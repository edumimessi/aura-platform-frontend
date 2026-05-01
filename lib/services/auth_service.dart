/// auth_service.dart — Autenticação com Supabase
///
/// Gerencia login, logout e registro de dispositivos (FCM).
/// Após login bem-sucedido, registra o FCM token do dispositivo.

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class AuthService {
  final _supabase = Supabase.instance.client;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _deviceInfo = DeviceInfoPlugin();

  /// Faz login com email e senha
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Após login bem-sucedido, registrar FCM token
      if (response.user != null) {
        await _registerFcmToken();
      }

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

  /// Registra o FCM token do dispositivo no backend
  Future<void> _registerFcmToken() async {
    try {
      // Solicitar permissão de notificações
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken == null) return;

        final deviceName = await _getDeviceName();
        final platform = Platform.isIOS ? 'ios' : 'android';

        // TODO: Chamar API para registrar o dispositivo
        // await ApiService().registerDevice({
        //   'fcm_token': fcmToken,
        //   'platform': platform,
        //   'device_name': deviceName,
        // });
      }
    } catch (e) {
      // Não falha o login se o FCM falhar
      print('Aviso: erro ao registrar FCM token: $e');
    }
  }

  /// Obtém o nome do dispositivo
  Future<String> _getDeviceName() async {
    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.name;
      } else {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.model;
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }
}
