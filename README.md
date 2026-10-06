# exquisssita_manager

Aplicación administrativa Flutter para Exquisssita.

La única fuente autoritativa de la definición de base de datos es
`supabase/migrations/`, aplicada en orden. Los SQL de la raíz son históricos:
no utilizarlos para despliegues, bootstrap ni recuperación. `database_app.sql`
contiene borrado destructivo; `user_rol_set.sql` puede reemplazar autorización segura.
Nunca reescribir migraciones ya aplicadas; crear cambios incrementales nuevos.

Consulta la [auditoría de seguridad y matriz RLS](docs/database-audit.md) y el
[inventario derivado del esquema](docs/database-schema-inventory.md).
La auditoría reconstruye el esquema versionado; no certifica su aplicación remota.

El [motor offline-first bidireccional](docs/offline-sync.md) mantiene Drift como
fuente inmediata, usa cursor/tombstones, RPC idempotentes y muestra estados de
sincronización. Su nueva migración requiere revisión y aplicación remota antes
de activar el cliente; no se desplegó durante el desarrollo local.

La [auditoría y reconciliación de pagos e inventario](docs/critical-operations.md)
documenta estados críticos, reservas, compensaciones append-only y los cambios
incrementales de seguridad. La nueva versión del cliente requiere `sync_execute_v2`.

La [evolución del sistema visual](docs/design-system.md) conserva la identidad
Exquisssita y centraliza tokens, componentes, accesibilidad y pruebas.
La galería se abre desde **Más opciones** en debug, después de iniciar sesión.
# Verificación de plataformas

Consulta [auditoría Android/Windows](docs/platform-hardening.md) para la firma externa de release, pruebas reproducibles, alternativa QR y bloqueos del entorno de build.
