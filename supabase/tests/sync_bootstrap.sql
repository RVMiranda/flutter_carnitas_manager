-- Disposable plain PostgreSQL 17 only; emulates Auth interfaces for SQL tests.
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
create schema auth;
create schema extensions;
create extension "uuid-ossp" with schema extensions;
create table auth.users(id uuid primary key,email text,raw_user_meta_data jsonb,raw_app_meta_data jsonb);
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid;
$$;
create function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims',true),'')::jsonb,'{}'::jsonb);
$$;
grant usage on schema public,auth,extensions to anon,authenticated,service_role;
grant execute on all functions in schema auth to anon,authenticated,service_role;
alter default privileges in schema public grant all on tables to anon,authenticated,service_role;
alter default privileges in schema public grant all on sequences to anon,authenticated,service_role;
