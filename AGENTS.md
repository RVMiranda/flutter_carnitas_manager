# Flutter Taquería — Instrucciones Maestras para el Agente de Desarrollo

## 1. Rol principal

Actúa como un **Senior Flutter Software Engineer / Mobile & Desktop Application Architect**, especializado en:

- Flutter y Dart.
- Aplicaciones Android y Windows.
- Arquitecturas escalables y mantenibles.
- MVVM.
- Clean Architecture cuando aporte valor.
- Riverpod para gestión de estado e inyección de dependencias.
- PostgreSQL y Supabase.
- Row Level Security (RLS).
- Sistemas Offline-First.
- Sincronización de datos.
- Sistemas POS / restaurantes.
- Manejo de transacciones y consistencia de datos.
- Seguridad de aplicaciones.
- UX/UI para aplicaciones operativas.

Tu responsabilidad no es simplemente "hacer que compile".

Debes construir una aplicación **profesional, mantenible, segura, escalable, testeable y preparada para crecer**.

Prioriza siempre:

1. Correctitud.
2. Seguridad.
3. Integridad de datos.
4. Mantenibilidad.
5. Testabilidad.
6. Escalabilidad.
7. Experiencia de usuario.
8. Rendimiento.
9. Simplicidad razonable.

No implementes soluciones rápidas que comprometan la arquitectura futura.

---

# 2. Contexto del proyecto

Se está construyendo un sistema de gestión para una taquería.

El sistema tendrá inicialmente dos aplicaciones independientes:

### Aplicación administrativa

Será utilizada por:

- Administrador / dueño.
- Cajeros.
- Meseros.
- Personal autorizado.

Plataformas iniciales:

- Android.
- Windows.

### Aplicación para clientes

Será desarrollada posteriormente y estará orientada a:

- Lealtad.
- Puntos.
- Promociones.
- Historial.
- Información pública del negocio.

**En este proyecto debes concentrarte únicamente en la aplicación administrativa**, pero toda decisión de arquitectura debe permitir que posteriormente exista una aplicación para clientes sin tener que rehacer el backend.

---

# 3. Funcionalidades principales

La aplicación administrativa debe quedar preparada para manejar:

## 3.1 Mesas y órdenes

- Visualización de mesas.
- Estado de mesas.
- Mesa libre.
- Mesa ocupada.
- Apertura de órdenes.
- Modificación de órdenes.
- Agregar productos.
- Eliminar productos.
- Modificar cantidades.
- Pedidos para llevar.
- Cambio de estado de órdenes.
- Consulta de órdenes abiertas.
- Consulta de órdenes cerradas.
- Asociación opcional de cliente.
- Historial.

La interfaz debe actualizarse reactivamente cuando cambien los datos.

---

# 4. Sistema de cobro

El sistema debe soportar:

- Pago completo.
- Pago parcial.
- Pago por producto.
- Pago por cantidad de un producto.
- Pago por monto.
- Diferentes métodos de pago.
- Múltiples transacciones para una misma orden.
- División de cuenta.
- Estado de pago por cada elemento de la orden.
- Cálculo correcto del total pendiente.
- Cálculo de total pagado.
- Cálculo de cambio cuando corresponda.

La lógica financiera debe mantenerse fuera de las vistas.

No realizar cálculos importantes directamente dentro de widgets.

Toda operación monetaria debe manejarse de forma segura y consistente.

Evita utilizar `double` para cálculos monetarios cuando pueda producir errores de precisión.

Utiliza una estrategia apropiada, por ejemplo:

- `int` representando centavos, o
- `Decimal` mediante una solución adecuada.

La estrategia deberá ser consistente en toda la aplicación.

---

# 5. Inventario

El sistema debe diferenciar entre productos:

### Productos sin inventario limitado

Ejemplo:

- Tacos.
- Tortas.
- Productos cuya existencia no se controla individualmente.

Estos pueden venderse sin necesidad de descontar stock.

### Productos con inventario

Ejemplo:

- Refrescos.
- Agua embotellada.
- Productos físicos limitados.

Estos deben:

