> Actualización 2026-10-03: [reconciliación de operaciones críticas](critical-operations.md) describe la migración incremental 20261003070556, Drift v6, sync_execute_v2 y las sustituciones de RPC/ACL. Sus decisiones y verificaciones posteriores complementan y sustituyen los comportamientos anteriores de pagos e inventario descritos aquí. Ninguna migración se aplicó al servidor remoto.

# Motor offline-first bidireccional

Implementado el 2026-10-03. Drift sigue siendo la fuente inmediata de la UI. El contrato remoto se encuentra en la **nueva** migración `supabase/migrations/20261003062018_bidirectional_sync_contract.sql`; no se aplicó a Supabase remoto y no se editaron migraciones anteriores.

## Problema, decisión, motivo e impacto

Problema: el worker sólo enviaba datos, dejaba `processing` huérfanos y guardaba excepciones completas; no había versiones, pull ni evidencia de eliminaciones.

Decisión: separar `SyncCoordinator`, `PushProcessor`, `PullProcessor`, `ConflictResolver` y `SyncRepository`. `DriftSyncStore` implementa las transacciones de cola, metadatos y reconciliación. Riverpod publica `SyncSnapshot` para estado/counters; los repositorios de negocio siguen leyendo Drift. Se conserva Riverpod en MVVM según instrucciones del proyecto, aunque el skill de arquitectura muestra ChangeNotifier como ejemplo.

Motivo: poder verificar fallos de red, atomicidad de páginas, replay y conflictos sin widgets ni conexión real; no confundir una respuesta perdida con una operación rechazada.

Impacto: la app necesita `sync_pull` y `sync_execute` para sincronizar. Si todavía no existen, mantiene Drift y la cola, muestra `sync_error` y **no recurre al antiguo upsert incondicional**. Es necesario desplegar primero el contrato revisado, luego la app. La compilación/las pruebas locales no certifican el esquema remoto.

## Responsabilidades y ciclo

| Componente | Responsabilidad |
|---|---|
| SyncCoordinator | Exclusión de ciclos, arranque/recuperación, señales de red/auth/Realtime, polling, estado observable y backoff de pull |
| PushProcessor | Claim condicional, envío, clasificación, límite de intentos, próxima ejecución persistida y trazabilidad |
| PullProcessor | Watermark estable por ciclo, paginación y validación del contrato; cursor avanza sólo tras transacción local exitosa |
| ConflictResolver | Decide cuándo aplicar servidor, preservar una edición o requerir revisión; no usa last-write-wins financiero |
| SyncRepository | Abstracción de push/pull/señales; Supabase encapsula RPC y Realtime |
| DriftSyncStore | Aplica imágenes/tombstones, conserva versiones y conflictos, reconcilia IDs y cuenta pendientes/fallidas |

Arranque → `processing` vuelve a `pending` con evento `recovered` → pull → push → pull/reconciliación. Un fallo entre commit remoto y ACK local se reintenta con la misma key y payload. No se borran operaciones completadas/fallidas ni se generan keys nuevas en reintentos. El procesamiento es FIFO por entidad/ID: una edición fallida bloquea sus sucesoras hasta revisión. Operaciones de entidades distintas pueden seguir progresando. No hay worker que ignore backoff por estar delante de un LIMIT: se filtran vencimientos antes del límite.

## Pull inicial e incremental

La migración añade `sync_version` a las 14 tablas de negocio y un feed en `private_sync.changes`. El backfill inicial registra cada fila existente. Desde cursor 0 se reconstruyen las filas accesibles; ciclos posteriores leen `seq > cursor`. Cada ciclo fija un watermark, procesa páginas de hasta 200 eventos y guarda imágenes más cursor en una sola transacción Drift. Errores de mapeo no avanzan el cursor ni dejan media página aplicada.

No se usa un timestamp del dispositivo como cursor: empates, precisión, cambios de reloj y commits fuera de orden pueden omitir datos. Los escritores toman un advisory lock transaccional común antes de emitir secuencias y lo mantienen hasta COMMIT. Así no se confirma un seq posterior mientras otro inferior sigue invisible. Los gaps de secuencia por rollback son normales. El lock serializa escrituras: adecuado como primera implementación del POS, pero requiere medir contención antes de escalar a varias sucursales. Escritores antiguos que toman locks de fila antes del advisory pueden producir deadlocks; `40P01` se clasifica transitorio. La RPC nueva toma primero el advisory.

Las páginas avanzan también sobre eventos ocultos, sin entregar su contenido. Sólo staff accede al feed; empleados no reciben empleados, nómina ni auditoría (más restrictivo que lectura propia de las políticas históricas). No se añadió un feed para clientes. No se cambiaron los permisos de Flutter.

## Realtime, red y UI

Realtime se registra en el adaptador; ignora el payload recibido y sólo emite una señal. El coordinador agrupa señales durante 250 ms y vuelve a consultar el feed. La migración agrega siete tablas operativas a `supabase_realtime` si existe la publicación. **Nunca publica el feed privado ni los recibos**. Las tablas no publicadas y los cambios de permisos se detectan por polling cada 15 s; perder una señal no pierde el dato.

