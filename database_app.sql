-- =====================================================================================
-- database_app.sql — Exquisssita Manager
-- Versión 2 — Esquema corregido y compatible con arquitectura Offline-First
-- 
-- INSTRUCCIONES: Ejecutar este script completo en Supabase SQL Editor.
-- Elimina las tablas anteriores (si existen) y las recrea con la arquitectura correcta.
-- =====================================================================================

-- =====================================================================================
-- 0. LIMPIEZA (eliminar tablas existentes en orden correcto por FK)
-- =====================================================================================

DROP TABLE IF EXISTS historial_pagos_empleados CASCADE;
DROP TABLE IF EXISTS venta_diaria CASCADE;
DROP TABLE IF EXISTS transacciones CASCADE;
DROP TABLE IF EXISTS detalle_orden CASCADE;
DROP TABLE IF EXISTS ordenes CASCADE;
DROP TABLE IF EXISTS promociones CASCADE;
DROP TABLE IF EXISTS mesas CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS empleados CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;

-- Eliminar funciones RPC si existen
DROP FUNCTION IF EXISTS decrementar_stock(UUID, INTEGER);
DROP FUNCTION IF EXISTS realizar_corte_caja(DATE);
DROP FUNCTION IF EXISTS registrar_visita_cliente(UUID);

-- =====================================================================================
-- 1. EXTENSIONES NECESARIAS
-- =====================================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- Para uuid_generate_v4() como default

-- =====================================================================================
-- 2. FUNCIÓN UTILITARIA: Actualizar updated_at automáticamente
-- =====================================================================================

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================================
-- 3. CREACIÓN DE TABLAS
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- 3.1 CLIENTES
-- Vinculado a auth.users. Un cliente puede existir sin cuenta de app (visita física).
-- UUID generado en cliente Flutter y sincronizado.
-- -------------------------------------------------------------------------------------

CREATE TABLE clientes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Nullable: cliente sin cuenta
    nombre          TEXT NOT NULL,
    telefono        TEXT UNIQUE,
    visitas_totales INTEGER DEFAULT 0 CHECK (visitas_totales >= 0),
    puntos_lealtad  INTEGER DEFAULT 0 CHECK (puntos_lealtad >= 0),
    fecha_registro  TIMESTAMPTZ DEFAULT NOW(),
    created_at      TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_clientes_user_id ON clientes(user_id);
CREATE INDEX idx_clientes_telefono ON clientes(telefono);

CREATE TRIGGER set_updated_at_clientes
  BEFORE UPDATE ON clientes
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- -------------------------------------------------------------------------------------
-- 3.2 EMPLEADOS
-- UUID para soporte offline-first. Vinculación opcional con auth.users.
-- -------------------------------------------------------------------------------------