- Tener stock actual.
- Tener stock mínimo.
- Descontarse automáticamente cuando corresponda.
- Generar alertas cuando alcancen el mínimo.
- Impedir operaciones inválidas cuando corresponda.

La lógica de inventario debe estar encapsulada en una capa apropiada.

No duplicar lógica de inventario entre pantallas.

---

# 6. Nómina

Debe existir soporte para:

- Empleados.
- Nombre.
- Apellido.
- Teléfono.
- Salario.
- Día de pago.
- Historial de pagos.
- Registro de pago.
- Notas.
- Consulta de próximos pagos.
- Identificación de empleados cuyo pago corresponde al día actual.

La aplicación debe mostrar de forma clara:

> "Hoy corresponde pagar a..."

La información debe actualizarse automáticamente cuando cambie la fecha o los datos relevantes.

---

# 7. Lealtad y QR

La aplicación administrativa debe integrar un lector QR.

Utiliza una librería adecuada y mantenida, por ejemplo:

- `mobile_scanner`

El flujo debe permitir:

1. Abrir lector.
2. Detectar QR.
3. Validar contenido.
4. Identificar al cliente.
5. Consultar información necesaria.
6. Registrar la visita.
7. Actualizar puntos.
8. Mostrar confirmación visual.
9. Manejar errores.
10. Evitar registros duplicados accidentales.

No asumir que todo QR es válido.

La validación debe realizarse de forma segura.

---

# 8. Promociones

Debe existir un módulo para:

- Crear promociones.
- Editar promociones.
- Activar/desactivar promociones.
- Definir título.
- Definir descripción.
- Definir imagen.
- Definir fecha de publicación.
- Definir fecha de vencimiento.
- Publicar promociones.

La arquitectura debe permitir que posteriormente la aplicación de clientes pueda consultar las promociones públicas.

---

# 9. Corte de caja

Debe existir un módulo para:

- Consultar ventas del día.
- Consultar transacciones.
- Agrupar por método de pago.
- Mostrar efectivo.
- Mostrar tarjeta.
- Mostrar total.
- Mostrar número de operaciones.
- Realizar cierre de caja.
- Registrar hora de cierre.
- Consultar cortes anteriores.

La información financiera debe tratarse como información crítica.

No eliminar transacciones históricas como mecanismo normal de corrección.

Preferir mecanismos de auditoría, reversión o corrección controlada.

---

# 10. Base de datos y Supabase

El backend utiliza:

- Supabase.
- PostgreSQL.
- Supabase Auth.
- RLS.
- Realtime cuando sea apropiado.

Existe un archivo:

```text
database.sql
```

en la raíz del proyecto.

## IMPORTANTE

Antes de comenzar a implementar funcionalidades, debes:

1. Leer `database.sql`.
2. Analizar todas las tablas.
3. Analizar relaciones.
4. Analizar constraints.
5. Analizar índices.
6. Analizar políticas RLS.
7. Detectar inconsistencias.
8. Detectar riesgos de seguridad.
9. Detectar problemas de integridad.
10. Comparar el esquema actual con los requerimientos de esta aplicación.

No asumas que el SQL actual es perfecto.

Si detectas problemas importantes, debes documentarlos antes de implementar la funcionalidad afectada.

---

# 11. Identificadores

La arquitectura objetivo utiliza UUID v4 para las entidades sincronizadas.

El esquema SQL actual puede contener IDs `BIGINT`.

Esto debe ser auditado.

Si existe una inconsistencia entre el esquema actual y la arquitectura requerida:

- No la ignores.
- No generes modelos Flutter inconsistentes.
- No agregues conversiones improvisadas.
- No mezcles UUID y BIGINT sin una razón arquitectónica clara.

Propón y aplica una estrategia coherente.

Las entidades que necesiten sincronización offline deben tener identificadores seguros para generar localmente y sincronizar posteriormente.

Preferentemente:

```text
UUID v4
```

Esto permite crear registros offline sin depender de PostgreSQL para generar el ID.

---

# 12. Seguridad y RLS

La seguridad debe diseñarse desde la base de datos.

Nunca confiar únicamente en:

- Ocultar botones.
- Ocultar pantallas.
- Validaciones del frontend.

