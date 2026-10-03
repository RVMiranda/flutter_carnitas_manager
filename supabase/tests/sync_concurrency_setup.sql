-- Disposable database only. Fake identities and fixtures for parallel RPC tests.
insert into auth.users(id,email) values('00000000-0000-4000-8000-000000000101','parallel@test.invalid');
update public.user_roles set role='admin' where user_id='00000000-0000-4000-8000-000000000101';
insert into public.productos(id,nombre,precio,categoria,controla_inventario,stock_actual)
values('00000000-0000-4000-8000-000000000102','Fixture',100,'Fixture',true,2);
insert into public.ordenes(id,tipo_servicio)
values('00000000-0000-4000-8000-000000000103','Para llevar');
insert into public.detalle_orden(id,orden_id,producto_id,cantidad,precio_unitario)
values('00000000-0000-4000-8000-000000000104','00000000-0000-4000-8000-000000000103','00000000-0000-4000-8000-000000000102',1,100);
