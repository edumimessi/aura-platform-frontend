/// supabase_config.dart — Configuração do Supabase
///
/// Armazena as constantes de conexão com o Supabase.
/// Em produção, use variáveis de ambiente ou flutter_dotenv.
///
/// IMPORTANTE: A ANON KEY é segura para o frontend.
/// O backend usa a SERVICE_KEY (nunca exposta no app).

class SupabaseConfig {
  /// URL do projeto Supabase
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';

  /// Anon Key — chave pública, segura para o app
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  /// URL base da API FastAPI
  static const String apiBaseUrl = 'http://localhost:8000';
}