El backend debe impedir operaciones no autorizadas.

Audita cuidadosamente las políticas RLS existentes.

Considera:

- `auth.uid()`
- roles.
- permisos.
- ownership.
- acceso de empleados.
- acceso de administradores.
- acceso de clientes.
- datos públicos.
- datos privados.

No utilizar la `service_role` key dentro de Flutter.

Nunca exponer secretos del backend en la aplicación.

La aplicación Flutter solamente debe utilizar credenciales destinadas al cliente.

---

# 13. Roles y permisos

Diseña la arquitectura para soportar como mínimo:

```text
admin
empleado
```

Y deja preparada la arquitectura para agregar posteriormente roles más específicos, por ejemplo:

```text
cajero
mesero
gerente
```

No hardcodear toda la lógica de permisos directamente dentro de widgets.

Crear una abstracción de autorización.

Ejemplo conceptual:

```dart
Permission.canManageEmployees
Permission.canCloseCashRegister
Permission.canManageInventory
Permission.canManagePromotions
```

La implementación exacta queda a criterio del arquitecto siempre que mantenga buena cohesión.

---

# 14. Arquitectura Flutter

Utiliza como base:

```text
MVVM
```

con separación clara de responsabilidades.

Puedes incorporar principios de Clean Architecture cuando realmente aporten valor.

No conviertas la arquitectura en una sobreingeniería innecesaria.

La aplicación debe separar como mínimo:

```text
Presentation
Domain
Data
Core
```

La estructura exacta puede cambiar si existe una mejor solución.

La regla fundamental es:

> Cada módulo debe tener una responsabilidad clara y las dependencias deben apuntar en una dirección controlada.

---

# 15. Estructura sugerida

Puedes utilizar una estructura similar a:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   ├── theme/
│   └── configuration/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── network/
│   ├── result/
│   ├── utils/
│   ├── logging/
│   ├── permissions/
│   └── connectivity/
│
├── data/
│   ├── local/
│   ├── remote/
│   ├── models/
│   ├── repositories/
│   └── synchronization/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── use_cases/
│
├── features/
│   ├── authentication/
│   ├── tables/
│   ├── orders/
│   ├── payments/
│   ├── inventory/
│   ├── employees/
│   ├── payroll/
│   ├── loyalty/
│   ├── promotions/
│   └── cash_register/
│
└── shared/
    ├── widgets/
    ├── dialogs/
    ├── loading/
    └── components/
```

Esta estructura es una guía, no una obligación.

Puedes modificarla si encuentras una arquitectura mejor.

Sin embargo, cualquier cambio estructural importante debe tener una justificación.

---

# 16. MVVM

Cada feature deberá mantener una separación similar a:

```text
View
ViewModel
Model / Entity
Repository
UseCase
```

Ejemplo:

```text
features/
└── orders/
    ├── presentation/
    │   ├── views/
    │   ├── widgets/
    │   └── view_models/
    │
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── use_cases/
    │
    └── data/
        ├── models/
        ├── data_sources/
        └── repositories/
```

La View:

- Renderiza UI.
- Escucha estado.
- Envía acciones.

La ViewModel:

- Coordina acciones de UI.
- Maneja estados.
- Ejecuta casos de uso.
- Expone información observable.

El Domain:

- Contiene reglas de negocio.
- No depende de Flutter.
- No depende directamente de Supabase.

Data:

- Maneja persistencia.
- Supabase.
- Base local.
- DTOs.
- sincronización.

---

# 17. Riverpod

Utiliza:

```text
Riverpod
```

como mecanismo principal para:

- Estado.
- Dependency Injection.
- Providers.
- ViewModels.
- Repositories.
- Servicios.
- Casos de uso.

Evita:

- `Provider` globales manuales.
- Singleton innecesario.
- Variables globales mutables.
- Estado escondido dentro de widgets.

Las dependencias deben poder reemplazarse fácilmente durante testing.

---

# 18. Offline-First — REQUISITO CRÍTICO

La aplicación debe poder seguir funcionando cuando no exista conexión a internet.

La UI NO debe depender directamente de Supabase.

La fuente inmediata de datos para la interfaz debe ser una base de datos local.

Puedes evaluar:

- Drift.
- Isar.

Selecciona la opción que mejor encaje con:

- Flutter Android.
- Flutter Windows.
- Relaciones complejas.
- Consultas.
- Transacciones.
- Offline-first.
- Sincronización.
- Mantenibilidad.

Explica brevemente la decisión antes de implementar.

---

# 19. Principio de Source of Truth

La aplicación debe seguir esta arquitectura conceptual:

```text
UI
 ↓
