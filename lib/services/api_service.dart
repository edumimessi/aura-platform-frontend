/// api_service.dart — Chamadas à API FastAPI
///
/// Centraliza todas as chamadas HTTP ao backend.
/// Usa o token JWT do Supabase para autenticação.

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura_app/config/supabase_config.dart';
import 'dart:convert';

class ApiService {
  final _supabase = Supabase.instance.client;
  final String _baseUrl = SupabaseConfig.apiBaseUrl;

  /// Obtém o token JWT atual do Supabase
  Future<String> _getToken() async {
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('Usuário não autenticado');
    return session.accessToken;
  }

  /// Headers padrão com autenticação
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // MOOD RECORDS
  // ============================================================

  Future<Map<String, dynamic>> createMoodRecord(
      Map<String, dynamic> data) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/logs/mood'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao criar registro de humor: ${response.body}');
    }
  }

  Future<List<dynamic>> getMoodRecords(String patientId,
      {int days = 30}) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/logs/mood/$patientId?days=$days'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar registros: ${response.body}');
    }
  }

  // ============================================================
  // CRISIS RECORDS
  // ============================================================

  Future<Map<String, dynamic>> createCrisisRecord(
      Map<String, dynamic> data) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/logs/crisis'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao criar registro de crise: ${response.body}');
    }
  }

  // ============================================================
  // MÓDULOS GENÉRICOS (sono, exercício, meditação, dieta, sintomas, medicação)
  // ============================================================

  /// Cria um registro para qualquer módulo via endpoint genérico.
  /// [module] pode ser: 'sleep', 'exercise', 'meditation', 'diet', 'symptoms', 'medications'
  Future<Map<String, dynamic>> createModuleRecord(
      String module, Map<String, dynamic> data) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/modules/$module'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao criar registro de $module: ${response.body}');
    }
  }

  /// Busca registros de qualquer módulo por paciente
  Future<List<dynamic>> getModuleRecords(String module, String patientId,
      {int days = 30}) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/modules/$module/$patientId?days=$days'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar registros de $module: ${response.body}');
    }
  }

  // ============================================================
  // CONSENTIMENTO LGPD
  // ============================================================

  /// Verifica se o usuário já tem consentimento ativo registrado
  Future<bool> hasActiveConsent() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/consent/status'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['has_active_consent'] == true;
      }
      return false;
    } catch (e) {
      // Em caso de erro de conexão (ex: backend offline), não bloquear o usuário
      // mas registrar o problema
      return false;
    }
  }

  /// Registra o aceite do consentimento LGPD
  Future<Map<String, dynamic>> registerConsent(
      Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/consent'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao registrar consentimento: ${response.body}');
    }
  }

  // ============================================================
  // DEVICE REGISTRATION
  // ============================================================

  Future<Map<String, dynamic>> registerDevice(
      Map<String, dynamic> data) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/devices/register'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao registrar dispositivo: ${response.body}');
    }
  }
}
