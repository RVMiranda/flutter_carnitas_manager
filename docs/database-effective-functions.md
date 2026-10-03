> Actualización 2026-10-03: [reconciliación de operaciones críticas](critical-operations.md) describe la migración incremental 20261003070556, Drift v6, sync_execute_v2 y las sustituciones de RPC/ACL. Sus decisiones y verificaciones posteriores complementan y sustituyen los comportamientos anteriores de pagos e inventario descritos aquí. Ninguna migración se aplicó al servidor remoto.

# Definiciones finales de funciones (derivadas)
Estas son las últimas definiciones CREATE OR REPLACE de cada función. Aplicar conceptualmente los ALTER FUNCTION y ACL posteriores del inventario; no ejecutar este documento. La tabla de funciones en database-audit.md describe seguridad, search_path y EXECUTE finales.
## public.auth_role — 20261002204523_phase1_secure_roles_rls.sql
```sql
create or replace function public.auth_role()
returns text
language sql stable security definer
set search_path = public
as $$
  select coalesce((select role from public.user_roles where user_id = (select auth.uid())), '');
$$;
```
## public.decrementar_stock — 20261002204457_remote_baseline.sql
```sql
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
```
## public.handle_new_user_role — 20261002204523_phase1_secure_roles_rls.sql
```sql
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
```
## public.realizar_corte_caja — 20261002204457_remote_baseline.sql
```sql
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
```
## public.realizar_corte_caja_seguro — 20261003034251_phase10_idempotent_cash_register.sql
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
```
## public.registrar_movimiento_inventario — 20261003025226_phase7_atomic_inventory.sql
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
```
## public.registrar_pago — 20261003024202_phase6_atomic_payment.sql
```sql
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
```
## public.registrar_visita_cliente — 20261002204457_remote_baseline.sql
```sql
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
```
## public.registrar_visita_qr — 20261003030433_phase8_qr_loyalty_daily_visit.sql
```sql
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
```
## public.set_user_role — 20261002204523_phase1_secure_roles_rls.sql
```sql
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
```
## public.trigger_set_updated_at — 20261002204457_remote_baseline.sql
```sql
CREATE OR REPLACE FUNCTION public.trigger_set_updated_at()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$;
```
