-- Run against a disposable, already provisioned database as postgres:
-- psql -X -v ON_ERROR_STOP=1 -f supabase/tests/database_security_contract.sql
-- No DROP/TRUNCATE/DML. Gates intentionally fail on known unsafe baseline ACL.
-- Not pgTAP: plain SQL assertions, does not require installing an extension.
begin;
do $$
declare
  entity text;
  db_role text;
  signature text;
begin
  foreach entity in array array[
    'clientes','empleados','productos','mesas','promociones','ordenes',
    'detalle_orden','transacciones','venta_diaria','historial_pagos_empleados',
    'user_roles','pago_detalles','movimientos_inventario','visitas_clientes','auditoria_eventos'
  ] loop
    if not exists (select 1 from pg_class where oid=to_regclass('public.'||entity) and relrowsecurity) then
      raise exception 'RLS absent: %', entity;
    end if;
    foreach db_role in array array['anon','authenticated'] loop
      if has_table_privilege(db_role, 'public.'||entity, 'TRUNCATE') then
        raise exception 'Unsafe TRUNCATE grant: % / %', db_role, entity;
      end if;
    end loop;
  end loop;
  foreach db_role in array array['anon','authenticated'] loop
    if has_sequence_privilege(db_role,'public.venta_diaria_id_seq','UPDATE') then
      raise exception 'Unsafe setval grant: %', db_role;
    end if;
  end loop;
  foreach signature in array array[
    'public.decrementar_stock(uuid,integer)',
    'public.registrar_visita_cliente(uuid)',
    'public.realizar_corte_caja(date,uuid)'
  ] loop
    foreach db_role in array array['anon','authenticated'] loop
      if has_function_privilege(db_role,signature,'EXECUTE') then
        raise exception 'Legacy privileged RPC still exposed: % / %',db_role,signature;
      end if;
    end loop;
  end loop;
  if exists (
    select 1 from pg_proc
    where pronamespace='public'::regnamespace and prosecdef
    and not exists (select 1 from unnest(proconfig) cfg where cfg like 'search_path=%')
  ) then
    raise exception 'SECURITY DEFINER without fixed search_path';
  end if;
  foreach signature in array array[
    'public.registrar_pago(uuid,bigint,text,uuid,jsonb)',
    'public.registrar_movimiento_inventario(uuid,integer,text,uuid,uuid,text)',
    'public.registrar_visita_qr(text)', 'public.realizar_corte_caja_seguro(date)',
    'public.set_user_role(text,text)'
  ] loop
    if has_function_privilege('anon',signature,'EXECUTE') then
      raise exception 'Anonymous RPC execution: %',signature;
    end if;
    if not has_function_privilege('authenticated',signature,'EXECUTE') then
      raise exception 'Authenticated RPC missing grant: %',signature;
    end if;
  end loop;
end;
$$;

-- Real RLS check under a non-owner role with no JWT identity.
select set_config('request.jwt.claims','{}',true);
select set_config('request.jwt.claim.sub','',true);
set local role authenticated;
do $$
begin
  if public.auth_role() <> '' then raise exception 'Identity-free role escalation'; end if;
  if exists(select 1 from public.user_roles) then raise exception 'Role rows exposed without identity'; end if;
  begin
    perform public.set_user_role('audit-nonexistent@example.invalid','admin');
    raise exception 'Role RPC accepted non-admin' using errcode='P0001';
  exception when insufficient_privilege then
    null; -- expected explicit admin guard (42501)
  end;
end;
$$;
reset role;
rollback;