`connectivity_plus` informa disponibilidad de interfaz de red, no garantiza acceso a internet. Los errores reales del transporte/RPC y el último ciclo determinan `sync_error`. Se exponen online, offline, reconnecting, syncing y sync_error, pendientes (pending + processing) y fallidas. El banner global sólo muestra texto seguro y counters. Realtime no modifica providers de dominio/UI.

Se cancelan listeners de conectividad, Auth, Realtime y timers al disponer. Se evita doble inicialización del coordinador/servicio. No se registra `error.toString()`, stacks o payloads de sincronización en logs ni en el banner.

## Persistencia local v5

| Tabla | Uso |
|---|---|
| sync_queue | Payload y key durables originales; estado/attempts; errores mediante códigos seguros |
| sync_operation_state | Versión base capturada al encolar y next_attempt_at persistido |
| sync_entity_state | Última versión/imagen del servidor y marca deleted, incluso si hay una edición pendiente |
| sync_checkpoint | Cursor durable por identidad autenticada |
| sync_trace | Eventos/operación/timestamp; no copia payloads ni excepciones |
| sync_conflicts | Referencia entidad/ID, motivo seguro y fecha; imagen remota disponible en sync_entity_state |
| sync_identity | Identidad propietaria de esta base/outbox; bloquea enviar la cola como otra cuenta |

Los metadatos se crean desde la estrategia de migración Drift. No requieren nuevos paquetes ni cambios manuales a archivos generados. La v5 además cambia CHECK de movimientos a cantidad != 0 y admite Domicilio en órdenes, recreando esas tablas con TableMigration para conservar filas. Se verificaron upgrades v1/v2/v3/v4. Las versiones base de operaciones antiguas que no tenían snapshot son 0: si el registro ya existe, se requiere revisión en vez de inventar una versión y sobrescribirlo.

La base actual se vincula al primer usuario que sincroniza; un cambio de cuenta se bloquea de forma segura. **No se implementó partición/migración de bases por múltiples cajeros**. Antes de habilitar cambio de identidad con una cola existente se necesita un flujo explícito de bases por identidad y una revisión de autorización de los datos locales. El caché de negocio existente no está cifrado y el control de acceso local previo no se rediseñó en esta tarea: no confundir la protección de envío de la cola con aislamiento completo del caché/UI entre usuarios o tras degradar roles. No borrar ni reasignar sync_identity para sortear el control.

## Conflictos por entidad

| Entidad | Regla |
|---|---|
| mesas, ordenes, detalle_orden | CAS: versión esperada debe coincidir. Conflicto conserva edición local y copia remota; nunca overwrite automático. Órdenes con pagos/cerradas/canceladas y detalles pagados requieren revisión; cierre sólo por pago RPC |
| promociones | sync_version además de updated_at; actualización remota concurrente requiere revisión, sólo admin escribe |
| empleados | CAS y admin; no sobreescribe cambios pendientes silenciosamente |
| nómina | INSERT inmutable por comando, sólo admin; no UPDATE/DELETE vía sync_execute |
| pagos/pago_detalles | Servidor autoritativo; sólo registrar_pago dentro de comando con recibo privado; no DML genérico del cliente. Asignaciones ajenas/canceladas/duplicadas se rechazan antes de la RPC existente |
| inventario | Movimiento + stock mediante RPC atómica; key estable y recibo; escritura directa de stock rechazada en comando |
| clientes/productos | CAS; campos de puntos/visitas/QR/stock no editables por este comando genérico |
| caja | RPC de corte administrativa/idempotente; snapshot recibido sustituye provisional por fecha |

Las ediciones locales pendientes no se reemplazan durante pull: se guarda la imagen del servidor. Después del ACK y del segundo pull, se aplican las imágenes diferidas cuando no hay operaciones sin resolver. Pagos e inventario se reconcilian por idempotency_key, eliminando únicamente filas provisionales del caché local y sustituyéndolas por los UUID canónicos del servidor. Esto no elimina transacciones remotas ni evidencia de la cola. No existe UI de resolución manual de conflictos en esta entrega; la evidencia se conserva para construir ese flujo con autorización y validación financiera explícitas.

Un pago no confirmado no suma a `paidCents` ni a ventas confirmadas. El preview expone awaitingConfirmationCents/requiresReview; no permite cobrar otra vez la misma orden mientras está pendiente/rechazada. Repetir el mismo request local es un no-op; payload distinto con la misma key es error. Caja no cierra con pagos sin confirmar/revisar; un corte provisional no se presenta como cierre confirmado hasta recibir el registro del servidor.

## Eliminaciones

DELETE produce un evento con deleted=true y versión siguiente, incluso si el dispositivo estuvo desconectado. Drift guarda el tombstone y elimina la fila del caché sólo si no tiene cambios pendientes; en otro caso conserva ambos lados. Los IDs eliminados no se pueden reutilizar. Feed/recibos/tombstones no tienen TTL: no borrar eventos sin diseñar antes compactación con generación de cursor y rebootstrap obligatorio. Un TRUNCATE no emite tombstones por fila: el grant histórico peligroso debe revocarse antes de producción.

