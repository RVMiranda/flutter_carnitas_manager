/// Tipos de fallos que pueden ocurrir en la aplicación.
///
/// Esta jerarquía permite que la UI muestre mensajes amigables
/// sin exponer detalles técnicos internos al usuario.
sealed class Failure {
  const Failure(this.message, {this.technicalDetails});

  /// Mensaje amigable para mostrar al usuario.
  final String message;

  /// Detalles técnicos para logs (nunca mostrar directamente al usuario).
  final String? technicalDetails;

  @override
  String toString() => 'Failure(${runtimeType.toString()}, "$message")';
}

// ── Fallos de red / conectividad ─────────────────────────────────────────────

/// El dispositivo no tiene conexión a internet.
final class NetworkFailure extends Failure {
  const NetworkFailure({String? technicalDetails})
    : super(
        'Sin conexión a internet. La operación se guardará y se sincronizará cuando recuperes señal.',
        technicalDetails: technicalDetails,
      );
}

/// Error al comunicarse con el servidor remoto.
final class ServerFailure extends Failure {
  const ServerFailure({String? technicalDetails})
    : super(
        'Error al conectar con el servidor. Intenta de nuevo en un momento.',
        technicalDetails: technicalDetails,
      );
}

// ── Fallos de autenticación ───────────────────────────────────────────────────

/// Las credenciales de acceso son incorrectas.
final class AuthFailure extends Failure {
  const AuthFailure({String? technicalDetails})
    : super(
        'Credenciales incorrectas. Verifica tu correo y contraseña.',
        technicalDetails: technicalDetails,
      );
}

/// La sesión del usuario ha expirado.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure()
    : super('Tu sesión ha expirado. Por favor inicia sesión de nuevo.');
}

/// El usuario no tiene permisos para realizar esta acción.
final class PermissionFailure extends Failure {
  const PermissionFailure({String? technicalDetails})
    : super(
        'No tienes permisos para realizar esta acción.',
        technicalDetails: technicalDetails,
      );
}

// ── Fallos de base de datos local ─────────────────────────────────────────────

/// Error al leer o escribir en la base de datos local.
final class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({String? technicalDetails})
    : super(
        'Error al guardar la información localmente.',
        technicalDetails: technicalDetails,
      );
}

// ── Fallos de negocio ────────────────────────────────────────────────────────

/// Stock insuficiente para completar la operación.
final class InsufficientStockFailure extends Failure {
  const InsufficientStockFailure({
    required String productName,
    required int available,
  }) : super('Stock insuficiente de "$productName". Disponible: $available');
}

/// La orden ya fue cerrada o cancelada.
final class OrderClosedFailure extends Failure {
  const OrderClosedFailure()
    : super('Esta orden ya fue cerrada o cancelada y no puede modificarse.');
}

/// Intento de cobrar un monto mayor al pendiente.
final class ExceedsOrderTotalFailure extends Failure {
  const ExceedsOrderTotalFailure()
    : super('El monto a cobrar supera el total pendiente de la orden.');
}

/// El corte de caja ya fue realizado para esta fecha.
final class CashRegisterAlreadyClosedFailure extends Failure {
  const CashRegisterAlreadyClosedFailure()
    : super('El corte de caja de hoy ya fue realizado.');
}

/// La visita del cliente ya fue registrada hoy.
final class VisitAlreadyRegisteredFailure extends Failure {
  const VisitAlreadyRegisteredFailure()
    : super('Ya se registró una visita para este cliente hoy.');
}

/// No se encontró el recurso solicitado.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(String resourceName)
    : super('No se encontró: $resourceName');
}

/// Validación de formulario fallida.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Fallo desconocido o inesperado.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String? technicalDetails})
    : super(
        'Ocurrió un error inesperado. Por favor intenta de nuevo.',
        technicalDetails: technicalDetails,
      );
}
