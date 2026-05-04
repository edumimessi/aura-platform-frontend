/// supabase_config.dart — Configuração do Supabase e API
///
/// Armazena as constantes de conexão com o Supabase e o backend FastAPI.
/// Em produção, use flutter_dotenv para não expor valores no código.
///
/// IMPORTANTE:
/// - A ANON KEY é segura para o frontend (chave pública).
/// - O backend usa a SERVICE_KEY (nunca exposta no app).
class SupabaseConfig {
  /// URL do projeto Supabase
  static const String supabaseUrl = 'https://ugabpfpzcpolfodtupmg.supabase.co';

  /// Anon Key — chave pública, segura para o app
  /// Encontre em: Supabase → Settings → API → Project API keys → anon/public
  static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';

  /// URL base da API FastAPI
  ///
  /// Desenvolvimento local no computador (web/desktop):
  ///   'http://localhost:8000'
  ///
  /// Emulador Android (10.0.2.2 aponta para o host no Android):
  ///   'http://10.0.2.2:8000'
  ///
  /// Dispositivo físico (use o IP da sua máquina na rede local):
  ///   'http://192.168.X.X:8000'
  ///
  /// Produção (quando o backend estiver deployado):
  ///   'https://api.aura.com.br'
  static const String apiBaseUrl = 'http://10.0.2.2:8000';
}
