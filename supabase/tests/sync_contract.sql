-- After bootstrap + pristine migration replay, only disposable PostgreSQL.
begin;
insert into auth.users(id,email) values
 ('00000000-0000-4000-8000-000000000001','admin@test.invalid'),
 ('00000000-0000-4000-8000-000000000002','employee@test.invalid'),
 ('00000000-0000-4000-8000-000000000003','client@test.invalid');
update public.user_roles set role='admin' where user_id='00000000-0000-4000-8000-000000000001';
delete from public.user_roles where user_id='00000000-0000-4000-8000-000000000003';
insert into public.empleados(id,user_id,nombre,apellido,salario,dia_pago)
values('00000000-0000-4000-8000-000000000010','00000000-0000-4000-8000-000000000002','Private','Payroll',10000,15);
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000001',true);
set local role authenticated;
do $$
declare a jsonb;b jsonb;
begin
  a:=public.sync_execute_v2('mesas','00000000-0000-4000-8000-000000000020','INSERT',
    '{"numero_mesa":"20","estado":"Libre"}', '00000000-0000-4000-8000-000000000030',0);
  b:=public.sync_execute_v2('mesas','00000000-0000-4000-8000-000000000020','INSERT',
    '{"numero_mesa":"20","estado":"Libre"}', '00000000-0000-4000-8000-000000000030',0);
  if a<>b or (a->>'version')::int<>1 then raise exception 'Replay failed'; end if;
  begin
    perform public.sync_execute_v2('mesas','00000000-0000-4000-8000-000000000020','UPDATE',
      '{"estado":"Ocupada"}','00000000-0000-4000-8000-000000000031',0);
    raise exception 'Stale update accepted';
  exception when sqlstate 'P0004' then null;end;
  begin
    perform public.sync_execute_v2('mesas','00000000-0000-4000-8000-000000000020','INSERT',
      '{"numero_mesa":"different"}','00000000-0000-4000-8000-000000000030',0);
    raise exception 'Different replay accepted';
  exception when invalid_parameter_value then null;end;
  perform public.sync_execute_v2('mesas','00000000-0000-4000-8000-000000000020','UPDATE',
    '{"estado":"Ocupada"}','00000000-0000-4000-8000-000000000032',1);
  perform public.sync_execute_v2('mesas','00000000-0000-4000-8000-000000000020','DELETE',
    '{}','00000000-0000-4000-8000-000000000033',2);
  a:=public.sync_pull(0,null,200);
  if not exists(select 1 from jsonb_array_elements(a->'changes') c where c->>'entity_id'='00000000-0000-4000-8000-000000000020' and (c->>'deleted')::boolean) then
    raise exception 'Missing tombstone';end if;
  if (public.sync_pull((a->>'cursor')::bigint,null,200)->>'cursor')::bigint<>(a->>'cursor')::bigint then
    raise exception 'Unstable cursor';end if;
end;
$$;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000002',true);
do $$
declare a jsonb;
begin
  a:=public.sync_pull(0,null,200);
  if exists(select 1 from jsonb_array_elements(a->'changes') c where c->>'entity'='empleados') then
    raise exception 'Employee feed leaks payroll';end if;
  begin
    perform public.sync_execute_v2('promociones','00000000-0000-4000-8000-000000000040','INSERT',
      '{"titulo":"x","descripcion":"x"}','00000000-0000-4000-8000-000000000041',0);
    raise exception 'Employee promotion write accepted';
  exception when insufficient_privilege then null;end;
end;
$$;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000003',true);
do $$
begin
  begin perform public.sync_pull(0,null,200);raise exception 'Client feed accepted';
  exception when insufficient_privilege then null;end;
  if has_schema_privilege('authenticated','private_sync','USAGE') then
    raise exception 'Private receipt schema exposed';end if;
end;
$$;
reset role;
set local role anon;
do $$
begin
  if has_function_privilege('anon','public.sync_pull(bigint,bigint,integer)','EXECUTE') or
    has_function_privilege('anon','public.sync_execute_v2(text,text,text,jsonb,uuid,bigint)','EXECUTE') then
    raise exception 'Anonymous sync RPC grant';end if;
end;
$$;
reset role;
rollback;
