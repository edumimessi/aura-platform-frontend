/// auth_service.dart — Autenticação com Supabase
///
/// Gerencia login, logout e estado de autenticação.
/// Firebase Messaging será adicionado na Fase 2 (push notifications).

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  /// Faz login com email e senha
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Erro ao fazer login: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Faz logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Retorna o usuário atual
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Retorna o token JWT atual (para enviar ao backend)
  String? getCurrentToken() {
    return _supabase.auth.currentSession?.accessToken;
  }

  /// Stream de mudanças de estado de autenticação
  Stream<AuthState> authStateChanges() {
    return _supabase.auth.onAuthStateChange;
  }
}
