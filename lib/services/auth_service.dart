import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Login con email y password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Registro con email y password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Stream de cambios de auth
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // Verificar si está autenticado
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }
}
