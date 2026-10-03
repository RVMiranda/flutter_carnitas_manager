> Actualización 2026-10-03: [reconciliación de operaciones críticas](critical-operations.md) describe la migración incremental 20261003070556, Drift v6, sync_execute_v2 y las sustituciones de RPC/ACL. Sus decisiones y verificaciones posteriores complementan y sustituyen los comportamientos anteriores de pagos e inventario descritos aquí. Ninguna migración se aplicó al servidor remoto.

# Auditoría de definición de base de datos

Fecha de revisión: 2026-10-02 (America/Mexico_City). Alcance: exclusivamente definición SQL y su correspondencia con autorización Flutter.

## Autoridad y límites

**`supabase/migrations/` es la única fuente autoritativa del esquema versionado**, en orden lexicográfico. No se deben ejecutar los SQL de la raíz para crear, actualizar ni recuperar entornos. Las nueve migraciones, hasta `20261003034251_phase10_idempotent_cash_register.sql`, definen el estado reconstruido aquí. El nombre temporal de un archivo no prueba su aplicación remota. No se consultó el historial remoto ni su catálogo: este informe NO certifica el esquema desplegado ni ausencia de drift.

No se ejecutó `database_app.sql`, ninguna operación DROP, migración ni escritura remota. No se modificaron migraciones existentes. Cambios de esta revisión: documentación y pruebas de catálogo/RLS; ninguna corrección de seguridad aplicada al esquema. Cambios generados de plataformas ya presentes en el árbol se conservaron.

| Archivo | Clasificación | Diferencias y peligro |
|---|---|---|
| `database.sql` | Histórico, obsoleto, inseguro | BIGINT para entidades sincronizables, NUMERIC monetario en unidades mayores; clientes.id directamente vinculado a auth.users; sin tablas de integridad ni RPC actuales. Autorización por user_metadata editable, FOR ALL de staff sobre nómina/promociones/caja. No es bootstrap compatible. |
| `database_app.sql` | Histórico, destructivo, prohibido como despliegue | Recrea diez tablas con DROP CASCADE; UUID y centavos anteceden a baseline, pero faltan user_roles, tablas de integridad y RPC posteriores. auth_role usa user_metadata; RPC DEFINER sin ACL/search_path seguros. La limpieza de corte usa firma date aunque crea date,uuid: puede dejar sobrecargas históricas. |
| `user_rol_set.sql` | Obsoleto, peligroso | Puede reemplazar set_user_role(text,text) segura por DEFINER sin control de admin ni search_path; escribe raw_user_meta_data en vez de user_roles. Su trigger tiene otro nombre y puede coexistir con el actual. No importar. |
| `supabase_phase1_roles_rls.sql` | Histórico, parcialmente divergente | Su cabecera manda ejecutar database_app.sql. Política user_roles dirigida implícitamente a PUBLIC, a diferencia de TO authenticated en migración. No revoca ACL antiguas de RPC/trigger ni incluye endurecimiento posterior. Backfill confía en metadatos inseguros. |
| `supabase/migrations/*` | Autoridad versionada, con riesgos pendientes | Baseline captura privilegios excesivos; fases posteriores no los eliminan ni sustituyen las RPC antiguas. Inmutables una vez aplicadas. |

## Esquema efectivo reconstruido

El inventario [database-schema-inventory.md](database-schema-inventory.md) contiene DDL de tablas/columnas/defaults, constraints/FK, índices, triggers, todas las políticas y evolución de grants, con procedencia. Las [once definiciones finales de funciones](database-effective-functions.md) separan los cuerpos vigentes de sus versiones sustituidas; la tabla de funciones de este informe consolida ALTER FUNCTION y ACL posteriores. Es documentación derivada, nunca una segunda fuente SQL ejecutable. No hay vistas, enums personalizados ni políticas Storage declarados. uuid-ossp es prerrequisito del baseline (no crea la extensión); fase 8 declara pgcrypto en extensions. Config local usa PostgreSQL 17, expone public/graphql_public; schema_paths vacío implica migraciones imperativas. No hay seed.sql aunque config lo referencia.

Todas las 15 tablas tienen RLS habilitado; ninguna declara FORCE RLS. Dueño/BYPASSRLS pueden evitarlo. IDs UUID salvo venta_diaria.id BIGINT identity (snapshot del servidor) y user_roles.user_id como PK/FK auth.users. No hay versionado de filas para conflictos offline.

