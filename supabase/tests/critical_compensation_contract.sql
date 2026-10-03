-- Run after concurrent assertions. Changes in this test are rolled back.
begin;
insert into public.ordenes(id,tipo_servicio) values('10000000-0000-4000-8000-000000000050','Para llevar');
insert into public.detalle_orden(id,orden_id,producto_id,cantidad,precio_unitario)
values('10000000-0000-4000-8000-000000000051','10000000-0000-4000-8000-000000000050','10000000-0000-4000-8000-000000000002',1,100);
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000001',true);
set local role authenticated;
do $$ declare original uuid; payload jsonb; result jsonb; replay jsonb; begin
  result:=public.registrar_pago('10000000-0000-4000-8000-000000000050',40,'Efectivo','10000000-0000-4000-8000-000000000052','[{"detalle_orden_id":"10000000-0000-4000-8000-000000000051","cantidad":1,"monto":40}]');
  result:=public.registrar_pago('10000000-0000-4000-8000-000000000050',61,'Efectivo','10000000-0000-4000-8000-000000000053','[{"detalle_orden_id":"10000000-0000-4000-8000-000000000051","cantidad":1,"monto":61}]');
  if result->>'reason'<>'overpayment' or (select sum(monto) from public.transacciones where orden_id='10000000-0000-4000-8000-000000000050')<>40 then raise exception 'open_order_overpaid'; end if;
  select id into original from public.movimientos_inventario where producto_id='10000000-0000-4000-8000-000000000002' and tipo='venta';
  payload:=jsonb_build_object('p_producto_id','10000000-0000-4000-8000-000000000002','p_cantidad',1,'p_tipo','cancelacion','p_referencia_id',original,'p_idempotency_key','10000000-0000-4000-8000-000000000030');
  result:=public.sync_execute_v2('registrar_movimiento_inventario','10000000-0000-4000-8000-000000000002','INSERT',payload,'10000000-0000-4000-8000-000000000030',0);
  if result->>'status'<>'confirmed' then raise exception 'compensation_rejected'; end if;
  for i in 1..5 loop
    if public.sync_execute_v2('registrar_movimiento_inventario','10000000-0000-4000-8000-000000000002','INSERT',payload,'10000000-0000-4000-8000-000000000030',0)<>result then raise exception 'compensation_not_idempotent'; end if;
  end loop;
  payload:=jsonb_set(payload,'{p_idempotency_key}','"10000000-0000-4000-8000-000000000031"');
  result:=public.sync_execute_v2('registrar_movimiento_inventario','10000000-0000-4000-8000-000000000002','INSERT',payload,'10000000-0000-4000-8000-000000000031',0);
  if result->>'reason'<>'compensation_exceeds_original' then raise exception 'double_reversal_allowed'; end if;
  if (select stock_actual from public.productos where id='10000000-0000-4000-8000-000000000002')<>1 then raise exception 'compensated_stock_incorrect'; end if;
  -- Rejected sale remains rejected even after stock has been restored.
  -- Receipt data is private; fetch fixture IDs via known keys instead.
  payload:=jsonb_build_object('p_producto_id','10000000-0000-4000-8000-000000000002','p_cantidad',-1,'p_tipo','venta','p_idempotency_key','10000000-0000-4000-8000-000000000021');
  result:=public.sync_execute_v2('registrar_movimiento_inventario','10000000-0000-4000-8000-000000000002','INSERT',payload,'10000000-0000-4000-8000-000000000021',0);
  payload:=jsonb_set(payload,'{p_idempotency_key}','"10000000-0000-4000-8000-000000000022"');
  replay:=public.sync_execute_v2('registrar_movimiento_inventario','10000000-0000-4000-8000-000000000002','INSERT',payload,'10000000-0000-4000-8000-000000000022',0);
  if (result->>'status'='rejected')=(replay->>'status'='rejected') then raise exception 'rejected_key_became_sale'; end if;
  payload:=jsonb_build_object('p_producto_id','10000000-0000-4000-8000-000000000002','p_cantidad',1,'p_tipo','ajuste','p_expected_version',1,'p_idempotency_key','10000000-0000-4000-8000-000000000032');
  result:=public.sync_execute_v2('registrar_movimiento_inventario','10000000-0000-4000-8000-000000000002','INSERT',payload,'10000000-0000-4000-8000-000000000032',0);
  if result->>'reason'<>'stock_version_conflict' then raise exception 'stale_adjustment_allowed'; end if;
  begin perform public.sync_execute_v2('registrar_movimiento_inventario','10000000-0000-4000-8000-000000000002','INSERT',payload||'{"p_expected_version":3}','10000000-0000-4000-8000-000000000032',0); raise exception 'rejected_intent_changed'; exception when invalid_parameter_value then null; end;
end $$;
-- Reject clients/public and private receipt access.
set local role anon;
do $$ begin
  begin perform public.registrar_pago('10000000-0000-4000-8000-000000000003',1,'Efectivo','10000000-0000-4000-8000-000000000099','[]'); raise exception 'anon_rpc_exposed'; exception when insufficient_privilege then null; end;
  begin perform 1 from private_sync.critical_receipts; raise exception 'receipt_exposed'; exception when insufficient_privilege then null; end;
end $$;
rollback;
