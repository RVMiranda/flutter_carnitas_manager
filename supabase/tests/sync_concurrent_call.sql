begin;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000101',true);
set local role authenticated;
select public.sync_execute_v2('registrar_pago','00000000-0000-4000-8000-000000000105','INSERT',
 '{"p_orden_id":"00000000-0000-4000-8000-000000000103","p_monto":100,"p_metodo_pago":"Efectivo","p_idempotency_key":"00000000-0000-4000-8000-000000000106","p_asignaciones":[{"detalle_orden_id":"00000000-0000-4000-8000-000000000104","cantidad":1,"monto":100}]}',
 '00000000-0000-4000-8000-000000000106',0);
select public.sync_execute_v2('registrar_movimiento_inventario','00000000-0000-4000-8000-000000000102','INSERT',
 '{"p_producto_id":"00000000-0000-4000-8000-000000000102","p_cantidad":-1,"p_tipo":"venta","p_idempotency_key":"00000000-0000-4000-8000-000000000107"}',
 '00000000-0000-4000-8000-000000000107',0);
commit;