ViewModel
 ↓
UseCase
 ↓
Repository
 ↓
Local Database
 ↓
Sync Engine
 ↓
Supabase
```

La UI debe reaccionar principalmente a cambios de la base local.

Supabase funciona como backend remoto y mecanismo de sincronización.

No diseñar la aplicación como:

```text
UI → Supabase
```

---

# 20. Sync Queue

Debe existir un mecanismo similar a:

```text
sync_queue
```

en almacenamiento local.

Cada operación offline debe registrar información suficiente para reproducirla posteriormente.

Como mínimo considerar:

```text
id
entity
entity_id
operation
payload
created_at
attempts
last_attempt_at
status
error
```

La estructura exacta puede cambiar si existe una solución superior.

Estados posibles:

```text
pending
processing
completed
failed
```

La cola debe soportar:

- Reintentos.
- Backoff.
- Errores temporales.
- Errores permanentes.
- Detección de duplicados.
- Idempotencia.
- Trazabilidad.

---

# 21. Sincronización

Cuando vuelva la conexión:

1. Detectar conectividad.
2. Procesar operaciones pendientes.
3. Ejecutar operaciones de forma segura.
4. Confirmar éxito.
5. Marcar operación como sincronizada.
6. Reintentar fallos temporales.
7. Registrar errores permanentes.
8. Actualizar datos locales.

Nunca borrar silenciosamente una operación fallida.

Debe existir trazabilidad.

---

# 22. Conflictos

Debes diseñar una estrategia para conflictos.

Ejemplos:

- Dos dispositivos modifican una misma mesa.
- Dos empleados modifican una orden.
- Se vende un producto limitado mientras otro dispositivo actualiza inventario.
- Una transacción fue creada offline.
- Dos operaciones intentan descontar stock.

No asumir que los conflictos nunca ocurrirán.

Define reglas claras de:

```text
consistencia
idempotencia
orden de operaciones
resolución de conflictos
```

Cuando una operación sea crítica financieramente, prioriza la integridad del dato sobre una resolución silenciosa.

---

# 23. Conectividad

La aplicación debe detectar:

```text
online
offline
reconnecting
syncing
sync_error
```

El usuario debe saber claramente cuándo:

- Está trabajando offline.
- Se están sincronizando datos.
- La sincronización terminó.
- Existe un problema de sincronización.

No bombardear al usuario con mensajes innecesarios.

---

# 24. Manejo de estados

El manejo de estados es una prioridad.

Cada pantalla debe contemplar correctamente:

```text
initial
loading
success
empty
error
offline
syncing
```

Cuando corresponda:

```text
saving
saved
deleting
deleted
processing
```

Evitar pantallas congeladas o sin feedback.

---

# 25. Loading UX

Utiliza:

- Shimmers.
- Skeletons.
- Progress indicators.
- Animaciones.
- Estados de transición.
- Confirmaciones visuales.

Ejemplo:

Cuando se registra un pago:

```text
Usuario presiona "Cobrar"
        ↓
Botón cambia a estado procesando
        ↓
Se ejecuta operación
        ↓
Se confirma operación
        ↓
UI muestra éxito
        ↓
Estado local actualizado
        ↓
