-- =====================================================================================
-- user_rol_set.sql — Exquisssita Manager
-- Script para la asignación y gestión manual/automática de roles de usuario en Supabase Auth
-- 
-- INSTRUCCIONES:
-- 1. Abre el Editor SQL de tu proyecto en Supabase (https://supabase.com/dashboard).
-- 2. Copia y ejecuta la sección deseada según el caso de uso.
-- =====================================================================================

-- =====================================================================================
-- 1. CONSULTAR USUARIOS Y ROLES ACTUALES
-- =====================================================================================
-- Ejecuta esta consulta para ver todos los usuarios registrados y el rol que tienen asignado en user_metadata.

SELECT 
    id,
    email,
    raw_user_meta_data->>'rol' AS rol_actual,
    raw_user_meta_data,
    created_at,
    last_sign_in_at
FROM auth.users
ORDER BY created_at DESC;


-- =====================================================================================
-- 2. ASIGNACIÓN DIRECTA DE ROL POR CORREO ELECTRÓNICO (Rápido)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Opción A: Asignar rol de ADMINISTRADOR a un usuario existente
-- Reemplaza 'admin@taqueria.com' por el correo real del usuario.
-- -------------------------------------------------------------------------------------
UPDATE auth.users
SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || '{"rol": "admin"}'::jsonb
WHERE email = 'admin@taqueria.com';


-- -------------------------------------------------------------------------------------
-- Opción B: Asignar rol de EMPLEADO a un usuario existente
-- Reemplaza 'empleado@taqueria.com' por el correo real del usuario.
-- -------------------------------------------------------------------------------------
UPDATE auth.users
SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || '{"rol": "empleado"}'::jsonb
WHERE email = 'empleado@taqueria.com';


-- =====================================================================================
-- 3. FUNCIÓN DE UTILIDAD REUTILIZABLE PARA ASIGNAR ROLES
-- =====================================================================================
-- Al crear esta función en PostgreSQL, podrás asignar roles fácilmente llamando a SELECT set_user_role(...);

CREATE OR REPLACE FUNCTION public.set_user_role(target_email TEXT, target_role TEXT)
RETURNS TEXT AS $$
DECLARE
    affected_rows INT;
BEGIN
    IF target_role NOT IN ('admin', 'empleado') THEN
        RAISE EXCEPTION 'Rol inválido "%". Los roles permitidos son "admin" o "empleado".', target_role;
    END IF;

    UPDATE auth.users
    SET raw_user_meta_data = COALESCE(raw_user_meta_data, '{}'::jsonb) || jsonb_build_object('rol', target_role)
    WHERE email = target_email;

    GET DIAGNOSTICS affected_rows = ROW_COUNT;

    IF affected_rows = 0 THEN
        RETURN format('No se encontró ningún usuario con el correo: %s', target_email);
    ELSE
        RETURN format('Rol "%s" asignado exitosamente al usuario: %s', target_role, target_email);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ejemplo de uso de la función utilitaria:
-- SELECT public.set_user_role('tu_correo@ejemplo.com', 'admin');
-- SELECT public.set_user_role('empleado1@ejemplo.com', 'empleado');


-- =====================================================================================
-- 4. TRIGGER OPCIONAL: ROL POR DEFECTO PARA NUEVOS USUARIOS ('empleado')
-- =====================================================================================
-- Si deseas que cualquier nuevo usuario registrado sin rol reciba automáticamente el rol 'empleado':

CREATE OR REPLACE FUNCTION public.handle_new_user_default_role()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.raw_user_meta_data IS NULL OR NOT (NEW.raw_user_meta_data ? 'rol') THEN
    NEW.raw_user_meta_data := COALESCE(NEW.raw_user_meta_data, '{}'::jsonb) || '{"rol": "empleado"}'::jsonb;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Activar el trigger en la tabla auth.users
DROP TRIGGER IF EXISTS on_auth_user_created_set_default_role ON auth.users;
CREATE TRIGGER on_auth_user_created_set_default_role
  BEFORE INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_default_role();
