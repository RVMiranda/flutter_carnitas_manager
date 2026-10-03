-- Disposable PostgreSQL only. Run once after the migration chain.
insert into auth.users(id,email) values('10000000-0000-4000-8000-000000000001','critical@test.invalid');
update public.user_roles set role='admin' where user_id='10000000-0000-4000-8000-000000000001';
insert into public.productos(id,nombre,precio,categoria,controla_inventario,stock_actual)
values('10000000-0000-4000-8000-000000000002','Last unit',100,'Test',true,1);
insert into public.ordenes(id,tipo_servicio) values('10000000-0000-4000-8000-000000000003','Para llevar');
insert into public.detalle_orden(id,orden_id,producto_id,cantidad,precio_unitario)
values('10000000-0000-4000-8000-000000000004','10000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000002',1,100);