| Tabla | Claves / integridad relevante |
|---|---|
| clientes | UUID; FK user_id → auth.users SET NULL; teléfono único nullable; contadores >=0 pero nullable; qr_token_hash único parcial, sin CHECK de formato; user_id no único |
| empleados | UUID; user_id → auth.users SET NULL, no único; salario bigint >0; dia_pago 1..31; activo obligatorio |
| productos | UUID; precio bigint >=0; stock_actual/minimo >=0 pero nullable; controla_inventario/activo obligatorios |
| mesas | UUID; numero_mesa único; estado Libre/Ocupada/Reservada |
| ordenes | UUID; mesa → mesas RESTRICT, cliente → clientes SET NULL; servicio Mesa/Para llevar/Domicilio; estado Abierta/Cerrada/Cancelada; índice único parcial una abierta por mesa; falta coherencia cierre/estado/mesa/servicio |
| detalle_orden | UUID; orden CASCADE, producto RESTRICT; cantidad >0, precio bigint >=0; pago Pendiente/Pagado/Cancelado |
| transacciones | UUID; orden RESTRICT; monto bigint >0; método Efectivo/Tarjeta/Transferencia/Otro; idempotency_key UUID único; sin actor/dispositivo/offline ni reversión |
| venta_diaria | BIGINT identity; fecha única; cerrado_por → empleados SET NULL; totales bigint obligatorios, sin CHECK no negativo/suma; num_ordenes sin CHECK |
| historial_pagos_empleados | UUID; empleado RESTRICT; monto bigint >0; fecha default CURRENT_DATE (zona de sesión); sin auditoría/idempotencia |
| user_roles | user_id PK → auth.users CASCADE; role admin/empleado; timestamps, sin trigger updated_at |
| pago_detalles | UUID; transacción/detalle RESTRICT; unique(transaccion_id,detalle_orden_id); cantidad/monto >0; no constraint que garantice misma orden ni sumas |
| movimientos_inventario | UUID; producto RESTRICT; creado_por → auth.users SET NULL; cantidad !=0; tipo enumerado CHECK; idempotency_key único; referencia UUID sin FK; signos no protegidos por CHECK |
| visitas_clientes | UUID; cliente RESTRICT; registrado_por → auth.users SET NULL; usuario_id → auth.users RESTRICT; unique(cliente,fecha) y unique(usuario,fecha) parcial; puntos >=0 |
| auditoria_eventos | UUID; actor → auth.users SET NULL; entidad/accion, jsonb, dispositivo/offline; no escritura automática desde RPC; entidad_id sin FK |

Baseline: 21 índices explícitos más índices PK/UNIQUE; fase 2 añade 6; fase 8 añade 2 únicos parciales. teléfono y fecha de corte tienen índice explícito redundante con UNIQUE. Revisar índices FK de venta_diaria.cerrado_por, movimientos.creado_por, visitas.registrado_por y auditoria.actor_id; no asumir necesidad sin cargas/EXPLAIN. Los siete triggers de updated_at cubren clientes, detalle_orden, empleados, mesas, ordenes, productos, promociones; trigger de auth crea user_roles.

## Matriz rol × operación × entidad

S=SELECT, I=INSERT, U=UPDATE, D=DELETE; propia=ownership por auth.uid. Esta es la matriz RLS, **condicionada por grants**. Para las diez tablas baseline están explícitos; para las cinco nuevas no se declaran grants y dependen de defaults del entorno. Un cliente futuro se modela aquí como authenticated SIN fila administrativa en user_roles; el trigger actual hace que esto no se cumpla en cuentas nuevas.

| Entidad | admin | empleado | futuro cliente sin rol staff | anon |
|---|---|---|---|---|
| clientes | SIUD | SIU | SU propia, todas las columnas | Sin vía autorizada; helper puede causar error ACL |
| empleados | SIUD | S propia | S propia si vinculado | Sin vía autorizada; helper puede causar error ACL |
| historial_pagos_empleados | SIUD | S propia | S propia si vinculado | Sin vía autorizada; helper puede causar error ACL |
| productos | SIUD | SIU | S todas las filas/columnas | S pública prevista; probar interacción ACL helper |
| mesas | SIUD | SIU | S todas | S pública prevista; probar interacción ACL helper |
| promociones | SIUD | S | S todas, incluso inactivas/futuras/vencidas | S pública prevista; probar interacción ACL helper |
| ordenes | SIUD | SIU | S propias | Sin vía autorizada |
| detalle_orden | SIUD | SIUD | S de orden propia | Sin vía autorizada |
| transacciones | SI | SI | — | — |
| venta_diaria | SIUD | S | — | — |
| user_roles | S todas; cambio sólo RPC | S propia | S propia si existiera | — |
| pago_detalles | SI | SI | — | — |
| movimientos_inventario | SI | SI | — | — |
| visitas_clientes | SI | SI | — | — |
| auditoria_eventos | SI | I | — | — |

