-- Identity with no assigned staff role must fail every privileged entry point.
begin;
insert into auth.users(id,email) values('10000000-0000-4000-8000-000000000070','unassigned@test.invalid');
delete from public.user_roles where user_id='10000000-0000-4000-8000-000000000070';
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000070',true);
set local role authenticated;
do $$ begin
  begin perform public.sync_pull(0,null,10); raise exception 'unassigned_pull_allowed'; exception when insufficient_privilege then null; end;
  begin perform public.sync_execute_v2('mesas','10000000-0000-4000-8000-000000000071','INSERT','{}','10000000-0000-4000-8000-000000000072',0); raise exception 'unassigned_push_allowed'; exception when insufficient_privilege then null; end;
  begin perform public.registrar_pago('10000000-0000-4000-8000-000000000003',1,'Efectivo','10000000-0000-4000-8000-000000000073','[]'); raise exception 'unassigned_payment_allowed'; exception when insufficient_privilege then null; end;
  begin perform public.registrar_movimiento_inventario('10000000-0000-4000-8000-000000000002',1,'entrada','10000000-0000-4000-8000-000000000074'); raise exception 'unassigned_inventory_allowed'; exception when insufficient_privilege then null; end;
end $$;
rollback;
