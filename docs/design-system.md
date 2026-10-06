# Sistema visual Exquisssita — evolución incremental

Auditoría y cambios locales: 3 de octubre de 2026.

## Problema, decisión, motivo e impacto

**Problema.** La identidad estaba definida en `DESIGN_PROMPT.md`, `design_example/index.css`, `AppColors` y `AppTextStyles`, pero las pantallas repetían medidas, estilos y colores. La navegación y ajustes usaban gestos sin acceso por teclado, controles de 36×36 y emoji funcionales. Los subtítulos con alpha y ciertos pares originales no alcanzaban contraste AA. Algunas pantallas interpolaban excepciones técnicas en mensajes visibles.

**Decisión.** Montar `ExquisssitaTokens` en `ThemeData.extensions`, con un único accessor `context.exq`, y migrar las superficies existentes a componentes propios. Se mantienen las rutas, Riverpod, repositorios, Drift, autorización y funciones de negocio. Se reemplaza el chrome de los controles; no se construyen nuevos módulos de negocio ni se introduce un kit de UI.

**Motivo.** Las mismas decisiones de color, tipografía, medidas, foco y motion deben aplicarse en cada pantalla y poder probarse de forma aislada. Se preserva la paleta exacta y las fuentes bundleadas; los problemas de contraste se resuelven cambiando el uso de los colores y el tamaño de la etiqueta primaria.

**Impacto.** Cambian la presentación de login, shell, ajustes, promociones, QR, caja y revisión de operaciones críticas. La navegación conserva las cinco áreas y el QR central. Los mensajes de error pasan a texto de presentación seguro. Los botones de guardar y cerrar caja se deshabilitan durante su operación; el estado de caja usa un día normalizado para conservar estable su suscripción local. No hay cambios de esquema, RLS, permisos ni despliegues remotos en esta fase.

## Auditoría del material existente

| Fuente | Hallazgo | Tratamiento |
|---|---|---|
| `DESIGN_PROMPT.md` | Outfit/Fraunces, crema/salmón, azul y amarillo; temas claro/oscuro y pill de cinco destinos | Conservados |
| `design_example/index.css` | Valores originales de color y radio base 18 | Referencia de identidad; no se modifica ni se genera una paleta nueva |
| `design_example/app.tsx` | Mockup con emoji, controles pequeños y scale al pulsar | Se adapta a Flutter con iconos outlined, targets de 48 y feedback inmediato |
| `app_colors.dart` | Paleta exacta; algunos pares de texto secundarios fallaban AA | Permanece como fuente de primitivas, consumida por tokens/tema |
| `app_text_styles.dart` | Tipografía correcta, fuentes disponibles offline | Se conserva y se agrega `accessibleAction` de 20 px/700 |
| `app_theme.dart` | Configuración Material existente sin extensión y con tipografía repetida | Monta la extensión, usa su TextTheme y métricas, aplica `NoSplash`; añade alto contraste |
| `main_shell.dart` | Gestos, 36×36, emoji y altura fija de navegación | Pressable, iconos, foco y altura según contenido; sigue el mismo routing |
| Pantallas existentes | Mezcla de botones/list tiles, valores sueltos, errores técnicos y posibles recortes | Se migran sus controles a componentes compartidos y contenido que puede crecer/desplazarse |

Salón, menú/inventario y empleados siguen siendo placeholders del proyecto. Esta evolución visual no presenta funcionalidades inexistentes como si estuvieran implementadas.

## Tokens y uso

`lib/app/theme/exquisssita_tokens.dart` contiene la extensión, las métricas y el accessor. `AppColors` y `AppTextStyles` conservan las primitivas originales; no deben importarse en widgets. Los aliases existentes de `AppTheme` se conservan como compatibilidad, pero los widgets migrados leen `context.exq`.

```dart
final t = context.exq;
final m = t.metrics;
Text('Total pendiente', style: t.label);
SizedBox(height: m.spaceL);
ExquisssitaAction(label: 'Guardar', onPressed: save);
```

| Grupo | Tokens principales |
|---|---|
| Color | background, foreground, card, primary/onPrimary, secondary, muted, accent/onAccent, border, focus, actionBackground/actionForeground, shadow, scrim |
| Tipografía | text, heading, body, label, caption, button, currency, currencySmall |
| Espaciado | 2, 4, 8, 12, 16, 20, 24; section 48 |
| Radios | card 18, button 14, chip 24, nav 28, sheet 24, small 12 |
| Elevación | card 2, nav 8, FAB 6; sombras derivadas de estos tokens |
| Medidas | target 48, icon 18/22/32, QR 56, logo 64, contentMax 640, dialogMax 560 |
| Motion | press 90 ms, release 150 ms, transition 200 ms, easeOutCubic, pressedScale .98 |

Los colores y TextTheme implementan `copyWith`/`lerp`. Las métricas comunes permanecen iguales en ambos temas. No hay `ColorScheme.fromSeed`, fuentes descargadas ni dependencia visual nueva.

## Contraste sin cambiar la paleta