**Fuera de la matriz RLS:** baseline concede TRUNCATE, REFERENCES, TRIGGER y MAINTAIN, además de SIUD, a anon/authenticated sobre las diez tablas. TRUNCATE no pasa por RLS; FK pueden impedir casos concretos, pero el grant sigue siendo crítico. venta_diaria_id_seq concede SELECT/UPDATE/USAGE a ambos: nextval/setval pueden alterar la secuencia sin RLS. Evitar cualquier prueba destructiva para comprobarlo; consultar has_table_privilege/has_sequence_privilege.

Las políticas baseline son TO PUBLIC y permisivas; se combinan por OR. Las nuevas son TO authenticated. UPDATE/ALL sin WITH CHECK reutiliza USING según PostgreSQL: **no significa ausencia de comprobación**. Aquí la condición staff no limita columnas/ownership; clientes_update_own sí tiene WITH CHECK explícito pero permite alterar puntos/QR/contadores. SELECT acompaña UPDATE en tablas actuales; SELECT FOR UPDATE también requiere política UPDATE. Las cuatro tablas de ledger/auditoría no tienen UPDATE: upsert de sincronización puede fallar al repetir un ID existente. El helper auth_role no permite EXECUTE a anon, mientras políticas TO PUBLIC lo invocan: validar consultas públicas reales; un OR USING(true) no garantiza orden de evaluación ni ausencia de error de permisos.

## Funciones, ACL y RPC

| Función / firma | Seguridad final / search_path | EXECUTE cliente / control del cuerpo |
|---|---|---|
| auth_role() | DEFINER / public,auth,extensions | authenticated; anon/PUBLIC revocados; consulta user_roles por auth.uid; bypass intencional evita recursión RLS |
| set_user_role(text,text) | DEFINER / public,auth,extensions | authenticated, admin en cuerpo; escribe tabla segura y app_metadata; no auditoría ni protección último admin |
| handle_new_user_role() | DEFINER / public,auth,extensions | PUBLIC/anon/authenticated revocados; trigger; asigna empleado a TODA alta |
| trigger_set_updated_at() | INVOKER implícito / public,auth,extensions | PUBLIC/anon/authenticated mantienen EXECUTE; retorna trigger, no RPC normal útil |
| decrementar_stock(uuid,integer) | DEFINER / public,auth,extensions | authenticated sin comprobar rol; cantidad negativa aumenta stock; sin movimiento ni idempotencia |
| registrar_visita_cliente(uuid) | DEFINER / public,auth,extensions | authenticated sin comprobar rol/QR/ownership; updated_at proxy de visita, CURRENT_DATE de sesión; no visita en ledger |
| realizar_corte_caja(date,uuid) | DEFINER / public,auth,extensions | authenticated con control admin; caller elige cerrado_por; sin idempotencia concurrente |
| registrar_pago(uuid,bigint,text,uuid,jsonb) | INVOKER / public | authenticated con control staff; bloqueo orden/detalles; necesita grants DML |
| registrar_movimiento_inventario(uuid,integer,text,uuid,uuid,text) | INVOKER / public | authenticated con control staff; bloqueo producto; signos sólo validados aquí |
| registrar_visita_qr(text) | INVOKER / public,extensions | authenticated con control staff; SHA256, visita única usuario/fecha; UPDATE clientes |
| realizar_corte_caja_seguro(date) | INVOKER / public,auth | authenticated con control admin; unique fecha y manejo unique_violation |

CREATE OR REPLACE conserva ACL existentes. Baseline concede también postgres/service_role para funciones/tablas; no son roles de cliente. Funciones nuevas tienen EXECUTE de authenticated explícito; ACL adicionales por default privileges no quedan determinadas por el repositorio. search_path fijado es mejor que mutable pero public/extensions deben ser esquemas no escribibles por roles no confiables; no hay REVOKE CREATE ON SCHEMA ni defaults explícitos. Preferir path vacío y referencias calificadas en futuras revisiones. DEFINER no es automáticamente un fallo: depende del dueño/BYPASSRLS y del control interno. Mantener sólo helpers/operaciones privilegiadas justificadas.