## Errores y reintentos

Se distinguen SocketException/Timeout/HttpException, SQLSTATE de serialización/deadlock/locks/conexión/recursos, códigos PGRST de disponibilidad, HTTP 408/429/500/502/503/504, sesión inválida, conflicto y errores permanentes. Un SQLSTATE `50000` no se trata como HTTP 500. Errores desconocidos son permanentes para push; constraints, permisos y payload inválido no se reintentan automáticamente.

Hasta 8 intentos para errores reintentables; equal jitter entre la mitad y el máximo exponencial, acotado a 2 min. Vencimiento se persiste, y el timer lo vuelve a evaluar aunque no haya nuevos eventos de red. Pull aplica backoff acotado después de un ciclo fallido. Los códigos visibles/guardados son temporary_unavailable, session_required, conflict_requires_review y operation_requires_review. El contenido original de la operación permanece en almacenamiento local para revisión, nunca en mensajes de error.

## Cambios de seguridad y activación remota

Problema: exponer recibos mediante INSERT permitiría fabricar ACKs; un feed genérico podría filtrar nómina; los upserts antiguos ignoran conflictos.

Decisión: esquema privado con RLS, sin USAGE ni grants de tablas/secuencias/funciones a clientes; sync_pull y sync_execute son SECURITY DEFINER con search_path vacío, nombres calificados y EXECUTE sólo authenticated. Los cuerpos verifican auth.uid y user_roles, y limitan entidades/operaciones/campos. Recibos vinculan key, actor y request completo; replay con otro actor/payload se rechaza. Los triggers privilegiados sólo versionan y capturan cambios.

Motivo: escribir recibos privados en la misma transacción que una mutación, sin permitir falsificarlos desde la API. **Estas RPC no descansan en RLS de las tablas para autorizar:** el límite privilegiado utiliza controles explícitos. Se verificó admin/empleado/cliente/anon en PostgreSQL con identidades simuladas; esto requiere revisión de seguridad antes de despliegue.

Impacto: la nueva API es más restrictiva; columnas/correcciones históricas no admitidas requieren flujos separados. Replay de una operación legacy sin recibo requiere revisión, no un ACK inferido. Se conserva el SQL/RLS histórico, incluyendo grants excesivos, trigger que asigna empleado a altas nuevas, RPC legacy y DML directo. La migración de sincronización **no resuelve toda la auditoría de seguridad**. Aplicar el hardening incremental propuesto en database-audit.md antes de exponer esta API a una app de clientes/producción. Revisar también las limitaciones financieras ya documentadas de registrar_pago (por ejemplo semántica de cantidades de pagos parciales) y la política de pagos tardíos después de corte.

Antes de despliegue: cotejar historial/catálogo remoto, hacer respaldo, revisar/medir locks y tamaño de backfill, ejecutar suite en rama desechable Supabase, aplicar la migración nueva mediante el flujo del proyecto y confirmar publicaciones/ACL/advisors. No ejecutar SQL de la raíz ni reescribir migraciones aplicadas. No se aplicó nada remoto durante esta entrega.

## Verificación

- `flutter analyze --no-pub`: limpio.
- Suite Flutter: 41 pruebas, incluyendo motor + Drift real + servidor simulado; desconexión/reconexión, respuesta perdida, recovery, rechazo permanente, replay, FIFO, cursor/páginas, tombstones, rollback, identidad, UUID financiero y señales de invalidación. Cinco widget tests cubren estados/counters seguros del banner.
- `flutter build bundle --debug --no-pub`: correcto; confirma compilación Dart/Flutter del entrypoint y assets.
- Build nativo Windows bloqueado por soporte de symlinks: falta Developer Mode. No se modificó configuración del sistema. Android y Realtime websocket contra Supabase real no se ejecutaron.
- PostgreSQL 17 desechable: bootstrap Auth simulado, replay del esquema y nueva migración, pruebas sync_contract.sql con CAS/replay/tombstones/roles; dos sesiones concurrentes sync_concurrent_call.sql produjeron un único pago/asignación y un único descuento/movimiento de inventario. Fixtures en sync_concurrency_setup.sql y assertions en sync_concurrency_assert.sql.
- Replay PostgreSQL omitió únicamente los dos DROP IF EXISTS históricos de política/trigger que son no-op en una base vacía; los archivos originales no se alteraron. No se ejecutó database_app.sql ni DROP PostgreSQL.
- database_security_contract.sql de la auditoría previa sigue siendo una puerta de hardening que falla por grants históricos; no confundirla con la suite específica del contrato sync.

Referencias verificadas: [Realtime Postgres Changes](https://supabase.com/docs/guides/realtime/postgres-changes), [Dart subscribe](https://supabase.com/docs/reference/dart/subscribe), [funciones y seguridad](https://supabase.com/docs/guides/database/functions), [advisory locks](https://www.postgresql.org/docs/17/explicit-locking.html). Se revisó [changelog](https://supabase.com/changelog); las notas de pgcrypto legacy-cipher/ltree no afectan SHA-256 del QR ni este feed.
