# Mesas: auditoría y corrección — 5 de octubre de 2026

## Evidencia y alcance

Se verificó el proyecto enlazado mediante Supabase CLI 2.119.0 (`npx --no-install supabase`), después de consultar su ayuda. El proyecto enlazado coincide con el host configurado en la app. Las consultas fueron de lectura mediante `db query --linked`.

Resultado remoto al momento de la auditoría:

- 10 mesas, numeradas del 1 al 10, todas `Libre`; 0 órdenes.
- `mesas` y `ordenes` incluidas en la publicación Realtime.
- RPC `sync_execute_v2` y `sync_pull` disponibles.
- `numero_mesa` protegido por UNIQUE; `detalle_orden.precio_unitario` utiliza bigint en centavos.
- RLS permite insertar/actualizar mesas a admin y empleado; eliminar a admin. Existe SELECT público en mesas: se conserva y se registra como exposición a revisar en la auditoría general de seguridad.

Por tanto, la tabla remota consultada **sí contiene mesas**. La observación de un dashboard vacío no coincide con esta consulta; conviene comprobar proyecto, esquema y filtros del editor.

Se leyó una copia temporal de Drift de la app instalada en `emulator-5554`, sin modificar su almacenamiento: 10 mesas, 4 órdenes locales y 4 operaciones de órdenes fallidas con `operation_requires_review`. Sus fechas de apertura estaban serializadas como enteros. Las mesas 1, 2 y 7 tenían una orden abierta local. La copia y el script de diagnóstico se eliminaron después; no se conservaron datos personales ni payloads en esta documentación.

No se ejecutó `database_app.sql`, DROP, migraciones, escrituras remotas ni reintentos sobre la app instalada. `supabase/migrations` conserva su papel de fuente autoritativa; no se necesita una nueva migración para esta corrección. Los cambios de nómina/promociones que ya existían en el checkout se preservaron.

## Problema, decisión, motivo e impacto

**Problema:** la tarjeta ocupada quedaba deshabilitada; la acción de abrir intentaba crear otra orden. La apertura cambiaba el estado local de mesa sin encolar su actualización remota. El payload enviaba fechas epoch a columnas timestamptz, nombres de precio incompatibles y campos de tiempo reservados al servidor. El detalle no reaccionaba a cambios de líneas, y el orden textual colocaba Mesa 10 antes de Mesa 2.

**Decisión:** mantener Drift como fuente inmediata, abrir o recuperar la orden existente en una transacción local, encolar el estado de mesa y adaptar únicamente los payloads operativos al contrato RPC actual. Añadir alta de mesas con UUID local y cola persistente.

**Motivo:** evita duplicados por doble tap, permite trabajar offline y corrige la incompatibilidad sin borrar órdenes, reemplazar datos financieros ni cambiar el esquema remoto.

**Impacto:** las tarjetas ocupadas permiten continuar su orden; se muestran estados pendientes/fallidos; la numeración se ordena naturalmente. “Agregar mesa” valida 1–9999 y rechaza duplicados locales, guarda en Drift y sincroniza posteriormente. El detalle muestra el número real de mesa, líneas reactivas y navegación de regreso. Se conservan Outfit, Fraunces, temas claro/oscuro y los componentes de marca con foco, semántica y targets de 48 px.

## Compatibilidad, recuperación y seguridad

- Las fechas nuevas se envían como ISO UTC y los precios como centavos enteros, sin double.
- La conversión de payload antiguo ocurre al enviar y no altera la intención persistida ni la idempotency key. Se limita a mesas, órdenes y detalles: excluye pagos, inventario y nómina.
- “Reintentar envío anterior” recupera únicamente operaciones de la orden seleccionada rechazadas con `operation_requires_review` y formato antiguo reconocible. Añade `operator_requested_legacy_retry` a `sync_trace`. Conflictos y otros rechazos requieren revisión y no se reintentan por este mecanismo.
- El estado remoto de mesa se vuelve a encolar según la existencia actual de una orden abierta, incluso al recuperar una orden histórica.
- Una mesa ocupada sin orden disponible muestra una explicación y no crea otra orden silenciosamente.
- El alta conserva la validación remota existente y RLS; no usa service_role ni privilegios adicionales. Un número creado concurrentemente en otro dispositivo puede ser rechazado por UNIQUE y debe revisarse; no se sobrescribe ni borra la operación.
- Los errores visibles son mensajes controlados; no se muestran excepciones técnicas ni payloads.
- Orden y mesa siguen siendo operaciones separadas en la cola. Esta corrección no proporciona atomicidad distribuida entre ambas ni modifica la resolución de conflictos del motor existente.

## Verificación reproducible

```powershell
flutter analyze --no-pub
flutter test --no-pub test/tables_repository_test.dart test/tables_widget_test.dart test/operational_sync_payload_test.dart test/design/tables_visual_test.dart test/orders_test.dart test/orders_widget_test.dart test/platform_flows_test.dart --reporter=expanded --concurrency=2 --timeout=45s
flutter test --no-pub --reporter=expanded --concurrency=2 --timeout=45s
flutter build bundle --debug --no-pub
flutter build apk --debug --no-pub
```

- Análisis final: sin incidencias.
- Pruebas específicas y regresiones de órdenes/plataforma: **18 aprobadas**. Cubren alta offline, duplicados, doble apertura, recuperación de orden, rechazo de mesa ocupada sin orden, detalle reactivo, compatibilidad de payload y reintento auditable. Pruebas visuales verifican claro/oscuro, texto al 200%, semántica y targets.
- Suite completa: **99 aprobadas, 7 fallidas**. Una prueba de `employees_view_test.dart` espera “Pagada” y no la encuentra. Seis de `sync_status_banner_test.dart` esperan un banner construido con contadores de SyncSnapshot; el componente actual lo oculta cuando no hay operaciones críticas sin reconocer y obtiene sus contadores de esas operaciones. Estos archivos de producción no se modificaron para la corrección de mesas; no se atribuye su fallo a una línea base no ejecutada.
- Bundle debug: compilación correcta.
- APK debug: bloqueado antes de compilar el proyecto por `java.io.IOException: Unable to establish loopback connection` en Java/Gradle. La corrección **no está instalada todavía en el emulador**; la aceptación con backend real queda pendiente de disponer de un build nativo ejecutable.
- Renders de fixtures, revisados visualmente: `build/verification/tables-light.png`, `tables-dark.png`, `tables-large-text.png`. No son capturas de la app instalada.

Después de instalar una compilación nueva, abrir las mesas afectadas y usar el reintento explícito; comprobar que la cola se completa y que órdenes/estado aparecen en el proyecto enlazado. No borrar Drift para resolver la diferencia: contiene órdenes todavía no recibidas por el servidor.
