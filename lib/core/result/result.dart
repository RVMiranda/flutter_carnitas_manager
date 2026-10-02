import 'package:exquisssita_manager/core/errors/failure.dart';

/// Tipo Result para manejar éxito o fallo sin excepciones no controladas.
///
/// Uso:
/// ```dart
/// final result = await repository.getOrdenes();
/// switch (result) {
///   case Ok(:final value): // usar value
///   case Err(:final failure): // mostrar failure.message
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Crea un resultado exitoso con un valor.
  const factory Result.ok(T value) = Ok<T>;

  /// Crea un resultado de error con un Failure.
  const factory Result.err(Failure failure) = Err<T>;

  /// Retorna true si el resultado es exitoso.
  bool get isOk => this is Ok<T>;

  /// Retorna true si el resultado es un error.
  bool get isErr => this is Err<T>;

  /// Retorna el valor si es Ok, o null si es Err.
  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  /// Retorna el Failure si es Err, o null si es Ok.
  Failure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(:final failure) => failure,
  };

  /// Transforma el valor Ok aplicando [transform].
  /// Si es Err, propaga el error sin modificarlo.
  Result<U> map<U>(U Function(T value) transform) => switch (this) {
    Ok(:final value) => Result.ok(transform(value)),
    Err(:final failure) => Result.err(failure),
  };

  /// Ejecuta [onOk] si es Ok, o [onErr] si es Err.
  void when({
    required void Function(T value) onOk,
    required void Function(Failure failure) onErr,
  }) {
    switch (this) {
      case Ok(:final value):
        onOk(value);
      case Err(:final failure):
        onErr(failure);
    }
  }
}

/// Resultado exitoso que contiene un valor de tipo [T].
final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  String toString() => 'Ok($value)';
}

/// Resultado de error que contiene un [Failure].
final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  String toString() => 'Err(${failure.message})';
}