| Par original / uso | Ratio | Decisión |
|---|---:|---|
| Blanco / rojo `#D94F3D` | 4,09:1 | Etiqueta primaria Outfit 20 px/700: cumple el umbral de 3:1 para texto grande; no usar este par para texto pequeño |
| Azul `#1A2744` / salmón oscuro `#E8715A` | 4,90:1 | Etiqueta e icono primarios del tema oscuro |
| Gris `#6B7A99` / blanco | 4,31:1 | No usar para etiquetas pequeñas de lectura |
| Gris `#6B7A99` / crema `#FDF5EF` | 4,00:1 | Se usa foreground para fechas, subtítulos y estados |
| Azul / crema | 13,74:1 | Lectura en claro |
| Humo `#E8E4DF` / tarjeta oscura `#1A2337` | 12,39:1 | Lectura en oscuro |
| Azul / amarillo `#F5A623` | 7,31:1 | Iconos sobre amarillo |

Las variantes de alto contraste usan únicamente colores de la misma identidad: acción con foreground/card y bordes fuertes. El estado se expresa con texto e icono, no solamente con color. La opacidad de controles deshabilitados comunica su estado; estos no ofrecen activación.

## Interacción y accesibilidad

`ExquisssitaPressable` es la única implementación de gestos propia. Integra `FocusableActionDetector`, Tab, Enter/Espacio sin auto-repeat, foco visible y un nodo semántico con nombre, rol, selección, habilitación y foco. La región táctil es de al menos 48×48 y permanece estable aunque el contenido pintado escale. La pulsación tiene feedback de opacidad desde pointer-down; cancelar o empezar a desplazar la lista no ejecuta la acción. La animación puede cambiar de dirección sin bloquear el input.

Reduced motion contempla Android Remove animations, navegación asistida y el flag específico iOS Reduce Motion. Se desactiva escala y transición de hojas/modales; permanece el feedback de opacidad. El cambio de tema de la app también desactiva su transición cuando el sistema lo solicita. El skeleton es estático, sin animación repetitiva.

Los campos conservan el comportamiento nativo de edición/validación, con label asociado. Los controles de contraseña tienen nombre y tooltip. Los iconos ornamentales se excluyen de semántica. Las rutas modales de Flutter aíslan los nodos detrás de la hoja; esto se comprueba sobre el árbol semántico real. El texto mantiene `TextScaler` del sistema sin límites impuestos por la app. La navegación crece verticalmente y los importes de caja pueden reorganizarse en lugar de recortarse.

## Componentes reutilizables

En `lib/shared/widgets/exquisssita_components.dart`:

| Componente | Responsabilidad |
|---|---|
| ExquisssitaAction | Acción primaria o secundaria; disabled/busy |
| ExquisssitaIconAction | Acción de icono con etiqueta y tooltip |
| ExquisssitaSurface | Tarjeta, borde, radio, sombra y padding |
| ExquisssitaPageHeader | Título semántico, subtítulo y acción |
| ExquisssitaStatusBadge | Estado con icono y texto que puede crecer |
| ExquisssitaEmptyState / ErrorState | Vacío y error de presentación; retry opcional y live region de error |
| ExquisssitaSkeleton | Estado de carga semántico, sin motion repetitivo |
| ExquisssitaFormField | Campo con labels/validación y estilo de marca |
| ExquisssitaModal / Sheet | Contenido adaptable y scroll; helpers de apertura con motion/scrim de tokens |
| ExquisssitaSyncStatus | Estado de conexión y contadores, acción hacia revisión local |

`SyncStatusBanner` sigue obteniendo sus datos del motor de sincronización. La hoja conserva los estados y las acciones auditables de pagos/inventario. No muestra payloads, tokens ni excepciones internas.

El banner montado desde `MaterialApp.builder` abre la hoja usando la clave del Navigator de GoRouter: su contexto original está por encima del Navigator. Una prueba específica monta ese mismo layout y comprueba la apertura de revisión local.

## Galería y verificación

En una compilación **debug**, iniciar sesión y abrir **Más opciones → Galería Exquisssita**. Incluye temas claro/oscuro, alto contraste, acciones, estados, formulario, importes, skeleton, modal y hoja. La ruta no se registra en release y conserva el guard de autenticación.

Capturas renderizadas con Outfit/Fraunces e iconos bundleados:

- [Tema claro](visual/gallery-light.png)
- [Tema oscuro](visual/gallery-dark.png)

Pruebas:

```sh
flutter test test/design
flutter test
flutter analyze --no-pub
flutter build bundle --debug --no-pub
# Regenerar capturas locales; no contacta Supabase:
flutter test test/design/design_system_test.dart --dart-define=CAPTURE_DESIGN=true
```

La batería visual comprueba los cuatro guidelines de Flutter (Android/iOS tap target, labels y contraste), pares de tokens, fuentes/identidad, foco y activación de teclado, disabled/cancel, flags reduced motion, modales y hojas con texto 200–300 % a 320 px. Las pantallas de login, promociones/editor, caja/historial y shell se prueban con 100/200/300 %. La galería mantiene el guard de Auth; sus pruebas y capturas usan fixtures locales, sin backend.

Resultado: suite completa de 77 pruebas aprobadas, `flutter analyze --no-pub` sin incidencias y bundle debug compilado. Las capturas se inspeccionaron en claro y oscuro.

La verificación de hardware de cámara, TalkBack y lector de pantalla de Windows necesita dispositivos/ejecución nativa y no se sustituye por las pruebas de semántica. El build nativo de Windows tiene la limitación previa de enlaces simbólicos/Developer Mode del entorno; el bundle verifica compilación Dart y assets.

Referencias verificadas: [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html) y [pruebas de accesibilidad de Flutter](https://docs.flutter.dev/ui/accessibility/accessibility-testing).
