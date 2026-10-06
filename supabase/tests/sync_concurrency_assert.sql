do $$
begin
  if (select count(*) from public.transacciones where idempotency_key='00000000-0000-4000-8000-000000000106')<>1 then
    raise exception 'Duplicate payment';end if;
  if (select count(*) from public.pago_detalles where detalle_orden_id='00000000-0000-4000-8000-000000000104')<>1 then
    raise exception 'Duplicate allocation';end if;
  if (select stock_actual from public.productos where id='00000000-0000-4000-8000-000000000102')<>1 then
    raise exception 'Stock decremented twice';end if;
  if (select count(*) from public.movimientos_inventario where idempotency_key='00000000-0000-4000-8000-000000000107')<>1 then
    raise exception 'Duplicate inventory movement';end if;
end;
$$;
