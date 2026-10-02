# Brief de Diseño UI/UX: App Administrativa Taquería

## 1. Concepto y Estilo Visual
- **Vibe General:** Minimalista, funcional y limpio. La aplicación debe sentirse como una herramienta de trabajo ágil, pero con una estética cálida y apetitosa que refleje la esencia de un restaurante.
- **Formas y Geometría:** Esquinas redondeadas suaves (radios de 16px a 24px) para tarjetas y botones. 
- **Profundidad:** Uso de sombras sutiles (drop shadows) en el modo claro para dar volumen a los contenedores, y tarjetas con bordes tenues (strokes) en el modo oscuro para mantener la limpieza visual.

---

## 2. Paleta de Colores
Aplicar la regla de proporción 60-30-10 (60% fondo, 30% superficies, 10% acentos) para evitar saturación visual, tomando inspiración de los colores físicos del local.

### ☀️ Modo Claro (Fresco y de día)
- **Fondo Principal (60%):** Blanco roto o un Salmón pastel muy tenue (casi crema).
- **Superficies / Tarjetas (30%):** Blanco puro (#FFFFFF) para máxima legibilidad.
- **Texto Principal:** Azul Marino Oscuro (inspirado en la rotulación física).
- **Acentos y Botones Activos (10%):** Rojo Lona o Amarillo Cálido.

### 🌙 Modo Oscuro (Elegante y nocturno)
- **Fondo Principal (60%):** Azul Medianoche muy oscuro (casi negro) o Gris Carbón.
- **Superficies / Tarjetas (30%):** Azul grisáceo ligeramente más claro que el fondo para crear contraste.
- **Texto Principal:** Blanco ahumado o Gris claro.
- **Acentos y Botones Activos (10%):** Salmón vibrante o Amarillo (para resaltar fuertemente sobre los fondos oscuros).

---

## 3. Estructura Base y Navegación

### Top Bar (Cabecera)
- **Diseño limpio:** Solo debe mostrar el nombre del empleado activo y la fecha actual.
- **Acciones:** Un ícono de engrane (⚙️) en la esquina superior derecha para indexar el resto de opciones (Configuraciones, Gráficas de ventas, Cierre de caja, etc.).

### Bottom Navigation Bar (Barra Inferior)
- **Estilo:** Flotante, tipo "píldora" (separada por unos píxeles del borde inferior y los laterales de la pantalla), con fondo sólido o ligeramente translúcido.
- **Distribución de Íconos (5 Pestañas):**
  1. **Mesas/Pedidos:** Ícono de una mesa o campana de servicio.
  2. **Menú/Inventario:** Ícono de lista o caja de insumos.
  3. **Escáner QR (Botón Central):** Ícono de código QR. Debe ser ligeramente más grande, sobresalir del borde superior de la píldora, o tener un fondo circular de color de acento (Amarillo o Salmón) para destacar como la acción principal hacia el cliente.
  4. **Nómina/Empleados:** Ícono de usuarios o gafete.
  5. **Promociones:** Ícono de estrella o etiqueta de descuento.

---

## 4. Desglose de Pantallas Clave

- **Pantalla 1 (Mesas - Inicio):** 
  - Layout en formato Grid (cuadrícula) con tarjetas cuadradas que representan las mesas. 
  - Las mesas ocupadas deben tener un borde o indicador de acento (ej. Rojo); las libres deben verse neutrales (Grises o Salmón tenue).

- **Pantalla 2 (Menú e Inventario):** 
  - Layout de lista vertical. 
  - Cada ítem debe incluir: Foto pequeña a la izquierda, nombre del producto, y una barra de progreso visual que indique el stock actual (verde si está lleno, amarillo/rojo si es stock mínimo).

- **Pantalla 3 (Escáner QR - Lealtad):** 
  - El 70% del espacio superior actúa como visor de la cámara. 
  - En el tercio inferior, una tarjeta blanca flotante con la información del cliente escaneado y un botón grande para "Ingresar código manual".

- **Pantalla 4 y 5 (Gestión de Empleados y Promociones):** 
  - Layout de listas limpias estilo directorio. 
  - Incorporar un Botón Flotante de Acción (FAB) en la esquina inferior derecha para agregar nuevas entradas ("Nuevo Empleado" o "Nueva Promo").