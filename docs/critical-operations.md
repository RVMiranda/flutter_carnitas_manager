# Pagos e inventario: auditoría y reconciliación

Fecha: 2026-10-03. Fuente autoritativa: `supabase/migrations` en orden. Esta entrega modifica el cliente local y prepara `20261003070556_critical_operation_reconciliation.sql`; **no aplica migraciones ni cambia el servidor remoto**. Requiere también la migración previa del contrato bidireccional. No se ejecutaron SQL históricos de la raíz ni DROP PostgreSQL.

## Hallazgos y decisión

| Flujo auditado | Problema anterior | Decisión e impacto |
|---|---|---|
| LocalPaymentRepository | Insertaba transacción y asignaciones provisionales en el ledger. Una respuesta perdida o un rechazo no tenían estado de negocio separado. | Una nueva operación guarda intención inmutable en outbox y estado crítico. Sólo pull introduce el ledger aceptado. Registro repetido de la misma clave/payload no genera otro pago. |
| LocalInventoryRepository | Actualizaba stock_actual antes del servidor. Los rechazos conservaban un saldo optimista y la reconciliación borraba movimientos provisionales. | stock_actual conserva la imagen confirmada; las salidas reservan unidades por separado. Entradas pendientes no habilitan nuevas ventas. Un resultado incierto retiene la reserva; un rechazo explícito la libera con historial. |
| registrar_pago | Comprobaba la clave antes del bloqueo y no verificaba su payload. Acumulaba cantidades de abonos; dos pagos parciales del mismo producto podían rechazarse. | Recibos privados vinculan actor, clave, payload y resultado. Bloqueo de orden y validación del saldo total y por detalle; la cantidad describe una asignación, el monto determina el saldo pagado. |
| registrar_movimiento_inventario | El replay devolvía una coincidencia por clave sin comprobar intención; el stock no tenía precondición para ajustes. | Stock mínimo no negativo bajo bloqueo para ventas; expectedVersion obligatorio para ajustes admin. Rechazo durable: reponer stock no convierte el mismo intento rechazado en una venta. |
| Mapper de pull | Eliminaba filas provisionales y hacía UPDATE de ledgers. | Insert-only, rechaza tombstones y cambios de contenido financiero. Para filas locales legacy conserva el ID original y relaciona el ID canónico mediante sync_ledger_alias, sin borrar movimientos ni asignaciones. |

Problema: mezclar intención y aceptación hace que un resultado incierto parezca una operación concluida. Decisión: distinguir outbox, estado crítico, reservas y ledger confirmado. Motivo: proteger saldo, existencias y evidencia durante retries/rechazos. Impacto: Drift sigue siendo la fuente inmediata; el cajero ve operaciones pendientes o por revisar, y caja excluye pagos sin confirmación. No se resuelve un conflicto con last-write-wins.

## Estados e invariantes

| Estado local | Significado | Acción permitida |
|---|---|---|
| pending_sync | Intención guardada; falta respuesta válida del servidor. Incluye processing y retries automáticos. | Esperar; conservar clave, payload y reservas. |
| confirmed | ACK válido con transaction_id o movement_id, o estado legacy previamente completado. | Pull materializa el ledger y la versión del producto. No se permite otro pago de la orden antes de materializar la transacción. |
| rejected | El servidor devolvió rechazo conocido sin insertar pago/movimiento. | Registrar atención del rechazo. Si se recibió dinero, devolverlo o atender la incidencia física/bancaria antes de confirmar atención. |
| requires_review | Se agotaron reintentos, hubo conflicto, permiso denegado, respuesta inválida o resultado no certificado. | Consultar mediante replay del comando original con la misma clave. Nunca sustituirlo por una operación nueva ni marcarlo confirmado manualmente. |

`sync_queue` conserva su estado técnico pending/processing/completed/failed. `critical_operations` conserva el estado de negocio, rechazo conocido, atención, ID remoto y versión. `critical_events` registra intención, transitions, replay y atención con timestamps; es append-only. `sync_trace` conserva cada intento/recovery. La identidad local está fijada en sync_identity; los recibos remotos y movimientos conservan auth.uid como actor autoritativo. La evidencia de atención del cajero queda local; no es un comprobante de reembolso bancario ni una auditoría remota de acciones de UI.

