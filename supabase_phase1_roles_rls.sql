-- Fase 1: roles y RLS seguros para Exquisssita Manager.
-- Ejecutar DESPUÉS de database_app.sql en el SQL Editor de Supabase.
-- No elimina tablas ni datos.

create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin', 'empleado')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_roles enable row level security;

create or replace function public.auth_role()
returns text
language sql stable security definer set search_path = public
as $$
  select coalesce((select role from public.user_roles where user_id = auth.uid()), '');
$$;

revoke all on function public.auth_role() from public;
grant execute on function public.auth_role() to authenticated;

-- Migra el rol existente de user_metadata una sola vez.
insert into public.user_roles (user_id, role)
select id, case when raw_user_meta_data->>'rol' = 'admin' then 'admin' else 'empleado' end
from auth.users
where not exists (select 1 from public.user_roles r where r.user_id = auth.users.id)
on conflict (user_id) do nothing;

-- Mantiene app_metadata como claim no editable por el usuario.
create or replace function public.set_user_role(target_email text, target_role text)
returns text
language plpgsql security definer set search_path = public
as $$
declare target_id uuid;
begin
  if public.auth_role() <> 'admin' then
    raise exception 'permiso_denegado' using errcode = '42501';
  end if;
  if target_role not in ('admin', 'empleado') then
    raise exception 'rol_invalido' using errcode = '22023';
  end if;
  select id into target_id from auth.users where email = target_email;
  if target_id is null then return 'Usuario no encontrado'; end if;
  insert into public.user_roles(user_id, role) values (target_id, target_role)
  on conflict (user_id) do update set role = excluded.role, updated_at = now();
  update auth.users set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('rol', target_role)
  where id = target_id;
  return 'Rol actualizado';
end;
$$;

revoke all on function public.set_user_role(text, text) from public;
grant execute on function public.set_user_role(text, text) to authenticated;

drop policy if exists user_roles_self_select on public.user_roles;
create policy user_roles_self_select on public.user_roles for select
  using (user_id = auth.uid() or public.auth_role() = 'admin');

-- En nuevos usuarios, el rol predeterminado es empleado y se guarda en tabla segura.
create or replace function public.handle_new_user_role()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.user_roles(user_id, role) values (new.id, 'empleado') on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_set_role on auth.users;
create trigger on_auth_user_created_set_role after insert on auth.users
for each row execute function public.handle_new_user_role();

-- Fuerza el helper nuevo en las políticas existentes.
-- Las políticas originales pueden coexistir porque PostgreSQL combina OR en RLS.
comment on table public.user_roles is 'Fuente de verdad de autorización; no usar user_metadata para permisos.';
