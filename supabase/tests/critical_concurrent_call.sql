-- Run TWO independent psql sessions concurrently with different :payment_key,
-- :stock_key and :amount (40 and 60). Replay both sessions repeatedly afterward.
begin;
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000001',true);
set local role authenticated;
select public.sync_execute_v2('registrar_pago',:'payment_key','INSERT',jsonb_build_object(
 'p_orden_id','10000000-0000-4000-8000-000000000003','p_monto',:amount,'p_metodo_pago','Efectivo','p_idempotency_key',:'payment_key',
 'p_asignaciones',jsonb_build_array(jsonb_build_object('detalle_orden_id','10000000-0000-4000-8000-000000000004','cantidad',1,'monto',:amount))),:'payment_key',0);
select public.sync_execute_v2('registrar_movimiento_inventario','10000000-0000-4000-8000-000000000002','INSERT',jsonb_build_object(
 'p_producto_id','10000000-0000-4000-8000-000000000002','p_cantidad',-1,'p_tipo','venta','p_idempotency_key',:'stock_key'),:'stock_key',0);
commit;