ACK incorrecto o pérdida de respuesta no equivalen a rechazo. Una operación fallida no se borra. Atención de rechazo no borra la cola: sólo libera el bloqueo operativo conocido y deja constancia; sus filas siguen disponibles para auditoría. Los contadores de intervención excluyen rechazos ya atendidos.

Saldo disponible de inventario = stock confirmado + reservas negativas pendientes/inciertas. Cada clave reserva una sola vez. La reserva de una salida aceptada permanece hasta recibir el movimiento y una imagen de producto con versión >= product_version del recibo. Las entradas/compensaciones pendientes no incrementan disponibilidad. El pull conserva imágenes competidoras en sync_entity_state/sync_conflicts mientras haya comandos inciertos; aplica la imagen autoritativa después de un resultado conocido. Un rechazo registra la liberación, nunca un movimiento ficticio que el servidor no aceptó.

## Compensaciones

- Pago rechazado: nunca entra en transacciones/pago_detalles nuevos. La hoja accesible desde el banner permite registrar atención después de devolver dinero recibido o atender la incidencia. No fabrica un pago negativo ni cambia un pago aceptado.
- Inventario rechazado: libera la reserva local; conserva intención y rechazo. Una nueva corrección debe tener nueva clave y, para ajuste, la versión revisada del producto.
- Inventario aceptado: `InventoryRepository.compensate(movementId, idempotencyKey: ...)` crea una intención de cancelación positiva referida al movimiento remoto confirmado. La RPC añade otro movimiento y limita el total compensado a las unidades del original. Repetir la clave no duplica devolución; una segunda clave tampoco permite sobrecompensar. Esta API está disponible en Data; la hoja de revisión actual atiende rechazos y resultados inciertos, no ofrece un flujo completo de devoluciones de ventas aceptadas.
- Un reembolso de un pago **aceptado** requiere otro contrato de negocio (importe, método, autorización, comprobante, efecto en caja y devolución bancaria). Esta entrega no implementa ese flujo ni altera silenciosamente transacciones confirmadas.

## Dinero y precondiciones

Todos los importes son int/BIGINT en centavos. CurrencyUtils convierte texto decimal exacto a int, rechaza exponentes, más de dos decimales y fuera de BIGINT. Formato MXN usa cadenas e enteros, incluso por encima de 2^53 y para BIGINT mínimo. Caja dejó de dividir importes con `/ 100`. No quedan double monetarios en lib.

LocalPaymentRepository verifica asignaciones positivas, únicas, suma igual al importe, detalle local, cantidad y saldo disponible antes de encolar. Cancelados quedan fuera del preview. Las RPC vuelven a validar entradas, pertenencia de detalles, orden abierta, saldo y stock bajo bloqueo. Pagos no requieren CAS de versión de orden: la precondición remota es saldo suficiente/estado abierto serializado, lo que permite dos abonos concurrentes válidos. Ajustes absolutos o sensibles de inventario usan expectedVersion; ventas usan decremento de ledger con límite de stock bajo lock, sin enviar stock_actual calculado por Flutter.

## Cambios de seguridad