Sincronización posterior
```

No permitir doble ejecución accidental por múltiples taps.

---

# 26. Diseño y UI/UX

Existe una carpeta en la raíz:

```text
design_example/
```

Contiene archivos web con un mockup inicial.

Existe además un archivo Markdown en la raíz con instrucciones de diseño.

Antes de construir la interfaz:

1. Revisa `design_example/`.
2. Revisa el archivo de instrucciones de diseño.
3. Comprende la intención visual.
4. Identifica componentes reutilizables.
5. Replica el lenguaje visual en Flutter.

No copies literalmente HTML/CSS.

Adapta el diseño correctamente a Flutter.

---

# 27. Identidad visual

La interfaz debe mantener una estética:

- Minimalista.
- Moderna.
- Operativa.
- Clara.
- Rápida de utilizar.
- Adecuada para una taquería.
- Fácil de utilizar durante horas de trabajo.

Paleta aproximada:

- Salmón / rosa pastel.
- Azul oscuro.
- Amarillo cálido.
- Rojo lona.

Debe existir:

```text
Light Theme
Dark Theme
```

Centraliza:

- Colores.
- Tipografías.
- Espaciado.
- Bordes.
- Elevaciones.
- Radios.
- Animaciones.

No repetir valores visuales arbitrariamente por toda la aplicación.

---

# 28. Navegación principal

La navegación principal debe contemplar:

1. Mesas y pedidos.
2. Menú e inventario.
3. Lector QR.
4. Nómina y empleados.
5. Promociones.

El lector QR debe funcionar como acción central destacada.

La navegación secundaria debe contemplar:

- Usuario/cajero.
- Fecha.
- Configuración.
- Gráficas.
- Corte de caja.
- Opciones administrativas.

El diseño exacto debe basarse en:

```text
design_example/
```

y las instrucciones de diseño existentes.

---

# 29. Responsive Design

La aplicación debe considerar:

### Android

- Teléfonos.
- Tablets.
- Diferentes orientaciones cuando sea necesario.

### Windows

- PC.
- Diferentes resoluciones.
- Mouse.
- Teclado.
- Touch cuando esté disponible.

No construir una interfaz que funcione únicamente en una resolución.

Utiliza layouts adaptativos.

---

# 30. Paquetes y dependencias

El proyecto acaba de crearse.

Está permitido y esperado agregar las dependencias necesarias.

Evalúa e incorpora librerías mantenidas y apropiadas para:

- Riverpod.
- Supabase.
- Base de datos local.
- Connectivity.
- QR scanner.
- PDF.
- Printing.
- Gráficos.
- UUID.
- Logging.
- Routing.
- Serialización.
- Manejo de fechas.
- Testing.

Por ejemplo:

```text
flutter_riverpod
supabase_flutter
drift
mobile_scanner
pdf
printing
fl_chart
uuid
```

No agregues paquetes simplemente por conveniencia.

Antes de agregar una dependencia:

1. Verifica que sea necesaria.
2. Evalúa mantenimiento.
3. Evalúa compatibilidad Android/Windows.
4. Evalúa estabilidad.
5. Evita dependencias redundantes.

Mantén `pubspec.yaml` limpio.

---

# 31. PDF y tickets

El sistema deberá quedar preparado para:

- Generar tickets.
- Generar comprobantes.
- Imprimir.
- Exportar PDF.

Utilizar las librerías apropiadas.

La generación de documentos no debe estar mezclada con la lógica de negocio.

---

# 32. Gráficas

Utilizar una solución como:

```text
fl_chart
```

para:

- Ventas.
- Métodos de pago.
- Tendencias.
- Productos.
- Inventario.

Los widgets de gráficas deben recibir datos ya procesados.

No meter consultas complejas dentro del widget.

---

# 33. Logs y debugging

Implementa un sistema de logging apropiado.

Los logs deben permitir diagnosticar:

- Sincronización.
- Errores de Supabase.
- Errores locales.
- Errores de autenticación.
- Operaciones críticas.

Nunca escribir:

- Contraseñas.
- Tokens.
- Secrets.
- Service role keys.
- Información sensible innecesaria.

---

# 34. Errores

No mostrar errores técnicos directamente al usuario.

Convertir errores internos en errores de dominio/presentación apropiados.

Ejemplo:

En lugar de:

```text
PostgrestException(code: 23505...)
```

mostrar:

```text
No fue posible guardar el producto porque ya existe uno con ese nombre.
```

Pero conservar suficiente información en logs para debugging.

---

# 35. Validación

Toda entrada del usuario debe validarse.

Especial atención en:

- Dinero.
- Cantidades.
- Teléfonos.
- Nombres.
- Fechas.
- Stock.
- Métodos de pago.
- QR.
- Formularios administrativos.

No confiar exclusivamente en validaciones del frontend.

---

# 36. Seguridad

Nunca:

- Hardcodear passwords.
- Hardcodear tokens privados.
- Exponer secrets.
- Utilizar service role key.
- Desactivar RLS para simplificar.
- Bypassear permisos desde Flutter.
- Confiar únicamente en permisos visuales.

Todo acceso sensible debe estar protegido por backend/RLS.

---

# 37. Testing

El proyecto debe estar preparado para:

### Unit tests

Para:

- Casos de uso.
- Cálculos.
- Pagos.
- Inventario.
- Nómina.
- Sincronización.
- Validaciones.

### Widget tests

Para:

- Estados de UI.
- Formularios.
- Errores.
- Loading.
- Interacciones.

### Integration tests

Para flujos críticos:

```text
Crear orden
Agregar productos
Cobrar
Cerrar orden
```

y:

```text
Crear operación offline
Perder conexión
Recuperar conexión
Sincronizar
```

---

# 38. Principio de Responsabilidad Única

No crear clases gigantes.

Evitar:

```text
OrderViewModel
```

con cientos de métodos que manejen:

- UI.
- Base de datos.
- Supabase.
- PDF.
- inventario.
- pagos.
- navegación.

Separar responsabilidades.

Una clase debe tener una razón clara para cambiar.

---

# 39. Evitar sobreingeniería

No crear abstracciones solamente porque "la arquitectura lo pide".

Cada abstracción debe aportar:

- testabilidad,
- mantenibilidad,
- separación,
- reutilización,
- seguridad,
- escalabilidad.

Prefiere código claro sobre patrones innecesariamente complejos.

---

# 40. Reglas para modificar código

Antes de modificar una parte importante:

1. Comprende el código existente.
2. Identifica dependencias.
3. Identifica impacto.
4. Implementa el cambio.
5. Ejecuta análisis estático.
6. Ejecuta tests relevantes.
7. Verifica compilación.

No reescribas archivos completos si solamente es necesario modificar una pequeña sección.

No introducir código duplicado.

---

# 41. Flutter analysis

Mantener:

```text
flutter analyze
```

sin errores.

El código debe respetar las buenas prácticas de Dart.

Evitar:

- `dynamic` innecesario.
- `!` innecesario.
- `BuildContext` fuera de su responsabilidad.
- Estado mutable global.
- Código muerto.
- imports innecesarios.
- warnings ignorados sin justificación.

---

# 42. Reglas para Riverpod

Los Providers deben representar dependencias o estado de forma clara.

Preferir providers modernos de Riverpod y generación de código cuando sea conveniente.

Las ViewModels deben poder:

- exponerse mediante providers.
- reaccionar a cambios.
- invalidarse.
- refrescar datos.
- manejar estados.

No usar Riverpod como una caja global donde se coloque toda la lógica.

---

# 43. Reglas de repositorios

El ViewModel no debe conocer directamente:

```text
SupabaseClient
```

La dependencia debe pasar por abstracciones apropiadas.

Ejemplo conceptual:

```text
ViewModel
   ↓
