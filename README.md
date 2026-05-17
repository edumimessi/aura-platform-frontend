# AURA Platform — Frontend (Flutter)

App mobile e web de acompanhamento psiquiátrico ambulatorial.

## Instalação

### 1. Pré-requisitos

- Flutter SDK 3.0+
- Android Studio ou VS Code
- Dispositivo Android/iOS, emulador ou Chrome para web

### 2. Clonar o repositório

```bash
git clone https://github.com/edumimessi/aura-platform-frontend.git
cd aura-platform-frontend
```

### 3. Instalar dependências

```bash
flutter pub get
```

### 4. Configurar credenciais

O app lê configuração por `--dart-define`, sem colocar chaves diretamente no código.

Variáveis suportadas:

- `SUPABASE_URL`: URL do projeto Supabase. Se omitida, usa o projeto atual configurado em `SupabaseConfig`.
- `SUPABASE_ANON_KEY`: chave anon/public do Supabase. Obrigatória para login.
- `API_BASE_URL`: URL do backend FastAPI. Se omitida, usa `http://10.0.2.2:8000`, útil para emulador Android.

Exemplo web/local:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY \
  --dart-define=API_BASE_URL=http://localhost:8000
```

Exemplo Android/emulador:

```bash
flutter run \
  --dart-define=SUPABASE_ANON_KEY=SUA_ANON_KEY \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Se `SUPABASE_ANON_KEY` não for informada, o app mostra uma tela de configuração em vez de tentar inicializar o Supabase com valor inválido.

## Estrutura do Projeto

```text
aura-platform-frontend/
├── assets/
│   ├── icons/
│   └── images/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   └── supabase_config.dart
│   ├── models/
│   │   ├── mood_record.dart
│   │   └── crisis_record.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── api_service.dart
│   │   ├── local_storage_service.dart
│   │   └── sync_service.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── consent_screen.dart
│       ├── doctor/
│       └── patient/
├── test/
├── pubspec.yaml
└── README.md
```

## Arquitetura

O app usa autenticação Supabase e sincronização offline-first nos registros críticos de humor, crise e medicação pendente:

1. Dados críticos são salvos localmente no SQLite.
2. A sincronização converte o formato local antes de enviar para a API.
3. Registros com falha permanecem marcados como pendentes e guardam `sync_error` para nova tentativa.

Alguns módulos complementares ainda enviam direto para a API e devem ser migrados para o mesmo padrão offline-first nas próximas etapas.

## Segurança

- Autenticação via Supabase Auth (JWT)
- Token JWT enviado nas requisições ao backend
- Chave Supabase anon configurada por ambiente
- Service key nunca deve ser usada no app
- Firebase credentials não commitadas

## Próximos Passos

- [ ] Migrar sono, exercício, meditação, dieta e sintomas para SQLite + SyncService
- [ ] Buscar medicações e sintomas reais do backend em vez de dados mockados
- [ ] Adicionar runners Flutter completos (`android/`, `ios/`, `web/`) quando o alvo de build for definido
- [ ] Integrar Firebase Cloud Messaging
- [ ] Implementar gráficos de tendência
- [ ] Expandir testes de widget e integração

## Licença

MIT
