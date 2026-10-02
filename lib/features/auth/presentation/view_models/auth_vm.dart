import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:exquisssita_manager/core/errors/failure.dart';
import 'package:exquisssita_manager/core/logging/app_logger.dart';
import 'package:exquisssita_manager/core/result/result.dart';
import 'package:exquisssita_manager/core/permissions/permission.dart';

export 'package:exquisssita_manager/core/permissions/permission.dart'
    show AppRole;

part 'auth_vm.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Estado de autenticación
// ─────────────────────────────────────────────────────────────────────────────

/// Stream del usuario autenticado actualmente.
///
/// Emite null si no hay sesión activa.
/// El router lo escucha para aplicar guards de navegación.
@riverpod
Stream<User?> authState(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    AppLogger.debug('Auth state: ${event.event}', tag: 'Auth');
    return event.session?.user;
  });
}

/// Usuario actualmente autenticado.
///
/// Retorna null si no hay sesión.
@riverpod
User? currentUser(Ref ref) {
  return Supabase.instance.client.auth.currentUser;
}

/// Rol administrativo consultado desde [public.user_roles].
///
/// No se utiliza user_metadata ni app_metadata para autorización en Flutter.
/// Si el usuario no tiene una fila válida, se aplica el mínimo privilegio:
/// [AppRole.employee]. El backend/RLS sigue siendo la autoridad final.
final currentUserRoleProvider = FutureProvider<AppRole>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  if (authState == null) return AppRole.employee;

  try {
    final row = await Supabase.instance.client
        .from('user_roles')
        .select('role')
        .eq('user_id', authState.id)
        .maybeSingle();

    return switch (row?['role']) {
      'admin' => AppRole.admin,
      _ => AppRole.employee,
    };
  } on PostgrestException catch (e, st) {
    AppLogger.error(
      'No fue posible consultar el rol administrativo',
      tag: 'Auth',
      error: e,
      stackTrace: st,
    );
    return AppRole.employee;
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// ViewModel de autenticación
// ─────────────────────────────────────────────────────────────────────────────

/// Estado del proceso de login.
class AuthLoginState {
  const AuthLoginState({this.isLoading = false, this.failure});

  final bool isLoading;
  final Failure? failure;

  bool get hasError => failure != null;

  AuthLoginState copyWith({
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AuthLoginState(
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthLoginState build() => const AuthLoginState();

  /// Inicia sesión con email y contraseña.
  ///
  /// Retorna [Result.ok] en caso de éxito o [Result.err] si falla.
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        const failure = AuthFailure();
        state = state.copyWith(isLoading: false, failure: failure);
        return const Result.err(AuthFailure());
      }

      AppLogger.info('Usuario autenticado', tag: 'Auth');
      state = state.copyWith(isLoading: false);
      return Result.ok(response.user!);
    } on AuthException catch (e) {
      AppLogger.warning(
        'Error de autenticación: ${e.message}',
        tag: 'Auth',
        error: e,
      );
      final failure = AuthFailure(technicalDetails: e.message);
      state = state.copyWith(isLoading: false, failure: failure);
      return Result.err(failure);
    } catch (e, st) {
      AppLogger.error(
        'Error inesperado en login',
        tag: 'Auth',
        error: e,
        stackTrace: st,
      );
      final failure = UnexpectedFailure(technicalDetails: e.toString());
      state = state.copyWith(isLoading: false, failure: failure);
      return Result.err(failure);
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      AppLogger.info('Sesión cerrada', tag: 'Auth');
    } catch (e) {
      AppLogger.error('Error al cerrar sesión', tag: 'Auth', error: e);
    }
  }

  /// Limpia el error del estado actual.
  void clearError() {
    state = state.copyWith(clearFailure: true);
  }
}