## Hallazgos priorizados y Permission Flutter

1. **Crítico — privilegios fuera de RLS:** TRUNCATE y secuencia UPDATE públicos; riesgo de borrado/alteración de identidad. No se ejecutaron.
2. **Crítico — alta automática de staff:** handle_new_user_role concede empleado a cualquier registro permitido por Auth. El backfill además importó admin desde metadatos editables. Auditar asignaciones existentes con evidencia externa; nunca degradar automáticamente usuarios legítimos. La tabla segura no elimina contaminación histórica.
3. **Alto — RPC antiguas:** stock/lealtad DEFINER permiten a cualquier authenticated evadir RLS y reglas actuales. Las nuevas RPC no las revocan.
4. **Alto — bypass de reglas financieras:** INSERT directo a transacciones/pago_detalles evita validar total, asignación a misma orden y estado. Staff puede editar/eliminar detalles ya pagados; admin modificar/eliminar nómina y cortes históricos. No hay reversión/auditoría obligatoria.
5. **Alto — perfiles:** cliente propio puede cambiar puntos, contadores, qr_token_hash y demás columnas; staff puede hacerlo globalmente. Falta vínculo usuario único y control de emisión de QR.
6. **Alto — inventario:** UPDATE producto cambia stock sin ledger, e INSERT movimiento no ajusta stock. Permission.manageInventory=true para empleado coincide con RLS SIU de productos, pero no delimita entrada/ajuste/merma versus venta. RPC admite todas a staff.
7. **Medio — exposición pública:** productos revelan inventario e inactivos; promociones sin ventana de publicación/vencimiento; mesas exponen estado operativo. Config local no demuestra configuración API remota.
8. **Medio — grants incompletos:** cinco tablas nuevas dependen de defaults externos. Puede fallar incluso SELECT user_roles/autorización Flutter. No cambiar DEFINER para ocultar este problema.
9. **Alto — registrar_pago:** no rechaza estado cerrado/cancelado ni excluye detalles Cancelado; acepta asignaciones externas a la orden si el resto suma p_monto (el INSERT recorre el JSON completo), sin garantía relacional. Replay sólo compara key, no payload; validaciones NULL pueden eludir IF y terminar en constraints en vez de error claro. El chequeo de idempotencia sucede antes del bloqueo: reintentos concurrentes pueden causar unique_violation en vez de respuesta idempotente.
10. **Medio — otras RPC:** inventario también comprueba key antes del lock y no compara payload; stock nullable puede quedar NULL. QR tiene dos unicidades: perfiles duplicados/preexistentes pueden colisionar por cliente/fecha fuera del ON CONFLICT(usuario,fecha). Corte no congela pagos tardíos ni coordina escritores; snapshot queda desactualizado; num_ordenes no es número de operaciones. LIMIT 1 de empleado es ambiguo sin user_id único.

| Permission (lib/core/permissions/permission.dart) | Correspondencia y diferencia |
|---|---|
| manageEmployees | admin sí / empleado no coincide para escritura empleados y nómina; RLS permite lectura propia al empleado y borrado histórico al admin, sin capacidad separada |
| manageInventory | ambos sí coincide broadly; SQL permite cambiar precio/catálogos/stock y usar RPC antiguas sin alcance específico |
| managePromotions | sólo admin escribe, coincide; lectura pública sin filtro no está representada |
| closeCashRegister | sólo admin, coincide en RPC; RLS permite también U/D corte, y empleado S reportes, no expresado por Permission |
| manageOrders | ambos sí; D orden sólo admin pero D detalle ambos, sin guardas financieras |
| processPayments | ambos sí; INSERT directo elude RPC y reglas, no equivale a cobro seguro |
| scanLoyalty | ambos sí; RPC antigua admite authenticated sin rol; UPDATE puntos directo excede escaneo |

AppRole sólo enumera admin/employee, SQL admin/empleado. No existe rol cliente en CHECK. Permission no cubre user_roles, auditoría, cancelaciones, lectura pública ni ownership. La búsqueda de usos sólo encontró la definición de Permission (no controles en vistas); la capa remota tiene allowlist y acceso DML genérico a ledgers. Esto no sustituye autorización backend. No se cambió Flutter durante esta auditoría.

## Propuesta de migraciones incrementales (no creadas/aplicadas)

Crear archivos NUEVOS con `supabase migration new` cuando se implemente cada corrección; nunca editar baseline/fases aplicadas. Antes, cotejar history y catálogo con consultas read-only. No aplicar un borrador con supuestos sobre grants/owners reales. Ningún paso exige ejecutar SQL histórico ni DROP.

