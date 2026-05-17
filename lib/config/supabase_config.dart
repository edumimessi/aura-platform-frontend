/// supabase_config.dart — Configuração do Supabase e API
///
/// Valores sensíveis e URLs por ambiente devem ser passados com --dart-define.
/// Exemplo:
/// flutter run --dart-define=SUPABASE_ANON_KEY=sua-chave --dart-define=API_BASE_URL=http://localhost:8000
class SupabaseConfig {
  /// URL do projeto Supabase.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ugabpfpzcpolfodtupmg.supabase.co',
  );

  /// Anon Key pública do Supabase.
  /// Não use a SERVICE_KEY no app.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// URL base da API FastAPI.
  ///
  /// Web/desktop local: http://localhost:8000
  /// Emulador Android: http://10.0.2.2:8000
  /// Dispositivo físico: http://IP_DA_MAQUINA:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static bool get isSupabaseConfigured => supabaseAnonKey.isNotEmpty;
}
