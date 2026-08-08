import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/network/result.dart';
import '../models/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<AppUser>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> logout();

  Future<Result<void>> resetPassword({required String email});
}

// AuthRepository Impl
class AuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient _supabaseClient;
  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Failure('Login failed. Please check your credentials.');
      }

      return Success(AppUser.fromSupabaseUser(response.user!));
    } on supabase.AuthException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure('An unexpected error occurred.');
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _supabaseClient.auth.signOut();
      return Success(null);
    } catch (e) {
      return Failure('Failed to log out.');
    }
  }

  @override
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
      return Success(null);
    } on supabase.AuthApiException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure("An unexpected error occurred.");
    }
  }

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'name': name},
      );
      if (response.user == null) {
        return Failure('Sign up failed. Please try again.');
      }
      return Success(AppUser.fromSupabaseUser(response.user!));
    } on supabase.AuthApiException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure("An unexpected error occurred.");
    }
  }
}
