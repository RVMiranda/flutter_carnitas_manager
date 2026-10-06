> Actualización 2026-10-03: [reconciliación de operaciones críticas](critical-operations.md) describe la migración incremental 20261003070556, Drift v6, sync_execute_v2 y las sustituciones de RPC/ACL. Sus decisiones y verificaciones posteriores complementan y sustituyen los comportamientos anteriores de pagos e inventario descritos aquí. Ninguna migración se aplicó al servidor remoto.

# Inventario derivado de las migraciones
No ejecutar este documento. Autoridad: supabase/migrations. DDL en orden; cuerpos de función anteriores quedan sustituidos por CREATE OR REPLACE posterior y ALTER FUNCTION modifica su configuración. Grants/revokes se interpretan acumulativamente. No incluye ACL heredadas externas.
## 20261002204457_remote_baseline.sql
```sql
SET local check_function_bodies = off;

CREATE TABLE "public"."clientes" (
  "id"              uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "user_id"         uuid,
  "nombre"          text                     NOT NULL,
  "telefono"        text,
  "visitas_totales" integer                  DEFAULT 0,
  "puntos_lealtad"  integer                  DEFAULT 0,
  "fecha_registro"  timestamp with time zone DEFAULT now(),
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "clientes_pkey" PRIMARY KEY (id),
  CONSTRAINT "clientes_puntos_lealtad_check" CHECK ((puntos_lealtad >= 0)),
  CONSTRAINT "clientes_telefono_key" UNIQUE (telefono),
  CONSTRAINT "clientes_visitas_totales_check" CHECK ((visitas_totales >= 0))
);

ALTER TABLE "public"."clientes"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."detalle_orden" (
  "id"              uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "orden_id"        uuid                     NOT NULL,
  "producto_id"     uuid                     NOT NULL,
  "cantidad"        integer                  NOT NULL,
  "precio_unitario" bigint                   NOT NULL,
  "estado_pago"     text                     NOT NULL DEFAULT 'Pendiente'::text,
  "notas"           text,
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "detalle_orden_cantidad_check" CHECK ((cantidad > 0)),
  CONSTRAINT "detalle_orden_estado_pago_check" CHECK ((estado_pago = ANY (ARRAY['Pendiente'::text, 'Pagado'::text, 'Cancelado'::text]))),
  CONSTRAINT "detalle_orden_pkey" PRIMARY KEY (id),
  CONSTRAINT "detalle_orden_precio_unitario_check" CHECK ((precio_unitario >= 0))
);

ALTER TABLE "public"."detalle_orden"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."empleados" (
  "id"         uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "user_id"    uuid,
  "nombre"     text                     NOT NULL,
  "apellido"   text                     NOT NULL,
  "telefono"   text,
  "salario"    bigint                   NOT NULL,
  "dia_pago"   integer                  NOT NULL,
  "activo"     boolean                  NOT NULL DEFAULT true,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "empleados_dia_pago_check" CHECK (((dia_pago >= 1) AND (dia_pago <= 31))),
  CONSTRAINT "empleados_pkey" PRIMARY KEY (id),
  CONSTRAINT "empleados_salario_check" CHECK ((salario > 0))
);

ALTER TABLE "public"."empleados"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."historial_pagos_empleados" (
  "id"          uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "empleado_id" uuid                     NOT NULL,
  "monto"       bigint                   NOT NULL,
  "fecha_pago"  date                     NOT NULL DEFAULT CURRENT_DATE,
  "notas"       text,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "historial_pagos_empleados_monto_check" CHECK ((monto > 0)),
  CONSTRAINT "historial_pagos_empleados_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."historial_pagos_empleados"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."mesas" (
  "id"          uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "numero_mesa" text                     NOT NULL,
  "estado"      text                     NOT NULL DEFAULT 'Libre'::text,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "mesas_estado_check" CHECK ((estado = ANY (ARRAY['Libre'::text, 'Ocupada'::text, 'Reservada'::text]))),
  CONSTRAINT "mesas_numero_mesa_key" UNIQUE (numero_mesa),
  CONSTRAINT "mesas_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."mesas"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."ordenes" (
  "id"             uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "mesa_id"        uuid,
  "cliente_id"     uuid,
  "tipo_servicio"  text                     NOT NULL,
  "estado"         text                     NOT NULL DEFAULT 'Abierta'::text,
  "fecha_apertura" timestamp with time zone NOT NULL DEFAULT now(),
  "fecha_cierre"   timestamp with time zone,
  "notas"          text,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "ordenes_estado_check" CHECK ((estado = ANY (ARRAY['Abierta'::text, 'Cerrada'::text, 'Cancelada'::text]))),
  CONSTRAINT "ordenes_pkey" PRIMARY KEY (id),
  CONSTRAINT "ordenes_tipo_servicio_check" CHECK ((tipo_servicio = ANY (ARRAY['Mesa'::text, 'Para llevar'::text, 'Domicilio'::text])))
);

ALTER TABLE "public"."ordenes"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."productos" (
  "id"                  uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "nombre"              text                     NOT NULL,
  "precio"              bigint                   NOT NULL,
  "categoria"           text                     NOT NULL,
  "controla_inventario" boolean                  NOT NULL DEFAULT false,
  "stock_actual"        integer                  DEFAULT 0,
  "stock_minimo"        integer                  DEFAULT 0,
  "activo"              boolean                  NOT NULL DEFAULT true,
  "created_at"          timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"          timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "productos_pkey" PRIMARY KEY (id),
  CONSTRAINT "productos_precio_check" CHECK ((precio >= 0)),
  CONSTRAINT "productos_stock_actual_check" CHECK ((stock_actual >= 0)),
  CONSTRAINT "productos_stock_minimo_check" CHECK ((stock_minimo >= 0))
);

ALTER TABLE "public"."productos"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."promociones" (
  "id"                uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "titulo"            text                     NOT NULL,
  "descripcion"       text                     NOT NULL,
  "imagen_url"        text,
  "fecha_publicacion" timestamp with time zone NOT NULL DEFAULT now(),
  "fecha_vencimiento" date,
  "activo"            boolean                  NOT NULL DEFAULT true,
  "created_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "updated_at"        timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "promociones_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."promociones"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."transacciones" (
  "id"              uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "orden_id"        uuid                     NOT NULL,
  "monto"           bigint                   NOT NULL,
  "metodo_pago"     text                     NOT NULL,
  "fecha"           timestamp with time zone NOT NULL DEFAULT now(),
  "idempotency_key" uuid                     NOT NULL DEFAULT extensions.uuid_generate_v4(),
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "transacciones_idempotency_key_key" UNIQUE (idempotency_key),
  CONSTRAINT "transacciones_metodo_pago_check" CHECK ((metodo_pago = ANY (ARRAY['Efectivo'::text, 'Tarjeta'::text, 'Transferencia'::text, 'Otro'::text]))),
  CONSTRAINT "transacciones_monto_check" CHECK ((monto > 0)),
  CONSTRAINT "transacciones_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."transacciones"
  ENABLE ROW LEVEL SECURITY;

CREATE TABLE "public"."venta_diaria" (
  "id"             bigint                   GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  "fecha"          date                     NOT NULL,
  "total_efectivo" bigint                   NOT NULL DEFAULT 0,
  "total_tarjeta"  bigint                   NOT NULL DEFAULT 0,
  "total_otro"     bigint                   NOT NULL DEFAULT 0,
  "total_global"   bigint                   NOT NULL,
  "num_ordenes"    integer                  NOT NULL DEFAULT 0,
  "hora_cierre"    timestamp with time zone NOT NULL DEFAULT now(),
  "cerrado_por"    uuid,
  CONSTRAINT "venta_diaria_fecha_key" UNIQUE (fecha),
  CONSTRAINT "venta_diaria_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."venta_diaria"
  ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.auth_role()
  RETURNS text
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  AS $function$
  SELECT COALESCE(
    auth.jwt() -> 'user_metadata' ->> 'rol',
    ''
  );
$function$;

CREATE OR REPLACE FUNCTION public.decrementar_stock (
  p_producto_id uuid,
  p_cantidad    integer
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  AS $function$
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
$function$;

CREATE OR REPLACE FUNCTION public.realizar_corte_caja (
  p_fecha       date,
  p_cerrado_por uuid
)
  RETURNS TABLE (
    total_efectivo bigint,
    total_tarjeta  bigint,
    total_otro     bigint,
    total_global   bigint,
    num_ordenes    integer
  )
  LANGUAGE plpgsql
  SECURITY DEFINER
  AS $function$
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
$function$;

CREATE OR REPLACE FUNCTION public.registrar_visita_cliente (
  p_cliente_id uuid
)
  RETURNS jsonb
  LANGUAGE plpgsql
  SECURITY DEFINER
  AS $function$
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
$function$;

CREATE OR REPLACE FUNCTION public.trigger_set_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$;

ALTER TABLE "public"."clientes"
  ADD CONSTRAINT "clientes_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."empleados"
  ADD CONSTRAINT "empleados_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE "public"."historial_pagos_empleados"
  ADD CONSTRAINT "historial_pagos_empleados_empleado_id_fkey" FOREIGN KEY (empleado_id) REFERENCES public.empleados(id) ON DELETE RESTRICT;

ALTER TABLE "public"."ordenes"
  ADD CONSTRAINT "ordenes_cliente_id_fkey" FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE SET NULL;

ALTER TABLE "public"."ordenes"
  ADD CONSTRAINT "ordenes_mesa_id_fkey" FOREIGN KEY (mesa_id) REFERENCES public.mesas(id) ON DELETE RESTRICT;

ALTER TABLE "public"."detalle_orden"
  ADD CONSTRAINT "detalle_orden_orden_id_fkey" FOREIGN KEY (orden_id) REFERENCES public.ordenes(id) ON DELETE CASCADE;

ALTER TABLE "public"."detalle_orden"
  ADD CONSTRAINT "detalle_orden_producto_id_fkey" FOREIGN KEY (producto_id) REFERENCES public.productos(id) ON DELETE RESTRICT;

ALTER TABLE "public"."transacciones"
  ADD CONSTRAINT "transacciones_orden_id_fkey" FOREIGN KEY (orden_id) REFERENCES public.ordenes(id) ON DELETE RESTRICT;

ALTER TABLE "public"."venta_diaria"
  ADD CONSTRAINT "venta_diaria_cerrado_por_fkey" FOREIGN KEY (cerrado_por) REFERENCES public.empleados(id) ON DELETE SET NULL;

CREATE INDEX idx_clientes_telefono ON public.clientes USING btree (telefono);

CREATE INDEX idx_clientes_user_id ON public.clientes USING btree (user_id);

CREATE INDEX idx_detalle_orden_estado_pago ON public.detalle_orden USING btree (estado_pago);

CREATE INDEX idx_detalle_orden_orden_id ON public.detalle_orden USING btree (orden_id);

CREATE INDEX idx_detalle_orden_producto_id ON public.detalle_orden USING btree (producto_id);

CREATE INDEX idx_empleados_dia_pago ON public.empleados USING btree (dia_pago);

CREATE INDEX idx_empleados_user_id ON public.empleados USING btree (user_id);

CREATE INDEX idx_historial_pagos_empleado_id ON public.historial_pagos_empleados USING btree (empleado_id);

CREATE INDEX idx_historial_pagos_fecha ON public.historial_pagos_empleados USING btree (fecha_pago);

CREATE INDEX idx_ordenes_cliente_id ON public.ordenes USING btree (cliente_id);

CREATE INDEX idx_ordenes_estado ON public.ordenes USING btree (estado);

CREATE INDEX idx_ordenes_fecha_apertura ON public.ordenes USING btree (fecha_apertura);

CREATE INDEX idx_ordenes_mesa_id ON public.ordenes USING btree (mesa_id);

CREATE INDEX idx_productos_activo ON public.productos USING btree (activo);

CREATE INDEX idx_productos_categoria ON public.productos USING btree (categoria);

CREATE INDEX idx_promociones_activo ON public.promociones USING btree (activo);

CREATE INDEX idx_promociones_fecha_vencimiento ON public.promociones USING btree (fecha_vencimiento);

CREATE INDEX idx_transacciones_fecha ON public.transacciones USING btree (fecha);

CREATE INDEX idx_transacciones_metodo_pago ON public.transacciones USING btree (metodo_pago);

CREATE INDEX idx_transacciones_orden_id ON public.transacciones USING btree (orden_id);

CREATE INDEX idx_venta_diaria_fecha ON public.venta_diaria USING btree (fecha);

CREATE TRIGGER set_updated_at_clientes
  BEFORE UPDATE ON public.clientes
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_set_updated_at();

CREATE TRIGGER set_updated_at_detalle_orden
  BEFORE UPDATE ON public.detalle_orden
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_set_updated_at();

CREATE TRIGGER set_updated_at_empleados
  BEFORE UPDATE ON public.empleados
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_set_updated_at();

CREATE TRIGGER set_updated_at_mesas
  BEFORE UPDATE ON public.mesas
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_set_updated_at();

CREATE TRIGGER set_updated_at_ordenes
  BEFORE UPDATE ON public.ordenes
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_set_updated_at();

CREATE TRIGGER set_updated_at_productos
  BEFORE UPDATE ON public.productos
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_set_updated_at();

CREATE TRIGGER set_updated_at_promociones
  BEFORE UPDATE ON public.promociones
  FOR EACH ROW
  EXECUTE FUNCTION public.trigger_set_updated_at();

CREATE POLICY "clientes_admin_delete" ON "public"."clientes"
  FOR DELETE
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "clientes_select_own" ON "public"."clientes"
  FOR SELECT
  TO PUBLIC
  USING ((auth.uid() = user_id));

CREATE POLICY "clientes_staff_insert" ON "public"."clientes"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "clientes_staff_select" ON "public"."clientes"
  FOR SELECT
  TO PUBLIC
  USING ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "clientes_staff_update" ON "public"."clientes"
  FOR UPDATE
  TO PUBLIC
  USING ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "clientes_update_own" ON "public"."clientes"
  FOR UPDATE
  TO PUBLIC
  USING ((auth.uid() = user_id))
  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY "detalle_orden_clientes_select_own" ON "public"."detalle_orden"
  FOR SELECT
  TO PUBLIC
  USING ((orden_id IN ( SELECT o.id
   FROM (public.ordenes o
     JOIN public.clientes c ON ((c.id = o.cliente_id)))
  WHERE (c.user_id = auth.uid()))));

CREATE POLICY "detalle_orden_staff_all" ON "public"."detalle_orden"
  FOR ALL
  TO PUBLIC
  USING ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "empleados_admin_all" ON "public"."empleados"
  FOR ALL
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "empleados_select_own" ON "public"."empleados"
  FOR SELECT
  TO PUBLIC
  USING ((auth.uid() = user_id));

CREATE POLICY "pagos_empleados_admin_all" ON "public"."historial_pagos_empleados"
  FOR ALL
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "pagos_empleados_select_own" ON "public"."historial_pagos_empleados"
  FOR SELECT
  TO PUBLIC
  USING ((empleado_id IN ( SELECT empleados.id
   FROM public.empleados
  WHERE (empleados.user_id = auth.uid()))));

CREATE POLICY "mesas_admin_delete" ON "public"."mesas"
  FOR DELETE
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "mesas_public_select" ON "public"."mesas"
  FOR SELECT
  TO PUBLIC
  USING (true);

CREATE POLICY "mesas_staff_insert" ON "public"."mesas"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "mesas_staff_update" ON "public"."mesas"
  FOR UPDATE
  TO PUBLIC
  USING ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "ordenes_admin_delete" ON "public"."ordenes"
  FOR DELETE
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "ordenes_clientes_select_own" ON "public"."ordenes"
  FOR SELECT
  TO PUBLIC
  USING ((cliente_id IN ( SELECT clientes.id
   FROM public.clientes
  WHERE (clientes.user_id = auth.uid()))));

CREATE POLICY "ordenes_staff_insert" ON "public"."ordenes"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "ordenes_staff_select" ON "public"."ordenes"
  FOR SELECT
  TO PUBLIC
  USING ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "ordenes_staff_update" ON "public"."ordenes"
  FOR UPDATE
  TO PUBLIC
  USING ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "productos_admin_delete" ON "public"."productos"
  FOR DELETE
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "productos_public_select" ON "public"."productos"
  FOR SELECT
  TO PUBLIC
  USING (true);

CREATE POLICY "productos_staff_insert" ON "public"."productos"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "productos_staff_update" ON "public"."productos"
  FOR UPDATE
  TO PUBLIC
  USING ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "promociones_admin_delete" ON "public"."promociones"
  FOR DELETE
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "promociones_admin_insert" ON "public"."promociones"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((public.auth_role() = 'admin'::text));

CREATE POLICY "promociones_admin_update" ON "public"."promociones"
  FOR UPDATE
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "promociones_public_select" ON "public"."promociones"
  FOR SELECT
  TO PUBLIC
  USING (true);

CREATE POLICY "transacciones_staff_insert" ON "public"."transacciones"
  FOR INSERT
  TO PUBLIC
  WITH CHECK ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "transacciones_staff_select" ON "public"."transacciones"
  FOR SELECT
  TO PUBLIC
  USING ((public.auth_role() = ANY (ARRAY['admin'::text, 'empleado'::text])));

CREATE POLICY "venta_diaria_admin_all" ON "public"."venta_diaria"
  FOR ALL
  TO PUBLIC
  USING ((public.auth_role() = 'admin'::text));

CREATE POLICY "venta_diaria_empleado_select" ON "public"."venta_diaria"
  FOR SELECT
  TO PUBLIC
  USING ((public.auth_role() = 'empleado'::text));

GRANT EXECUTE ON FUNCTION "public"."auth_role"() TO PUBLIC, "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."auth_role"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."auth_role"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."auth_role"() TO "service_role";

GRANT EXECUTE ON FUNCTION "public"."decrementar_stock"(uuid, integer) TO PUBLIC, "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."decrementar_stock"(uuid, integer) FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."decrementar_stock"(uuid, integer) TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."decrementar_stock"(uuid, integer) TO "service_role";

GRANT EXECUTE ON FUNCTION "public"."realizar_corte_caja"(date, uuid) TO PUBLIC, "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."realizar_corte_caja"(date, uuid) FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."realizar_corte_caja"(date, uuid) TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."realizar_corte_caja"(date, uuid) TO "service_role";

GRANT EXECUTE ON FUNCTION "public"."registrar_visita_cliente"(uuid) TO PUBLIC, "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."registrar_visita_cliente"(uuid) FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."registrar_visita_cliente"(uuid) TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."registrar_visita_cliente"(uuid) TO "service_role";

GRANT EXECUTE ON FUNCTION "public"."trigger_set_updated_at"() TO PUBLIC, "anon", "authenticated";

REVOKE ALL ON FUNCTION "public"."trigger_set_updated_at"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."trigger_set_updated_at"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."trigger_set_updated_at"() TO "service_role";

REVOKE ALL ON SEQUENCE "public"."venta_diaria_id_seq" FROM "anon";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."venta_diaria_id_seq" TO "anon";

REVOKE ALL ON SEQUENCE "public"."venta_diaria_id_seq" FROM "authenticated";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."venta_diaria_id_seq" TO "authenticated";

REVOKE ALL ON SEQUENCE "public"."venta_diaria_id_seq" FROM "postgres";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."venta_diaria_id_seq" TO "postgres";

REVOKE ALL ON SEQUENCE "public"."venta_diaria_id_seq" FROM "service_role";

GRANT SELECT, UPDATE, USAGE ON SEQUENCE "public"."venta_diaria_id_seq" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."clientes" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."clientes" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."clientes" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."clientes" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."detalle_orden" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."detalle_orden" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."detalle_orden" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."detalle_orden" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."empleados" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."empleados" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."empleados" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."empleados" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."historial_pagos_empleados" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."historial_pagos_empleados" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."historial_pagos_empleados" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."historial_pagos_empleados" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."mesas" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."mesas" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."mesas" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."mesas" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ordenes" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."ordenes" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ordenes" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."ordenes" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."productos" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."productos" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."productos" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."productos" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."promociones" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."promociones" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."promociones" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."promociones" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."transacciones" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."transacciones" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."transacciones" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."transacciones" TO "service_role";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."venta_diaria" TO "anon", "authenticated";

REVOKE ALL ON TABLE "public"."venta_diaria" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."venta_diaria" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."venta_diaria" TO "service_role";


```
## 20261002204523_phase1_secure_roles_rls.sql
```sql
-- Fase 1: fuente de verdad segura para autorización administrativa.
-- No depende de raw_user_meta_data/user_metadata, que el usuario puede editar.

create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin', 'empleado')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_roles enable row level security;

create or replace function public.auth_role()
returns text
language sql stable security definer
set search_path = public
as $$
  select coalesce((select role from public.user_roles where user_id = (select auth.uid())), '');
$$;

revoke all on function public.auth_role() from public;
grant execute on function public.auth_role() to authenticated;

insert into public.user_roles (user_id, role)
select id,
       case when raw_user_meta_data->>'rol' = 'admin' then 'admin' else 'empleado' end
from auth.users
on conflict (user_id) do nothing;

drop policy if exists user_roles_self_select on public.user_roles;
create policy user_roles_self_select on public.user_roles
  for select to authenticated
  using (user_id = (select auth.uid()) or public.auth_role() = 'admin');

create or replace function public.set_user_role(target_email text, target_role text)
returns text
language plpgsql security definer
set search_path = public
as $$
declare target_id uuid;
begin
  if public.auth_role() <> 'admin' then
    raise exception 'permiso_denegado' using errcode = '42501';
  end if;
  if target_role not in ('admin', 'empleado') then
    raise exception 'rol_invalido' using errcode = '22023';
  end if;
  select id into target_id from auth.users where email = target_email;
  if target_id is null then return 'Usuario no encontrado'; end if;
  insert into public.user_roles(user_id, role) values (target_id, target_role)
  on conflict (user_id) do update set role = excluded.role, updated_at = now();
  update auth.users
    set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
      || jsonb_build_object('rol', target_role)
    where id = target_id;
  return 'Rol actualizado';
end;
$$;

revoke all on function public.set_user_role(text, text) from public;
grant execute on function public.set_user_role(text, text) to authenticated;

create or replace function public.handle_new_user_role()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.user_roles(user_id, role)
  values (new.id, 'empleado') on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_set_role on auth.users;
create trigger on_auth_user_created_set_role after insert on auth.users
for each row execute function public.handle_new_user_role();

revoke all on function public.handle_new_user_role() from public;

-- Las RPC financieras/stock/lealtad son invocables solo por usuarios autenticados.
revoke execute on function public.decrementar_stock(uuid, integer) from public, anon;
grant execute on function public.decrementar_stock(uuid, integer) to authenticated;
revoke execute on function public.realizar_corte_caja(date, uuid) from public, anon;
grant execute on function public.realizar_corte_caja(date, uuid) to authenticated;
revoke execute on function public.registrar_visita_cliente(uuid) from public, anon;
grant execute on function public.registrar_visita_cliente(uuid) to authenticated;

```
## 20261002204918_phase1_harden_function_security.sql
```sql
-- Endurecimiento posterior a los advisors de Supabase.

alter function public.auth_role() set search_path = public, auth, extensions;
alter function public.decrementar_stock(uuid, integer) set search_path = public, auth, extensions;
alter function public.realizar_corte_caja(date, uuid) set search_path = public, auth, extensions;
alter function public.registrar_visita_cliente(uuid) set search_path = public, auth, extensions;
alter function public.set_user_role(text, text) set search_path = public, auth, extensions;
alter function public.handle_new_user_role() set search_path = public, auth, extensions;

-- Las funciones internas no deben ser endpoints RPC anónimos.
revoke execute on function public.auth_role() from anon;
revoke execute on function public.handle_new_user_role() from anon, authenticated;
revoke execute on function public.set_user_role(text, text) from anon;
revoke execute on function public.decrementar_stock(uuid, integer) from anon;
revoke execute on function public.realizar_corte_caja(date, uuid) from anon;
revoke execute on function public.registrar_visita_cliente(uuid) from anon;

-- La función de cambio de rol solo se expone a usuarios autenticados;
-- el cuerpo valida además que sean admin.
grant execute on function public.set_user_role(text, text) to authenticated;

```
## 20261002205021_phase1_fix_trigger_search_path.sql
```sql
alter function public.trigger_set_updated_at()
  set search_path = public, auth, extensions;

```
## 20261002213231_phase2_business_integrity_tables.sql
```sql
-- Tablas de integridad para la aplicación administrativa.
-- Todas las cantidades monetarias están expresadas en centavos.

create table public.pago_detalles (
  id uuid primary key default extensions.uuid_generate_v4(),
  transaccion_id uuid not null references public.transacciones(id) on delete restrict,
  detalle_orden_id uuid not null references public.detalle_orden(id) on delete restrict,
  cantidad integer not null check (cantidad > 0),
  monto bigint not null check (monto > 0),
  created_at timestamptz not null default now(),
  unique (transaccion_id, detalle_orden_id)
);

create table public.movimientos_inventario (
  id uuid primary key default extensions.uuid_generate_v4(),
  producto_id uuid not null references public.productos(id) on delete restrict,
  cantidad integer not null check (cantidad <> 0),
  tipo text not null check (tipo in ('entrada', 'venta', 'ajuste', 'cancelacion', 'merma')),
  referencia_id uuid,
  notas text,
  creado_por uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  idempotency_key uuid not null unique default extensions.uuid_generate_v4()
);

create table public.visitas_clientes (
  id uuid primary key default extensions.uuid_generate_v4(),
  cliente_id uuid not null references public.clientes(id) on delete restrict,
  fecha date not null default (now() at time zone 'America/Mexico_City')::date,
  puntos_otorgados integer not null default 10 check (puntos_otorgados >= 0),
  registrado_por uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (cliente_id, fecha)
);

create table public.auditoria_eventos (
  id uuid primary key default extensions.uuid_generate_v4(),
  actor_id uuid references auth.users(id) on delete set null,
  entidad text not null,
  entidad_id uuid,
  accion text not null check (accion in ('crear', 'actualizar', 'eliminar', 'pagar', 'cancelar', 'sincronizar', 'ajustar')),
  datos jsonb not null default '{}'::jsonb,
  dispositivo_id text,
  offline boolean not null default false,
  created_at timestamptz not null default now()
);

create unique index ordenes_una_abierta_por_mesa
  on public.ordenes(mesa_id)
  where mesa_id is not null and estado = 'Abierta';

create index pago_detalles_transaccion_idx on public.pago_detalles(transaccion_id);
create index pago_detalles_detalle_idx on public.pago_detalles(detalle_orden_id);
create index movimientos_inventario_producto_idx on public.movimientos_inventario(producto_id, created_at desc);
create index visitas_clientes_fecha_idx on public.visitas_clientes(fecha desc);
create index auditoria_eventos_entidad_idx on public.auditoria_eventos(entidad, entidad_id, created_at desc);

alter table public.pago_detalles enable row level security;
alter table public.movimientos_inventario enable row level security;
alter table public.visitas_clientes enable row level security;
alter table public.auditoria_eventos enable row level security;

create policy pago_detalles_staff_select on public.pago_detalles
  for select to authenticated using (public.auth_role() in ('admin', 'empleado'));
create policy pago_detalles_staff_insert on public.pago_detalles
  for insert to authenticated with check (public.auth_role() in ('admin', 'empleado'));

create policy movimientos_inventario_staff_select on public.movimientos_inventario
  for select to authenticated using (public.auth_role() in ('admin', 'empleado'));
create policy movimientos_inventario_staff_insert on public.movimientos_inventario
  for insert to authenticated with check (public.auth_role() in ('admin', 'empleado'));

create policy visitas_clientes_staff_select on public.visitas_clientes
  for select to authenticated using (public.auth_role() in ('admin', 'empleado'));
create policy visitas_clientes_staff_insert on public.visitas_clientes
  for insert to authenticated with check (public.auth_role() in ('admin', 'empleado'));

create policy auditoria_eventos_admin_select on public.auditoria_eventos
  for select to authenticated using (public.auth_role() = 'admin');
create policy auditoria_eventos_staff_insert on public.auditoria_eventos
  for insert to authenticated with check (public.auth_role() in ('admin', 'empleado'));

comment on table public.pago_detalles is 'Asignación inmutable de transacciones a productos/cantidades para división de cuenta.';
comment on table public.movimientos_inventario is 'Libro de movimientos de inventario; no se corrige borrando filas.';
comment on table public.visitas_clientes is 'Una visita máxima por cliente y fecha local del negocio.';
comment on table public.auditoria_eventos is 'Trazabilidad de operaciones administrativas y sincronización offline.';

```
## 20261003024202_phase6_atomic_payment.sql
```sql
-- Operación financiera atómica para pagos completos, parciales y divididos.
-- SECURITY INVOKER: respeta las políticas RLS del usuario autenticado.
create or replace function public.registrar_pago(
  p_orden_id uuid,
  p_monto bigint,
  p_metodo_pago text,
  p_idempotency_key uuid,
  p_asignaciones jsonb
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_existing uuid;
  v_transaction_id uuid;
  v_order_total bigint;
  v_paid_before bigint;
  v_allocation_total bigint := 0;
  v_detail record;
  v_requested_qty integer;
  v_requested_amount bigint;
  v_detail_total bigint;
  v_detail_paid bigint;
  v_item jsonb;
begin
  if public.auth_role() not in ('admin', 'empleado') then
    raise exception 'not_authorized' using errcode = '42501';
  end if;
  if p_monto <= 0 then raise exception 'invalid_amount'; end if;
  if p_metodo_pago not in ('Efectivo', 'Tarjeta', 'Transferencia', 'Otro') then
    raise exception 'invalid_payment_method';
  end if;
  if jsonb_typeof(p_asignaciones) <> 'array' or jsonb_array_length(p_asignaciones) = 0 then
    raise exception 'invalid_allocations';
  end if;

  select id into v_existing
  from public.transacciones
  where idempotency_key = p_idempotency_key;
  if v_existing is not null then
    return jsonb_build_object('transaction_id', v_existing, 'idempotent', true);
  end if;

  perform 1 from public.ordenes where id = p_orden_id for update;
  if not found then raise exception 'order_not_found'; end if;
  select coalesce(sum(d.cantidad * d.precio_unitario), 0)
    into v_order_total
  from public.detalle_orden d where d.orden_id = p_orden_id;
  select coalesce(sum(t.monto), 0) into v_paid_before
  from public.transacciones t where t.orden_id = p_orden_id;
  if v_paid_before + p_monto > v_order_total then raise exception 'overpayment'; end if;

  for v_detail in
    select d.id, d.cantidad, d.precio_unitario
    from public.detalle_orden d
    where d.orden_id = p_orden_id
    for update
  loop
    select coalesce(sum(pd.cantidad), 0), coalesce(sum(pd.monto), 0)
      into v_requested_qty, v_detail_paid
    from public.pago_detalles pd
    where pd.detalle_orden_id = v_detail.id;
    for v_item in
      select item
      from jsonb_array_elements(p_asignaciones) item
      where (item->>'detalle_orden_id')::uuid = v_detail.id
    loop
      v_requested_qty := (v_item->>'cantidad')::integer;
      v_requested_amount := (v_item->>'monto')::bigint;
      if v_requested_qty <= 0 or v_requested_amount <= 0 then raise exception 'invalid_allocation'; end if;
      if v_requested_qty + coalesce((select sum(pd.cantidad) from public.pago_detalles pd where pd.detalle_orden_id = v_detail.id), 0) > v_detail.cantidad then
        raise exception 'quantity_already_paid';
      end if;
      v_detail_total := v_detail.cantidad * v_detail.precio_unitario;
      if v_requested_amount + v_detail_paid > v_detail_total then raise exception 'detail_overpayment'; end if;
      v_allocation_total := v_allocation_total + v_requested_amount;
    end loop;
  end loop;
  if v_allocation_total <> p_monto then raise exception 'allocation_amount_mismatch'; end if;

  insert into public.transacciones (orden_id, monto, metodo_pago, idempotency_key)
    values (p_orden_id, p_monto, p_metodo_pago, p_idempotency_key)
    returning id into v_transaction_id;
  insert into public.pago_detalles (transaccion_id, detalle_orden_id, cantidad, monto)
    select v_transaction_id, (item->>'detalle_orden_id')::uuid,
           (item->>'cantidad')::integer, (item->>'monto')::bigint
    from jsonb_array_elements(p_asignaciones) item;

  update public.detalle_orden d set estado_pago = 'Pagado', updated_at = now()
  where d.orden_id = p_orden_id
    and (select coalesce(sum(pd.monto), 0) from public.pago_detalles pd where pd.detalle_orden_id = d.id)
        >= d.cantidad * d.precio_unitario;
  if v_paid_before + p_monto = v_order_total then
    update public.ordenes set estado = 'Cerrada', fecha_cierre = now(), updated_at = now()
    where id = p_orden_id;
  end if;
  return jsonb_build_object('transaction_id', v_transaction_id, 'idempotent', false);
end;
$$;

revoke all on function public.registrar_pago(uuid, bigint, text, uuid, jsonb) from public, anon;
grant execute on function public.registrar_pago(uuid, bigint, text, uuid, jsonb) to authenticated;

comment on function public.registrar_pago(uuid, bigint, text, uuid, jsonb)
  is 'Registra un pago con asignaciones atómicas, idempotencia y bloqueo de orden/detalles.';

```
## 20261003025226_phase7_atomic_inventory.sql
```sql
create or replace function public.registrar_movimiento_inventario(
  p_producto_id uuid,
  p_cantidad integer,
  p_tipo text,
  p_idempotency_key uuid,
  p_referencia_id uuid default null,
  p_notas text default null
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_existing uuid;
  v_stock integer;
  v_controls boolean;
  v_movement_id uuid;
  v_new_stock integer;
begin
  if public.auth_role() not in ('admin', 'empleado') then
    raise exception 'not_authorized' using errcode = '42501';
  end if;
  if p_cantidad = 0 then raise exception 'invalid_quantity'; end if;
  if p_tipo not in ('entrada', 'venta', 'ajuste', 'cancelacion', 'merma') then
    raise exception 'invalid_movement_type';
  end if;
  if p_tipo in ('venta', 'merma') and p_cantidad > 0 then
    raise exception 'movement_sign_mismatch';
  end if;
  if p_tipo in ('entrada', 'cancelacion') and p_cantidad < 0 then
    raise exception 'movement_sign_mismatch';
  end if;

  select id into v_existing from public.movimientos_inventario
  where idempotency_key = p_idempotency_key;
  if v_existing is not null then
    return jsonb_build_object('movement_id', v_existing, 'idempotent', true);
  end if;

  select stock_actual, controla_inventario into v_stock, v_controls
  from public.productos where id = p_producto_id for update;
  if not found then raise exception 'product_not_found'; end if;
  if not v_controls and p_tipo in ('venta', 'merma') then
    raise exception 'product_does_not_track_inventory';
  end if;
  v_new_stock := v_stock + p_cantidad;
  if v_new_stock < 0 then raise exception 'insufficient_stock'; end if;

  insert into public.movimientos_inventario
    (producto_id, cantidad, tipo, referencia_id, notas, creado_por, idempotency_key)
  values
    (p_producto_id, p_cantidad, p_tipo, p_referencia_id, p_notas, auth.uid(), p_idempotency_key)
  returning id into v_movement_id;
  update public.productos set stock_actual = v_new_stock, updated_at = now()
  where id = p_producto_id;
  return jsonb_build_object(
    'movement_id', v_movement_id, 'stock_actual', v_new_stock, 'idempotent', false
  );
end;
$$;

revoke all on function public.registrar_movimiento_inventario(uuid, integer, text, uuid, uuid, text)
  from public, anon;
grant execute on function public.registrar_movimiento_inventario(uuid, integer, text, uuid, uuid, text)
  to authenticated;

comment on function public.registrar_movimiento_inventario(uuid, integer, text, uuid, uuid, text)
  is 'Registra un movimiento y actualiza stock con bloqueo de producto e idempotencia.';

```
## 20261003030433_phase8_qr_loyalty_daily_visit.sql
```sql
create extension if not exists pgcrypto with schema extensions;

alter table public.clientes
  add column if not exists qr_token_hash text;

create unique index if not exists clientes_qr_token_hash_uidx
  on public.clientes(qr_token_hash)
  where qr_token_hash is not null;

alter table public.visitas_clientes
  add column if not exists usuario_id uuid references auth.users(id) on delete restrict;

create unique index if not exists visitas_clientes_usuario_fecha_uidx
  on public.visitas_clientes(usuario_id, fecha)
  where usuario_id is not null;

comment on column public.clientes.qr_token_hash is
  'Hash SHA-256 de un token QR opaco; nunca se almacena el token en claro.';
comment on column public.visitas_clientes.usuario_id is
  'Identidad de la cuenta del cliente; base de la regla una visita diaria por usuario.';

create or replace function public.registrar_visita_qr(p_qr_token text)
returns jsonb
language plpgsql
security invoker
set search_path = public, extensions
as $$
declare
  v_cliente record;
  v_fecha date := (now() at time zone 'America/Mexico_City')::date;
  v_visita_id uuid;
  v_puntos integer := 10;
begin
  if public.auth_role() not in ('admin', 'empleado') then
    raise exception 'not_authorized' using errcode = '42501';
  end if;
  if p_qr_token is null or length(p_qr_token) < 32 or length(p_qr_token) > 512 then
    raise exception 'invalid_qr_token';
  end if;

  select c.id, c.user_id, c.visitas_totales, c.puntos_lealtad
    into v_cliente
  from public.clientes c
  where c.qr_token_hash = encode(extensions.digest(p_qr_token, 'sha256'), 'hex')
  for update;
  if not found or v_cliente.user_id is null then
    raise exception 'qr_customer_not_found';
  end if;

  insert into public.visitas_clientes (cliente_id, usuario_id, fecha, puntos_otorgados, registrado_por)
    values (v_cliente.id, v_cliente.user_id, v_fecha, v_puntos, auth.uid())
    on conflict (usuario_id, fecha) where usuario_id is not null do nothing
    returning id into v_visita_id;

  if v_visita_id is null then
    return jsonb_build_object(
      'registered', false,
      'already_registered', true,
      'cliente_id', v_cliente.id,
      'fecha', v_fecha
    );
  end if;

  update public.clientes
  set visitas_totales = visitas_totales + 1,
      puntos_lealtad = puntos_lealtad + v_puntos,
      updated_at = now()
  where id = v_cliente.id;

  return jsonb_build_object(
    'registered', true,
    'already_registered', false,
    'cliente_id', v_cliente.id,
    'fecha', v_fecha,
    'puntos_otorgados', v_puntos,
    'visitas_totales', v_cliente.visitas_totales + 1,
    'puntos_lealtad', v_cliente.puntos_lealtad + v_puntos
  );
end;
$$;

revoke all on function public.registrar_visita_qr(text) from public, anon;
grant execute on function public.registrar_visita_qr(text) to authenticated;

comment on function public.registrar_visita_qr(text) is
  'Registra como máximo una visita y puntos por usuario y fecha local de negocio.';

```
## 20261003034251_phase10_idempotent_cash_register.sql
```sql
create or replace function public.realizar_corte_caja_seguro(p_fecha date)
returns table (
  total_efectivo bigint,
  total_tarjeta bigint,
  total_otro bigint,
  total_global bigint,
  num_ordenes integer,
  ya_existia boolean
)
language plpgsql
security invoker
set search_path = public, auth
as $$
declare
  v_corte public.venta_diaria%rowtype;
  v_cerrado_por uuid;
begin
  if public.auth_role() <> 'admin' then
    raise exception 'not_authorized' using errcode = '42501';
  end if;
  select * into v_corte from public.venta_diaria where fecha = p_fecha for update;
  if found then
    return query select v_corte.total_efectivo, v_corte.total_tarjeta,
      v_corte.total_otro, v_corte.total_global, v_corte.num_ordenes, true;
    return;
  end if;

  select id into v_cerrado_por from public.empleados where user_id = auth.uid() limit 1;
  select coalesce(sum(case when metodo_pago = 'Efectivo' then monto else 0 end), 0),
         coalesce(sum(case when metodo_pago = 'Tarjeta' then monto else 0 end), 0),
         coalesce(sum(case when metodo_pago not in ('Efectivo', 'Tarjeta') then monto else 0 end), 0),
         coalesce(sum(monto), 0)
    into total_efectivo, total_tarjeta, total_otro, total_global
  from public.transacciones
  where (fecha at time zone 'America/Mexico_City')::date = p_fecha;
  select count(*)::integer into num_ordenes from public.ordenes
  where estado = 'Cerrada' and (fecha_cierre at time zone 'America/Mexico_City')::date = p_fecha;

  insert into public.venta_diaria(fecha, total_efectivo, total_tarjeta, total_otro, total_global, num_ordenes, cerrado_por)
  values (p_fecha, total_efectivo, total_tarjeta, total_otro, total_global, num_ordenes, v_cerrado_por)
  returning * into v_corte;
  ya_existia := false;
  return next;
exception when unique_violation then
  select * into v_corte from public.venta_diaria where fecha = p_fecha;
  return query select v_corte.total_efectivo, v_corte.total_tarjeta,
    v_corte.total_otro, v_corte.total_global, v_corte.num_ordenes, true;
end;
$$;

revoke all on function public.realizar_corte_caja_seguro(date) from public, anon;
grant execute on function public.realizar_corte_caja_seguro(date) to authenticated;

comment on function public.realizar_corte_caja_seguro(date) is
  'Cierre diario administrativo idempotente por fecha local del negocio.';

```
