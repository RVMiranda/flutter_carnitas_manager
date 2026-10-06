# Auditoría y endurecimiento Android / Windows

Fecha: 2026-10-03. Alcance: configuración, compatibilidad y pruebas de lo existente. No se implementan flujos POS nuevos ni se modifica Supabase remoto.

## Bloqueo de flutter test

Se reprodujo `flutter test --no-pub --timeout=45s --reporter=expanded` sin salida dentro del entorno restringido. Su wrapper `bin/internal/shared.bat` reintenta indefinidamente abrir `bin/cache/flutter.bat.lock`, ocultando stderr (`2>NUL`). La caché está fuera del workspace escribible. La misma suite ejecutada con permisos sobre el SDK, tanto por `flutter test` como por el Dart y snapshot instalados, terminó. Esto identifica el arranque del SDK como causa del bloqueo reproducido; un archivo lock existente por sí solo no demuestra que esté retenido.

Procesos identificados por CIM antes de actuar:

| PID observado | Propósito | Acción |
| --- | --- | --- |
| 11096 / 23008 | Wrapper y daemon de Flutter iniciado por VS Code | Conservados |
| 4456 / 4764 | PowerShell / wrapper anterior: `flutter test test/payroll_rules_test.dart` | Conservados; no son invocaciones iniciadas por esta auditoría |
| 3100 / 4072 | PowerShell / wrapper de la reproducción de esta auditoría | Interrumpida su sesión propia; ambos ya no aparecen |

Los PID son evidencia histórica y pueden reutilizarse: nunca usar esta tabla para terminar un proceso futuro. No se usó `taskkill`, borrado de locks ni terminación general de Dart/Java.

Ejecución reproducible:

```powershell
flutter pub get
flutter analyze --no-pub
flutter test --no-pub --reporter=expanded --concurrency=2 --timeout=45s
# Alternativa para un SDK ya inicializado y cuando el wrapper queda sin salida:
./scripts/test.ps1
```

El script utiliza el Dart y snapshot de la misma instalación, sin descargar ni modificar el SDK. También necesita permisos suficientes para telemetry/caché del SDK; no evita controles del entorno. `--timeout` limita las pruebas, no el arranque del wrapper. En widgets con Drift se crea/consulta la base bajo `tester.runAsync`, se acotan los `pumpAndSettle` y se libera el árbol y suscripciones antes de `db.close()`: se reprodujo una espera en ese cierre y se corrigió en la prueba nueva.

## Android

**Problema:** Activity legado, etiqueta plantilla y release firmado con debug.
**Decisión:** conservar el namespace `com.mirandadevsource.exquisssita`, eliminar exclusivamente el Activity `com.example.flutter_carnitas`, y exigir firma externa.
**Motivo:** el manifiesto `.MainActivity`, namespace y applicationId apuntan al paquete actual; no hay sabores ni referencias al Activity legado. Debug no es una identidad de publicación válida.
**Impacto:** debug conserva la firma estándar de desarrollo; tareas release fallan explícitamente sin secretos. No se generó ni cambió ninguna clave de publicación.

Firma: crear fuera del checkout un archivo privado (ejemplo `C:/Users/<usuario>/.config/exquisssita/signing.properties`) con estas claves, sin versionar valores reales:

```properties
storeFile=C:/Users/<usuario>/.config/exquisssita/upload-keystore.jks
storePassword=<secreto>
keyAlias=<alias-de-la-clave>
keyPassword=<secreto>
```