CREATE TABLE empleados (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL, -- Nullable: no todos usan la app
    nombre      TEXT NOT NULL,
    apellido    TEXT NOT NULL,
    telefono    TEXT,
    salario     BIGINT NOT NULL CHECK (salario > 0), -- Almacenado en centavos
    dia_pago    INTEGER NOT NULL CHECK (dia_pago BETWEEN 1 AND 31),
    activo      BOOLEAN DEFAULT TRUE NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at  TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_empleados_user_id ON empleados(user_id);
CREATE INDEX idx_empleados_dia_pago ON empleados(dia_pago);

CREATE TRIGGER set_updated_at_empleados
  BEFORE UPDATE ON empleados
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- -------------------------------------------------------------------------------------
-- 3.3 PRODUCTOS
-- UUID para soporte offline-first.
-- precio almacenado en centavos (INTEGER) para evitar errores de floating-point.
-- -------------------------------------------------------------------------------------

CREATE TABLE productos (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre              TEXT NOT NULL,
    precio              BIGINT NOT NULL CHECK (precio >= 0),  -- Centavos
    categoria           TEXT NOT NULL,
    controla_inventario BOOLEAN DEFAULT FALSE NOT NULL,
    stock_actual        INTEGER DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo        INTEGER DEFAULT 0 CHECK (stock_minimo >= 0),
    activo              BOOLEAN DEFAULT TRUE NOT NULL,
    created_at          TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at          TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_productos_categoria ON productos(categoria);
CREATE INDEX idx_productos_activo ON productos(activo);

CREATE TRIGGER set_updated_at_productos
  BEFORE UPDATE ON productos
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- -------------------------------------------------------------------------------------
-- 3.4 MESAS
-- UUID para soporte offline-first. CHECK constraint en estado.
-- -------------------------------------------------------------------------------------

CREATE TABLE mesas (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    numero_mesa TEXT NOT NULL UNIQUE,
    estado      TEXT NOT NULL DEFAULT 'Libre'
                  CHECK (estado IN ('Libre', 'Ocupada', 'Reservada')),
    created_at  TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at  TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TRIGGER set_updated_at_mesas
  BEFORE UPDATE ON mesas
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- -------------------------------------------------------------------------------------
-- 3.5 PROMOCIONES
-- UUID para soporte offline-first.
-- -------------------------------------------------------------------------------------

CREATE TABLE promociones (
    id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titulo             TEXT NOT NULL,
    descripcion        TEXT NOT NULL,
    imagen_url         TEXT,
    fecha_publicacion  TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_vencimiento  DATE,
    activo             BOOLEAN DEFAULT TRUE NOT NULL,
    created_at         TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at         TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_promociones_activo ON promociones(activo);
CREATE INDEX idx_promociones_fecha_vencimiento ON promociones(fecha_vencimiento);

CREATE TRIGGER set_updated_at_promociones
  BEFORE UPDATE ON promociones
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- -------------------------------------------------------------------------------------
-- 3.6 ÓRDENES
-- UUID generado offline en Flutter. fecha_cierre nullable (se llena al cerrar).
-- tipo_servicio y estado con CHECK constraints.
-- -------------------------------------------------------------------------------------

CREATE TABLE ordenes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mesa_id         UUID REFERENCES mesas(id) ON DELETE RESTRICT,
    cliente_id      UUID REFERENCES clientes(id) ON DELETE SET NULL,
    tipo_servicio   TEXT NOT NULL
                      CHECK (tipo_servicio IN ('Mesa', 'Para llevar', 'Domicilio')),
    estado          TEXT NOT NULL DEFAULT 'Abierta'
                      CHECK (estado IN ('Abierta', 'Cerrada', 'Cancelada')),
    fecha_apertura  TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    fecha_cierre    TIMESTAMPTZ,  -- NULL mientras está abierta
    notas           TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_ordenes_mesa_id ON ordenes(mesa_id);
CREATE INDEX idx_ordenes_cliente_id ON ordenes(cliente_id);
CREATE INDEX idx_ordenes_estado ON ordenes(estado);
CREATE INDEX idx_ordenes_fecha_apertura ON ordenes(fecha_apertura);

CREATE TRIGGER set_updated_at_ordenes
  BEFORE UPDATE ON ordenes
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- -------------------------------------------------------------------------------------
-- 3.7 DETALLE DE ORDEN
-- UUID para soporte offline-first. precio_unitario en centavos.
-- estado_pago con CHECK constraint.
-- -------------------------------------------------------------------------------------

CREATE TABLE detalle_orden (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    orden_id        UUID NOT NULL REFERENCES ordenes(id) ON DELETE CASCADE,
    producto_id     UUID NOT NULL REFERENCES productos(id) ON DELETE RESTRICT,
    cantidad        INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario BIGINT NOT NULL CHECK (precio_unitario >= 0),  -- Centavos, snapshot al momento del pedido
    estado_pago     TEXT NOT NULL DEFAULT 'Pendiente'
                      CHECK (estado_pago IN ('Pendiente', 'Pagado', 'Cancelado')),
    notas           TEXT,  -- Modificaciones especiales del ítem
    created_at      TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_detalle_orden_orden_id ON detalle_orden(orden_id);
CREATE INDEX idx_detalle_orden_producto_id ON detalle_orden(producto_id);
CREATE INDEX idx_detalle_orden_estado_pago ON detalle_orden(estado_pago);

CREATE TRIGGER set_updated_at_detalle_orden
  BEFORE UPDATE ON detalle_orden
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- -------------------------------------------------------------------------------------
-- 3.8 TRANSACCIONES
-- UUID para soporte offline-first. monto en centavos.
-- idempotency_key para prevenir duplicados durante sincronización.
-- -------------------------------------------------------------------------------------

CREATE TABLE transacciones (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    orden_id         UUID NOT NULL REFERENCES ordenes(id) ON DELETE RESTRICT,
    monto            BIGINT NOT NULL CHECK (monto > 0),  -- Centavos
    metodo_pago      TEXT NOT NULL
                       CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'Transferencia', 'Otro')),
    fecha            TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    idempotency_key  UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4(),  -- Previene duplicados en sync
    created_at       TIMESTAMPTZ DEFAULT NOW() NOT NULL
    -- No tiene updated_at: las transacciones son inmutables (append-only)
);

CREATE INDEX idx_transacciones_orden_id ON transacciones(orden_id);
CREATE INDEX idx_transacciones_fecha ON transacciones(fecha);
CREATE INDEX idx_transacciones_metodo_pago ON transacciones(metodo_pago);

-- -------------------------------------------------------------------------------------
-- 3.9 VENTA DIARIA (Cortes de caja)
-- Snapshot inmutable del cierre de caja. No es fuente de verdad en tiempo real.
-- Calculado por función RPC al momento del corte.
-- Se mantiene como BIGINT IDENTITY porque es generado solo por el servidor.
-- -------------------------------------------------------------------------------------

CREATE TABLE venta_diaria (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    fecha           DATE NOT NULL UNIQUE,
    total_efectivo  BIGINT DEFAULT 0 NOT NULL,   -- Centavos
    total_tarjeta   BIGINT DEFAULT 0 NOT NULL,   -- Centavos
    total_otro      BIGINT DEFAULT 0 NOT NULL,   -- Centavos (transferencias, etc.)
    total_global    BIGINT NOT NULL,             -- Centavos
    num_ordenes     INTEGER DEFAULT 0 NOT NULL,
    hora_cierre     TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    cerrado_por     UUID REFERENCES empleados(id) ON DELETE SET NULL
);

CREATE INDEX idx_venta_diaria_fecha ON venta_diaria(fecha);

-- -------------------------------------------------------------------------------------
-- 3.10 HISTORIAL DE PAGOS DE EMPLEADOS
-- UUID para soporte offline-first. monto en centavos.
-- -------------------------------------------------------------------------------------

CREATE TABLE historial_pagos_empleados (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    empleado_id UUID NOT NULL REFERENCES empleados(id) ON DELETE RESTRICT,
    monto       BIGINT NOT NULL CHECK (monto > 0),  -- Centavos
    fecha_pago  DATE DEFAULT CURRENT_DATE NOT NULL,
    notas       TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW() NOT NULL
    -- Inmutable: los pagos no se editan, se crean nuevos si hay error
);

CREATE INDEX idx_historial_pagos_empleado_id ON historial_pagos_empleados(empleado_id);
CREATE INDEX idx_historial_pagos_fecha ON historial_pagos_empleados(fecha_pago);

-- =====================================================================================
-- 4. ACTIVACIÓN DE ROW LEVEL SECURITY
-- =====================================================================================

ALTER TABLE clientes                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE empleados                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE mesas                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE promociones               ENABLE ROW LEVEL SECURITY;
ALTER TABLE ordenes                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE detalle_orden             ENABLE ROW LEVEL SECURITY;
ALTER TABLE transacciones             ENABLE ROW LEVEL SECURITY;
ALTER TABLE venta_diaria              ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial_pagos_empleados ENABLE ROW LEVEL SECURITY;

-- =====================================================================================
-- 5. HELPER: Función para verificar rol del usuario autenticado
-- Evita repetir la misma expresión JWT en cada política.
-- =====================================================================================

CREATE OR REPLACE FUNCTION auth_role()
RETURNS TEXT AS $$
  SELECT COALESCE(
    auth.jwt() -> 'user_metadata' ->> 'rol',
    ''
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- =====================================================================================
-- 6. POLÍTICAS RLS
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- 6.1 CLIENTES
-- -------------------------------------------------------------------------------------

-- Clientes autenticados pueden ver y editar su propio perfil
CREATE POLICY "clientes_select_own" ON clientes
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "clientes_update_own" ON clientes
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Staff (admin + empleado) tiene acceso completo
CREATE POLICY "clientes_staff_select" ON clientes
  FOR SELECT USING (auth_role() IN ('admin', 'empleado'));

CREATE POLICY "clientes_staff_insert" ON clientes
  FOR INSERT WITH CHECK (auth_role() IN ('admin', 'empleado'));

CREATE POLICY "clientes_staff_update" ON clientes
  FOR UPDATE USING (auth_role() IN ('admin', 'empleado'));

-- Solo admin puede eliminar clientes
CREATE POLICY "clientes_admin_delete" ON clientes
  FOR DELETE USING (auth_role() = 'admin');

-- -------------------------------------------------------------------------------------
-- 6.2 EMPLEADOS
-- -------------------------------------------------------------------------------------

-- Solo admin puede gestionar empleados
CREATE POLICY "empleados_admin_all" ON empleados
  FOR ALL USING (auth_role() = 'admin');

-- Empleados pueden ver sus propios datos
CREATE POLICY "empleados_select_own" ON empleados
  FOR SELECT USING (auth.uid() = user_id);

-- -------------------------------------------------------------------------------------
-- 6.3 PRODUCTOS
-- NOTA: SELECT es público e intencional (futura app de clientes puede ver el menú sin login).
-- -------------------------------------------------------------------------------------

-- Cualquiera (incluyendo anónimo) puede leer productos activos
CREATE POLICY "productos_public_select" ON productos
  FOR SELECT USING (true);

-- Solo staff puede insertar/modificar productos
CREATE POLICY "productos_staff_insert" ON productos
  FOR INSERT WITH CHECK (auth_role() IN ('admin', 'empleado'));

CREATE POLICY "productos_staff_update" ON productos
  FOR UPDATE USING (auth_role() IN ('admin', 'empleado'));

-- Solo admin puede eliminar (o desactivar) productos
CREATE POLICY "productos_admin_delete" ON productos
  FOR DELETE USING (auth_role() = 'admin');

-- -------------------------------------------------------------------------------------
-- 6.4 MESAS
-- NOTA: SELECT es público e intencional (futura app de clientes puede ver disponibilidad).
-- -------------------------------------------------------------------------------------

CREATE POLICY "mesas_public_select" ON mesas
  FOR SELECT USING (true);

CREATE POLICY "mesas_staff_insert" ON mesas
  FOR INSERT WITH CHECK (auth_role() IN ('admin', 'empleado'));

CREATE POLICY "mesas_staff_update" ON mesas
  FOR UPDATE USING (auth_role() IN ('admin', 'empleado'));

CREATE POLICY "mesas_admin_delete" ON mesas
  FOR DELETE USING (auth_role() = 'admin');

-- -------------------------------------------------------------------------------------
-- 6.5 PROMOCIONES
-- NOTA: SELECT es público e intencional (futura app de clientes).
-- -------------------------------------------------------------------------------------

CREATE POLICY "promociones_public_select" ON promociones
  FOR SELECT USING (true);

CREATE POLICY "promociones_admin_insert" ON promociones
  FOR INSERT WITH CHECK (auth_role() = 'admin');

CREATE POLICY "promociones_admin_update" ON promociones
  FOR UPDATE USING (auth_role() = 'admin');

CREATE POLICY "promociones_admin_delete" ON promociones
  FOR DELETE USING (auth_role() = 'admin');

-- -------------------------------------------------------------------------------------
-- 6.6 ÓRDENES
-- -------------------------------------------------------------------------------------

-- Staff accede a todas las órdenes
CREATE POLICY "ordenes_staff_select" ON ordenes
  FOR SELECT USING (auth_role() IN ('admin', 'empleado'));

CREATE POLICY "ordenes_staff_insert" ON ordenes
  FOR INSERT WITH CHECK (auth_role() IN ('admin', 'empleado'));

CREATE POLICY "ordenes_staff_update" ON ordenes
  FOR UPDATE USING (auth_role() IN ('admin', 'empleado'));

-- Solo admin puede cancelar/eliminar órdenes
CREATE POLICY "ordenes_admin_delete" ON ordenes
  FOR DELETE USING (auth_role() = 'admin');

-- Clientes pueden ver solo sus propias órdenes
CREATE POLICY "ordenes_clientes_select_own" ON ordenes
  FOR SELECT USING (
    cliente_id IN (SELECT id FROM clientes WHERE user_id = auth.uid())
  );

-- -------------------------------------------------------------------------------------
-- 6.7 DETALLE DE ORDEN
-- -------------------------------------------------------------------------------------

CREATE POLICY "detalle_orden_staff_all" ON detalle_orden
  FOR ALL USING (auth_role() IN ('admin', 'empleado'));

-- Clientes ven detalles de sus propias órdenes
CREATE POLICY "detalle_orden_clientes_select_own" ON detalle_orden
  FOR SELECT USING (
    orden_id IN (
      SELECT o.id FROM ordenes o
      INNER JOIN clientes c ON c.id = o.cliente_id
      WHERE c.user_id = auth.uid()
    )
  );

-- -------------------------------------------------------------------------------------
-- 6.8 TRANSACCIONES
-- -------------------------------------------------------------------------------------

CREATE POLICY "transacciones_staff_select" ON transacciones
  FOR SELECT USING (auth_role() IN ('admin', 'empleado'));

CREATE POLICY "transacciones_staff_insert" ON transacciones
  FOR INSERT WITH CHECK (auth_role() IN ('admin', 'empleado'));

-- Las transacciones son inmutables: nadie puede actualizar o eliminar
-- (correcciones se hacen con nuevas transacciones de ajuste)

-- -------------------------------------------------------------------------------------
-- 6.9 VENTA DIARIA
-- -------------------------------------------------------------------------------------

CREATE POLICY "venta_diaria_admin_all" ON venta_diaria
  FOR ALL USING (auth_role() = 'admin');

CREATE POLICY "venta_diaria_empleado_select" ON venta_diaria
  FOR SELECT USING (auth_role() = 'empleado');

-- -------------------------------------------------------------------------------------
-- 6.10 HISTORIAL DE PAGOS DE EMPLEADOS
-- -------------------------------------------------------------------------------------

CREATE POLICY "pagos_empleados_admin_all" ON historial_pagos_empleados
  FOR ALL USING (auth_role() = 'admin');

-- Empleados pueden ver su propio historial de pagos
CREATE POLICY "pagos_empleados_select_own" ON historial_pagos_empleados
  FOR SELECT USING (
    empleado_id IN (SELECT id FROM empleados WHERE user_id = auth.uid())
  );

-- =====================================================================================
-- 7. FUNCIONES RPC — Operaciones atómicas críticas
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- 7.1 Decrementar stock de forma atómica (protección de concurrencia)
-- Uso: SELECT decrementar_stock('uuid-producto', 3);
-- Retorna error si stock insuficiente.
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION decrementar_stock(
  p_producto_id UUID,
  p_cantidad    INTEGER
)
RETURNS VOID AS $$
DECLARE
  v_stock_actual INTEGER;
BEGIN
  -- Lock exclusivo en el registro del producto
  SELECT stock_actual INTO v_stock_actual
  FROM productos
  WHERE id = p_producto_id
  FOR UPDATE;

  IF v_stock_actual IS NULL THEN
    RAISE EXCEPTION 'producto_no_encontrado'
      USING ERRCODE = 'P0001';
  END IF;

  IF v_stock_actual < p_cantidad THEN
    RAISE EXCEPTION 'stock_insuficiente: disponible=%, solicitado=%',
      v_stock_actual, p_cantidad
      USING ERRCODE = 'P0002';
  END IF;

  UPDATE productos
  SET stock_actual = stock_actual - p_cantidad
  WHERE id = p_producto_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- -------------------------------------------------------------------------------------
-- 7.2 Realizar corte de caja
-- Calcula totales del día y registra el snapshot en venta_diaria.
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION realizar_corte_caja(
  p_fecha        DATE,
  p_cerrado_por  UUID
)
RETURNS TABLE (
  total_efectivo BIGINT,
  total_tarjeta  BIGINT,
  total_otro     BIGINT,
  total_global   BIGINT,
  num_ordenes    INTEGER
) AS $$
DECLARE
  v_efectivo  BIGINT;
  v_tarjeta   BIGINT;
  v_otro      BIGINT;
  v_total     BIGINT;
  v_ordenes   INTEGER;
BEGIN
  -- Solo admin puede ejecutar esto (verificado por RLS, pero doble check)
  IF auth_role() != 'admin' THEN
    RAISE EXCEPTION 'permiso_denegado'
      USING ERRCODE = 'P0003';
  END IF;

  -- Ya existe un corte para esta fecha?
  IF EXISTS (SELECT 1 FROM venta_diaria WHERE fecha = p_fecha) THEN
    RAISE EXCEPTION 'corte_ya_existe_para_fecha: %', p_fecha
      USING ERRCODE = 'P0004';
  END IF;

  -- Calcular totales desde transacciones del día
  SELECT
    COALESCE(SUM(CASE WHEN metodo_pago = 'Efectivo' THEN monto ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN metodo_pago = 'Tarjeta'  THEN monto ELSE 0 END), 0),
    COALESCE(SUM(CASE WHEN metodo_pago NOT IN ('Efectivo', 'Tarjeta') THEN monto ELSE 0 END), 0),
    COALESCE(SUM(monto), 0)
  INTO v_efectivo, v_tarjeta, v_otro, v_total
  FROM transacciones
  WHERE DATE(fecha AT TIME ZONE 'America/Mexico_City') = p_fecha;

  -- Contar órdenes cerradas del día
  SELECT COUNT(*)::INTEGER INTO v_ordenes
  FROM ordenes
  WHERE estado = 'Cerrada'
    AND DATE(fecha_cierre AT TIME ZONE 'America/Mexico_City') = p_fecha;

  -- Insertar snapshot
  INSERT INTO venta_diaria (
    fecha, total_efectivo, total_tarjeta, total_otro,
    total_global, num_ordenes, cerrado_por
  )
  VALUES (
    p_fecha, v_efectivo, v_tarjeta, v_otro,
    v_total, v_ordenes, p_cerrado_por
  );

  RETURN QUERY SELECT v_efectivo, v_tarjeta, v_otro, v_total, v_ordenes;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- -------------------------------------------------------------------------------------
-- 7.3 Registrar visita de cliente (lealtad QR)
-- Anti-duplicado: 1 visita máximo por cliente por día.
-- -------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION registrar_visita_cliente(
  p_cliente_id UUID
)
RETURNS JSONB AS $$
DECLARE
  v_cliente clientes%ROWTYPE;
  v_ultima_visita TIMESTAMPTZ;
BEGIN
  -- Obtener cliente con lock
  SELECT * INTO v_cliente
  FROM clientes
  WHERE id = p_cliente_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'cliente_no_encontrado'
      USING ERRCODE = 'P0005';
  END IF;

  -- Verificar que no se haya registrado una visita hoy
  -- (usando updated_at como proxy — en producción podría usarse una tabla separada de visitas)
  IF DATE(v_cliente.updated_at AT TIME ZONE 'America/Mexico_City') = CURRENT_DATE
     AND v_cliente.visitas_totales > 0 THEN
    RAISE EXCEPTION 'visita_ya_registrada_hoy'
      USING ERRCODE = 'P0006';
  END IF;

  -- Incrementar visitas y puntos
  UPDATE clientes
  SET
    visitas_totales = visitas_totales + 1,
    puntos_lealtad  = puntos_lealtad + 10,  -- 10 puntos por visita (configurable)
    updated_at      = NOW()
  WHERE id = p_cliente_id
  RETURNING * INTO v_cliente;

  RETURN jsonb_build_object(
    'visitas_totales', v_cliente.visitas_totales,
    'puntos_lealtad',  v_cliente.puntos_lealtad
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================================================
-- 8. DATOS INICIALES (seed mínimo para arrancar el sistema)
-- =====================================================================================

-- Nota: Los empleados y sus usuarios de auth deben crearse desde la app o desde
-- el dashboard de Supabase Auth. Este seed es solo para mesas iniciales.

-- Mesas ejemplo (ajustar según el local real)
INSERT INTO mesas (numero_mesa, estado) VALUES
  ('1',  'Libre'),
  ('2',  'Libre'),
  ('3',  'Libre'),
  ('4',  'Libre'),
  ('5',  'Libre'),
  ('6',  'Libre'),
  ('7',  'Libre'),
  ('8',  'Libre'),
  ('9',  'Libre'),
  ('10', 'Libre'),
  ('11', 'Libre'),
  ('12', 'Libre');

-- =====================================================================================
-- FIN DEL SCRIPT
-- =====================================================================================
-- Cambios respecto al esquema anterior:
--
-- 1. Todas las tablas de entidades usan UUID v4 como PK (generado en cliente Flutter)
-- 2. Todos los campos monetarios usan BIGINT (centavos) en lugar de NUMERIC(10,2)
-- 3. Agregados CHECK constraints en: mesas.estado, ordenes.estado, ordenes.tipo_servicio,
--    detalle_orden.estado_pago, transacciones.metodo_pago
-- 4. Agregados campos created_at / updated_at en todas las tablas mutables
-- 5. Agregados triggers automáticos de updated_at
-- 6. Agregados índices en todas las columnas FK y columnas frecuentemente filtradas
-- 7. Campo fecha_cierre agregado a ordenes
-- 8. Campo notas agregado a ordenes y detalle_orden
-- 9. Campo idempotency_key en transacciones para prevenir duplicados en sync
-- 10. Función helper auth_role() para simplificar y centralizar RLS
-- 11. Políticas RLS separadas por operación (INSERT/SELECT/UPDATE/DELETE)
-- 12. Políticas diferenciadas admin vs empleado para operaciones sensibles
-- 13. Funciones RPC atómicas: decrementar_stock, realizar_corte_caja, registrar_visita_cliente
-- 14. venta_diaria conserva BIGINT IDENTITY (solo generada por servidor en corte)
-- 15. historial_pagos_empleados migrado a UUID
-- =====================================================================================