- registrar_pago y registrar_movimiento_inventario pasan de INVOKER a DEFINER controlados: search_path vacío, referencias calificadas, auth.uid obligatorio y rol admin/empleado explícito, EXECUTE sólo authenticated. Ajustes requieren admin y versión. Los clientes no escriben recibos.
- sync_execute_v2 valida rol incluso si auth_role retorna NULL. El dispatcher anterior conserva su objeto y queda sin EXECUTE de clientes; sólo v2 delega operaciones no críticas. sync_pull se reemplaza incrementalmente para negar roles NULL.
- Recibos privados de resultados críticos guardan también rechazos y no se publican por Realtime. Replays con otro actor/payload se rechazan. Pagos/movimientos legacy sin recibo requieren revisión, nunca una confirmación inferida.
- Se revocan todos los grants históricos de clientes en transacciones, pago_detalles, movimientos_inventario y productos; se concede sólo SELECT a authenticated sujeto a RLS. Una política restrictiva limita lectura de productos a staff. La futura app cliente necesita una proyección pública segura de menú; no recibe stock por esta vía.
- Triggers impiden UPDATE/DELETE de los tres ledgers y TRUNCATE de ledgers. Se revoca EXECUTE cliente de decrementar_stock, que no genera ledger.
- Estos límites DEFINER autorizan explícitamente; RLS no reemplaza esos controles. No se deshabilita RLS. Persisten pendientes generales: alta automática como empleado, otras RPC legacy, perfiles/lealtad y privilegios excesivos de tablas fuera de este alcance. Ver database-audit.md.

## Compatibilidad y despliegue

Drift migra incrementalmente a v6 y conserva registros anteriores. Filas de operaciones anteriores se marcan legacy_optimistic: no se reserva otra vez el descuento que versiones anteriores ya aplicaron a stock local. Conservan payload, ledger y trazabilidad. Un conflicto histórico no se borra ni convierte silenciosamente en éxito. Toda lectura financiera debe excluir intents legacy no confirmados, como hacen preview y caja.

El cliente ahora llama sync_execute_v2. Antes de distribuirlo hay que revisar catálogo e historial remoto, probar sobre rama Supabase desechable, revisar consumidores directos antiguos, aplicar las migraciones nuevas en orden y verificar ACL/RLS. El cambio de acceso público a productos y la revocación del dispatcher antiguo requieren coordinación de clientes. No activar el nuevo cliente contra backend sin estas funciones. El advisory lock global del contrato previo conserva orden del feed y recibos; limita throughput, por lo que debe medirse antes de aumentar dispositivos. No se cambian migraciones históricas aplicadas.

## Pruebas reproducibles

Flutter: suite completa, unit tests monetarios/locales, tests del motor con Drift real, widget test de estados/revisión; pérdida de respuesta, mismo key repetido, rechazo, stock reservado, append-only, cierre/reapertura de archivo SQLite y recuperación processing. Los tests del motor se ejecutan con flutter test; no son pruebas E2E de Android/Windows ni usan Supabase remoto.

PostgreSQL 17 desechable con Auth simulado: replay ordenado de migraciones; se omiten sólo los dos DROP IF EXISTS históricos que son no-op en una base vacía, sin alterar originales. Los contratos están en supabase/tests:

1. critical_concurrency_setup.sql prepara una orden de 100 centavos y stock 1.
2. Ejecutar critical_concurrent_call.sql en dos sesiones simultáneas, amount 40/60, payment_key distintas terminadas 011/012 y stock_key distintas 021/022. Repetir tres rondas con las mismas claves.
3. critical_operations_assert.sql exige exactamente dos abonos, total 100, un movimiento, stock 0 y rechazo durable de la otra venta; verifica permisos y append-only.
4. critical_compensation_contract.sql prueba sobrepago de una orden aún abierta, devolución idempotente, sobrecompensación, rechazo estable tras reponer stock, ajuste con versión antigua y acceso anon/privado. Usa rollback.
5. critical_unassigned_role_contract.sql niega RPC/pull/push sin rol. sync_contract.sql conserva CAS, tombstones y separación de roles a través de v2.

Resultados de esta entrega: 53 pruebas Flutter aprobadas; cadena completa de migraciones y cuatro contratos PostgreSQL aprobados, incluyendo tres rondas adicionales de replay concurrente. flutter analyze --no-pub limpio y build bundle --debug --no-pub verificado. Build nativo Windows conserva la limitación de symlinks/Developer Mode detectada en la fase anterior; no se modificó configuración del sistema.

Las identidades ficticias y el bootstrap se usan exclusivamente en una base desechable. Auth real, Realtime websocket y E2E en dispositivos no están certificados por estas pruebas.