UseCase
   ↓
Repository Interface
   ↓
Repository Implementation
   ↓
Local / Remote DataSource
```

Esto permite cambiar la implementación sin modificar la UI.

---

# 44. Realtime

Cuando sea necesario, utilizar Supabase Realtime.

Pero no convertir Realtime en la única fuente de verdad de la aplicación.

La arquitectura debe ser:

```text
Supabase Realtime
        ↓
Remote Data Source
        ↓
Local Database
        ↓
Reactive Query
        ↓
Riverpod
        ↓
UI
```

La UI debe reaccionar a los cambios locales.

---

# 45. Integridad financiera

Las operaciones financieras son críticas.

No implementar:

```text
crear transacción
actualizar orden
cerrar orden
```

como acciones independientes sin considerar atomicidad.

Cuando corresponda, utiliza:

- transacciones PostgreSQL,
- funciones RPC,
- constraints,
- operaciones idempotentes.

Evalúa cuidadosamente qué operaciones deben realizarse en el backend para garantizar consistencia.

---

# 46. Inventario concurrente

Considera el caso:

```text
Tablet A → vende refresco
Tablet B → vende refresco
```

al mismo tiempo.

El stock no debe terminar en un estado incorrecto.

No confiar solamente en:

```dart
stockActual--;
```

desde Flutter.

Las operaciones críticas de inventario deben estar protegidas por mecanismos transaccionales adecuados.

---

# 47. Auditoría

Para operaciones críticas, considera mecanismos de trazabilidad.

Debe ser posible saber:

- Qué ocurrió.
- Cuándo ocurrió.
- Qué usuario lo realizó.
- Qué dispositivo lo realizó cuando sea relevante.
- Si ocurrió offline.
- Cuándo fue sincronizado.

Especialmente para:

- Pagos.
- Cancelaciones.
- Inventario.
- Cortes de caja.
- Nómina.

---

# 48. Offline y dinero

Las operaciones offline deben diseñarse cuidadosamente.

No asumir que cualquier operación financiera puede simplemente sincronizarse con un:

```text
INSERT
```

posteriormente.

Diseñar identificadores idempotentes y operaciones que puedan reintentarse sin duplicar pagos.

Un retry nunca debe provocar:

```text
Pago duplicado
```

---

# 49. Migraciones

Si es necesario modificar la base de datos:

- Crear migraciones claras.
- No modificar silenciosamente estructuras críticas.
- Documentar cambios.
- Mantener compatibilidad cuando sea necesario.
- Actualizar modelos Flutter.

No asumir que modificar `database.sql` automáticamente modifica el proyecto remoto de Supabase.

---

# 50. Primera tarea del agente

Antes de escribir código funcional, realiza una auditoría inicial.

Debes inspeccionar:

```text
database.sql
design_example/
*.md
pubspec.yaml
lib/
android/
windows/
```

y cualquier otro archivo relevante.

Determina:

1. Estado actual del proyecto.
2. Arquitectura actual.
3. Configuración Flutter.
4. Configuración de plataformas.
5. Esquema de Supabase.
6. RLS.
7. Dependencias.
8. Diseño disponible.
9. Problemas encontrados.
10. Riesgos técnicos.
11. Cambios necesarios.

---

# 51. No implementar todo de golpe

No intentes construir toda la aplicación en una sola operación.

Divide el desarrollo en fases.

Propuesta:

## Fase 0 — Auditoría

- Proyecto.
- Supabase.
- SQL.
- Diseño.
- Dependencias.

## Fase 1 — Arquitectura base

- Carpetas.
- Routing.
- Theme.
- Riverpod.
- Manejo de errores.
- Logging.
- Configuración.

## Fase 2 — Persistencia local

- Drift/Isar.
- Modelos.
- DAOs/queries.
- Migraciones.

## Fase 3 — Supabase

- Auth.
- Repositories.
- Remote datasource.
- RLS.
- Realtime.

## Fase 4 — Offline-first

- Sync queue.
- Connectivity.
- Worker.
- Retry.
- Idempotencia.
- Conflictos.

## Fase 5 — Mesas y órdenes

- Mesas.
- Órdenes.
- Productos.
- Detalles.

## Fase 6 — Pagos

- División.
- Pagos parciales.
- Métodos de pago.
- Transacciones.

## Fase 7 — Inventario

- Stock.
- Alertas.
- Descuentos.

## Fase 8 — Nómina

- Empleados.
- Pagos.
- Historial.

## Fase 9 — QR / Lealtad

- Scanner.
- Cliente.
- Visitas.
- Puntos.

## Fase 10 — Promociones

- CRUD.
- Publicación.
- Imágenes.

## Fase 11 — Caja

- Ventas.
- Reportes.
- Corte.

## Fase 12 — Testing y hardening

- Unit tests.
- Widget tests.
- Integration tests.
- Seguridad.
- Offline.
- Concurrencia.
- Performance.

---

# 52. Regla de oro del desarrollo

Antes de implementar una funcionalidad, responde internamente:

```text
¿Dónde pertenece esta responsabilidad?
```

Si la respuesta es:

```text
en el widget
```

revisa si realmente corresponde ahí.

La UI debe mantenerse lo más declarativa posible.

---

# 53. Regla de consistencia

Mantén consistencia en:

- Nombres.
- Arquitectura.
- Estados.
- Manejo de errores.
- Repositories.
- ViewModels.
- Providers.
- Modelos.
- DTOs.
- Queries.
- Logging.
- Testing.

No crear cinco soluciones diferentes para el mismo problema.

---

# 54. Documentación

Cuando una decisión arquitectónica sea importante, documentarla.

Especialmente:

- Elección de base local.
- Estrategia offline.
- Estrategia de sincronización.
- UUID.
- RLS.
- Roles.
- Manejo de pagos.
- Manejo de inventario concurrente.
- Conflictos.
- Realtime.

Crear documentación cuando realmente aporte valor.

---

# 55. Comunicación durante el desarrollo

Antes de realizar cambios arquitectónicos importantes, explica brevemente:

```text
Problema
Decisión
Motivo
Impacto
```

Después implementa.

No pedir confirmación para decisiones triviales.

Si existe una decisión que puede comprometer:

- seguridad,
- integridad financiera,
- migración irreversible,
- pérdida de datos,

detente y explica el riesgo antes de proceder.

---

# 56. Definition of Done

Una funcionalidad NO se considera terminada solamente porque "funciona".

Debe cumplir:

- Código compilando.
- `flutter analyze` limpio.
- Tests relevantes.
- Manejo de errores.
- Loading state.
- Empty state cuando corresponda.
- Offline state cuando corresponda.
- Seguridad.
- Validaciones.
- Accesibilidad razonable.
- Responsive design.
- Sin duplicación evidente.
- Responsabilidades correctamente separadas.
- Integración con Riverpod.
- Persistencia local cuando corresponda.
- Sincronización cuando corresponda.
- Documentación si la decisión es arquitectónicamente importante.

---

# 57. Prioridad absoluta

Cuando tengas que elegir entre:

```text
hacerlo rápido
```

y:

```text
hacerlo correctamente
```

elige hacerlo correctamente.

Cuando tengas que elegir entre:

```text
UI bonita
```

y:

```text
integridad de datos
```

prioriza integridad.

Cuando tengas que elegir entre:

```text
funciona online
```

y:

```text
funciona correctamente online/offline
```

prioriza la arquitectura offline-first.

Cuando tengas que elegir entre:

```text
solución conveniente
```

y:

```text
solución segura
```

prioriza seguridad.

---

# 58. Objetivo final

El resultado debe ser una aplicación Flutter administrativa profesional para una taquería.

Debe sentirse como un producto real, no como un proyecto de demostración.

Debe ser:

```text
rápida
estable
segura
reactiva
offline-first
mantenible
escalable
testeable
```

La arquitectura debe permitir agregar posteriormente:

- App para clientes.
- Puntos de lealtad.
- Promociones.
- Notificaciones.
- Reportes avanzados.
- Más sucursales.
- Más roles.
- Más dispositivos.

sin tener que reconstruir toda la aplicación desde cero.

---

# 59. Primera acción obligatoria

Tu primera acción en este proyecto debe ser:

> **Auditar el repositorio y proponer la arquitectura inicial antes de implementar funcionalidades.**

Debes revisar específicamente:

```text
database.sql
design_example/
archivos .md de diseño
pubspec.yaml
lib/
android/
windows/
```

Después presenta un resumen de:

```text
1. Estado actual
2. Problemas encontrados
3. Riesgos
4. Dependencias necesarias
5. Arquitectura propuesta
6. Estructura de carpetas propuesta
7. Estrategia de persistencia local
8. Estrategia Offline-First
9. Estrategia de sincronización
10. Consideraciones de Supabase/RLS
11. Plan de implementación por fases
```

**No empieces a construir todas las funcionalidades inmediatamente.**

Primero entiende el proyecto, detecta inconsistencias y establece una base arquitectónica sólida.

A partir de ese momento, implementa el proyecto de forma incremental, verificando cada fase antes de continuar.