| Prioridad / futura migración | Problema | Decisión | Motivo | Impacto / validación |
|---|---|---|---|---|
| 1 least_privilege_acl | grants peligrosos/defaults ambiguos | REVOKE TRUNCATE/TRIGGER/REFERENCES/MAINTAIN a clientes; secuencia sólo USAGE a authenticated si necesario; grants explícitos mínimos a 15 tablas; defaults restringidos por owner | RLS no cubre privilegios estructurales | Revisar CRUD/RPC; catálogo debe negar TRUNCATE/setval; no cambia datos |
| 2 staff_provisioning | alta pública e importación insegura | CREATE OR REPLACE trigger para no conceder staff; aprovisionamiento admin controlado; clientes sin rol staff; revisión manual del backfill | Evitar escalamiento | Nuevos empleados requieren invitación/asignación; preservar existentes hasta verificación; probar signup cliente y revocación inmediata |
| 3 retire_legacy_rpc | bypass DEFINER | REVOKE EXECUTE PUBLIC/anon/authenticated en tres RPC antiguas; conservar objetos; actualizar consumidores si existen | Eliminar rutas paralelas sin DROP | Verificar consumidores externos; sólo nuevas RPC disponibles; ACL owner/service revisada |
| 4 profile_public_scope | edición puntos y exposición | ALTER POLICY TO authenticated y USING/WITH CHECK explícitos; limitar columnas de perfil mediante ACL/RPC; políticas públicas separadas con ventana y activo; projection segura de menú sin stock; restringir mesas | Ownership de filas no protege columnas | App cliente deberá usar API limitada; probar SU propio/ajeno, puntos prohibidos, promociones futuras ocultas |
| 5 atomic_ledger_boundary | DML directo y RPC débiles | RPC privilegiadas mínimas con actor validado, search_path vacío, nombres calificados, ACL restringidas; revocar DML directo de ledgers y columnas críticas; validar payload/orden/estado/replay bajo lock | INVOKER necesita DML y por sí solo no fuerza pasar por RPC | Cambiar sync genérico por comandos; probar concurrentes, rollback completo, key distinto payload, reversión y auditoría; no revocar DML antes de adaptar RPC |
| 6 integrity_constraints | NULL, identidad duplicada, cierres incoherentes | Diagnóstico de filas; backfill controlado; CHECK/FK NOT VALID y VALIDATE posterior donde soportado; NOT NULL y UNIQUE sólo tras reparar datos; triggers/locks para invariantes multitabla | No borrar ni corregir silenciosamente históricos | Plan por volumen/downtime; no CHECK con subconsultas para sumas; UUID corte sólo si cliente crea cortes offline, no convertir sin necesidad |

## Verificación y pendientes

- `flutter analyze`: **No issues found** (19.7 s). No dependencias agregadas.
- Pruebas SQL añadidas en `supabase/tests/database_security_contract.sql`: contrato objetivo de catálogo y prueba RLS sin identidad sobre user_roles, con ROLLBACK. Las comprobaciones de privilegios peligrosos DEBEN fallar contra baseline actual: son puertas para el hardening, no un certificado verde. No ejecutadas: CLI Supabase/psql no disponibles y Docker no accesible en esta sesión. No se inició stack ni se reejecutaron migraciones con DROP.
- `supabase/inspection/effective_schema.sql`: extracción read-only de catálogo real, owners, ACL, defaults, políticas, extensiones y migration history. Compararla con inventario antes de despliegue. Ejecutar pruebas sólo en entorno desechable ya provisionado, con ON_ERROR_STOP; después ampliar fixtures admin/empleado/cliente, SELECT/INSERT/UPDATE/DELETE y RPC concurrentes al implementar cada corrección.
- El changelog.md no pudo leerse mediante el navegador por content-type; se consultó changelog HTML y documentación oficial. No hay implementación de API nueva en esta auditoría.

Referencias: [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security), [funciones](https://supabase.com/docs/guides/database/functions), [PostgreSQL CREATE POLICY](https://www.postgresql.org/docs/17/sql-createpolicy.html), [RLS y operaciones no cubiertas](https://www.postgresql.org/docs/17/ddl-rowsecurity.html), [changelog](https://supabase.com/changelog). PostgreSQL reutiliza USING como WITH CHECK si falta este último; las políticas permisivas se combinan por OR. No diagnosticar un bypass sólo por ausencia textual de WITH CHECK.
