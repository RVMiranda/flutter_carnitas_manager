import 'package:uuid/uuid.dart';

/// Utilidad para generar identificadores UUID v4.
///
/// Los UUIDs se generan localmente en el cliente Flutter, lo que permite
/// crear registros offline antes de sincronizar con Supabase.
///
/// La arquitectura Offline-First requiere IDs generados en el cliente
/// para poder establecer referencias entre entidades sin conectividad.
abstract final class UuidUtils {
  static const _uuid = Uuid();

  /// Genera un nuevo UUID v4 único.
  ///
  /// Es seguro llamarlo repetidamente; cada llamada produce un UUID diferente.
  static String generate() => _uuid.v4();

  /// Verifica si una cadena es un UUID v4 válido.
  static bool isValid(String value) {
    try {
      Uuid.isValidUUID(fromString: value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