Definir `EXQUISSSITA_SIGNING_PROPERTIES` con la ruta absoluta de ese archivo, solamente en el proceso de build o mediante secretos de CI. Ambas rutas se resuelven canónicamente y se rechazan dentro del repositorio; se requieren todos los campos. No imprimir archivos, variables ni passwords. Respaldar la clave y restringir su ACL al usuario de build. CI debe montar archivos fuera del checkout. Usar el procedimiento oficial de [firma Android de Flutter](https://docs.flutter.dev/deployment/android#sign-the-app). No sustituir la clave de una aplicación ya publicada sin revisar su identidad de firma/Play App Signing.

El manifiesto principal declara `INTERNET`, `CAMERA` y cámara opcional (`required=false`), por lo que dispositivos sin cámara no quedan excluidos del POS. La cámara requiere consentimiento en runtime, gestionado por el plugin. No se añadieron permisos de almacenamiento, audio o ubicación.

`mobile_scanner` resuelto: **7.4.0**. Su código Android declara minSdk 23 y compileSdk 36. El modelo ML Kit permanece **incluido** por defecto; no se activa el modelo descargable, preservando la lectura sin Internet. Registrar una visita sigue necesitando las condiciones del repositorio de lealtad; leer un QR offline no garantiza que el registro remoto pueda completarse.

El lector pausa al salir de la app, reanuda cuando corresponde, evita detecciones paralelas durante un registro y presenta mensajes seguros de permiso denegado/cámara no disponible. No muestra el QR crudo ni errores nativos. Comprobación física pendiente: permiso concedido, denegado, denegado permanentemente, regreso desde ajustes, cambio de aplicación, cámara ausente, QR repetido y lectura sin Internet. No hay Android conectado en `flutter devices`.

## Windows

Producto/título: **Exquisssita Manager**. Compañía: **Exquisssita**, tomando la marca existente como nombre de metadatos (no certificación de una razón social). Descripción: **Sistema administrativo Exquisssita**. Ejecutable e InternalName: **exquisssita_manager.exe / exquisssita_manager**. Se elimina `flutter_carnitas` de CMake, ventana y recursos.

El icono de plantilla se sustituye por un monograma **E** con Fraunces SemiBold, salmón `#FBE9DF`, azul `#1A2744` y amarillo `#F5A623`, derivados de los assets/tokens existentes. ICO incluye 16, 32, 48, 64, 128 y 256 px. Regenerar en Windows con `./scripts/generate-windows-icon.ps1`. Se inspeccionó su imagen; recursos incrustados y metadatos del ejecutable quedan pendientes del build nativo.

`mobile_scanner` [no soporta Windows](https://pub.dev/packages/mobile_scanner/versions/7.4.0). El lector muestra una alternativa explícita y no crea controlador ni cámara nativa: **registrar la visita en Android**. No se implementan entrada manual, lector USB ni otro plugin. Un lector USB que emula teclado necesita un flujo validado específico futuro; no se considera soportado hoy.

## Cobertura y límites reales

| Flujo solicitado | Prueba disponible | Límite |
| --- | --- | --- |
| Login | Widget compartido con integration_test: validación, envío exitoso, bloqueo de duplicados; repositorio Auth sustituible | Auth remoto y guards de sesión reales no se verifican |
| Crear orden offline | Widget compartido: tap en mesa, navegación, orden y outbox reales en Drift | Fixture local aislado; sin Supabase |
| Agregar producto | `orders_test.dart`, incluido en entrypoint nativo de repositorios | Pantalla de detalle no tiene acción para agregar productos |
| Cobrar | `test/integration/sync_engine_test.dart`: intención pendiente, recibo remoto, reconciliación sin duplicación | Remote determinista; no hay pantalla de cobro operativa |
| Cerrar orden | `order_close_reconciliation_test.dart`: pull de estado remoto Cerrada, exclusión de abiertas y avance de cursor | No existe acción local de cierre en OrdersRepository/UI; no se inventó un cierre local |
| Operar offline / reconectar / sincronizar | Suite de motor: outbox offline, reconexión, retry, procesamiento recuperado, duplicados, errores permanentes y pull incremental | No sustituye pruebas de conectividad física de Android/Windows |
| QR Windows | Widget: mensaje alternativo y ausencia de MobileScanner | Cámara Android queda pendiente de dispositivo |

Los entrypoints en `integration_test/` usan [IntegrationTestWidgetsFlutterBinding](https://docs.flutter.dev/testing/integration-tests), sin habilitar Flutter Driver en producción. `platform_flows_test.dart` prueba widgets reales con Drift/Auth controlados; `engine_scenarios_test.dart` reutiliza las pruebas de repositorios y motor. No son un recorrido POS completo ni certificación del backend.

```powershell
flutter test integration_test/platform_flows_test.dart -d windows --no-pub
flutter test integration_test/engine_scenarios_test.dart -d windows --no-pub
# Con un Android identificado en flutter devices:
flutter test integration_test/platform_flows_test.dart -d <device-id> --no-pub
flutter test integration_test/engine_scenarios_test.dart -d <device-id> --no-pub
flutter build apk --debug --no-pub
flutter build windows --debug --no-pub
```

## Verificación del entorno

- `flutter analyze --no-pub`: **sin incidencias**.
- `flutter test --no-pub --timeout=45s --reporter=expanded --concurrency=2`: **91 pruebas aprobadas**, exit code 0, aproximadamente 11 segundos. Log local en `build/verification/flutter-test.log`. Los entrypoints nativos requieren dispositivo/build por separado.
- `./scripts/test.ps1`: **91 pruebas aprobadas**, exit code 0; log local en `build/verification/script-test.log`.
- `flutter pub get`: resolvió integration_test del SDK y actualizó el lockfile, pero finalizó con error al crear enlaces de plugins Windows. No se actualizó mobile_scanner ni otro paquete existente intencionalmente.
- Windows debug e integration_test Windows: bloqueados por **symlink support / Developer Mode**. No se alteró la configuración de Windows ni se elevó automáticamente a administrador.
- Android debug: bloqueado antes de configurar el proyecto por **Java IOException: Unable to establish loopback connection**, causado por `UnixDomainSockets.connect` → `SocketException: Invalid argument: connect`, con JBR **25.0.2** y Gradle **9.1.0**. Se reprodujo con flutter build y gradlew --no-daemon --stacktrace. Un selector alternativo solo en el comando tampoco resolvió el fallo; no se incorporó ese experimento a Gradle. No atribuirlo al código Android sin evidencia.
- Configuración de firma release: revisada estáticamente; validación Gradle, APK firmado y certificado final **no ejecutables por el bloqueo anterior**. No hay secretos de firma configurados en esta auditoría.

Para completar la validación nativa se necesita una máquina con enlaces simbólicos habilitados, un JDK/entorno Gradle funcional y Android conectado. Ningún build nativo se declara aprobado mientras esos comandos no terminen correctamente.
