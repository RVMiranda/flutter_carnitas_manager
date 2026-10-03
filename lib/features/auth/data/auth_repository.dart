import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exquisssita_manager/core/errors/failure.dart';

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;
  Future<User> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(email: email.trim(), password: password);
      final user = response.user;
      if (user == null) throw const AuthFailure();
      return user;
    } on AuthException catch (error) { throw AuthFailure(technicalDetails: error.message); }
    on PostgrestException catch (error) { throw ServerFailure(technicalDetails: error.message); }
    catch (error) { throw UnexpectedFailure(technicalDetails: error.toString()); }
  }
  Future<void> signOut() async { try { await _client.auth.signOut(); } catch (error) { throw ServerFailure(technicalDetails: error.toString()); } }
}

class RoleRepository {
  RoleRepository(this._client);
  final SupabaseClient _client;
  Future<String> roleFor(String userId) async {
    try { final row = await _client.from('user_roles').select('role').eq('user_id', userId).maybeSingle(); return row?['role'] as String? ?? 'employee'; }
    on PostgrestException catch (error) { throw ServerFailure(technicalDetails: error.message); }
    catch (error) { throw UnexpectedFailure(technicalDetails: error.toString()); }
  }
}
