-- Assert persisted concurrent outcomes, then exercise rejection/replay/ACL.
do $$ begin
  if (select count(*) from public.transacciones where orden_id='10000000-0000-4000-8000-000000000003')<>2
    or (select sum(monto) from public.transacciones where orden_id='10000000-0000-4000-8000-000000000003')<>100 then raise exception 'partial_payments_lost_or_duplicated'; end if;
  if (select stock_actual from public.productos where id='10000000-0000-4000-8000-000000000002')<>0
    or (select count(*) from public.movimientos_inventario where producto_id='10000000-0000-4000-8000-000000000002')<>1 then raise exception 'last_unit_oversold'; end if;
  if (select count(*) from private_sync.critical_receipts where entity='inventory' and result->>'status'='rejected')<>1 then raise exception 'stock_rejection_missing'; end if;
end $$;
begin;
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000001',true);
set local role authenticated;
do $$ declare result jsonb; begin
  result:=public.registrar_pago('10000000-0000-4000-8000-000000000003',1,'Efectivo','10000000-0000-4000-8000-000000000099',
    '[{"detalle_orden_id":"10000000-0000-4000-8000-000000000004","cantidad":1,"monto":1}]');
  if result->>'status'<>'rejected' then raise exception 'overpayment_accepted'; end if;
  -- Original immutable key cannot be repurposed after a rejection.
  begin
    perform public.registrar_pago('10000000-0000-4000-8000-000000000003',2,'Efectivo','10000000-0000-4000-8000-000000000099',
      '[{"detalle_orden_id":"10000000-0000-4000-8000-000000000004","cantidad":1,"monto":2}]');
    raise exception 'mismatched_key_accepted';
  exception when invalid_parameter_value then null; end;
  begin update public.transacciones set monto=1; raise exception 'ledger_update_allowed'; exception when insufficient_privilege then null; end;
  begin delete from public.movimientos_inventario; raise exception 'ledger_delete_allowed'; exception when insufficient_privilege then null; end;
  begin update public.productos set stock_actual=99; raise exception 'silent_stock_update_allowed'; exception when insufficient_privilege then null; end;
  begin perform public.decrementar_stock('10000000-0000-4000-8000-000000000002',1); raise exception 'legacy_stock_allowed'; exception when insufficient_privilege then null; end;
end $$;
commit;
-- Even the owner cannot edit ledger entries; only append corrections.
do $$ begin
  begin update public.transacciones set monto=1; raise exception 'owner_ledger_update_allowed'; exception when insufficient_privilege then null; end;
end $$;
