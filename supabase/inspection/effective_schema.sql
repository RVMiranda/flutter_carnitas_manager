-- READ ONLY. No schema changes, no tokens/user data in output.
begin transaction read only;
select version();
select * from supabase_migrations.schema_migrations order by version;
select extname, extversion, extnamespace::regnamespace from pg_extension;
select n.nspname, pg_get_userbyid(n.nspowner) as owner, n.nspacl
from pg_namespace n where n.nspname in ('public','extensions','auth');
select c.relname, c.relkind, pg_get_userbyid(c.relowner) as owner,
       c.relrowsecurity, c.relforcerowsecurity, c.relacl
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' order by c.relname;
select table_name, column_name, data_type, udt_name, is_nullable,
       column_default, is_identity, identity_generation
from information_schema.columns where table_schema='public'
order by table_name, ordinal_position;
select conrelid::regclass as entity, conname, contype, convalidated,
       pg_get_constraintdef(oid) as definition
from pg_constraint where connamespace='public'::regnamespace
order by conrelid::regclass::text, conname;
select * from pg_indexes where schemaname='public' order by tablename,indexname;
select * from pg_policies where schemaname='public' order by tablename,policyname;
select p.oid::regprocedure as signature, pg_get_userbyid(p.proowner) as owner,
       p.prosecdef, p.proconfig, p.proacl, pg_get_functiondef(p.oid)
from pg_proc p where p.pronamespace='public'::regnamespace and p.prokind='f'
order by p.oid::regprocedure::text;
select tgrelid::regclass as entity, tgname, pg_get_triggerdef(oid)
from pg_trigger where not tgisinternal
and tgrelid in (select oid from pg_class where relnamespace in ('public'::regnamespace,'auth'::regnamespace));
select pg_get_userbyid(defaclrole) as owner, defaclnamespace::regnamespace,
       defaclobjtype, defaclacl from pg_default_acl;
select * from information_schema.role_table_grants where table_schema='public';
select * from information_schema.role_column_grants where table_schema='public';
select r.rolname, c.relname,
       has_table_privilege(r.oid,c.oid,'TRUNCATE') as can_truncate,
       has_table_privilege(r.oid,c.oid,'TRIGGER') as can_trigger
from pg_roles r cross join pg_class c
where r.rolname in ('anon','authenticated') and c.relkind='r'
and c.relnamespace='public'::regnamespace;
select r.rolname, c.relname, has_sequence_privilege(r.oid,c.oid,'UPDATE') as can_setval
from pg_roles r cross join pg_class c
where r.rolname in ('anon','authenticated') and c.relkind='S'
and c.relnamespace='public'::regnamespace;
rollback;
