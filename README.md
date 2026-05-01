# AURA Platform — Frontend (Flutter)

App mobile e web de acompanhamento psiquiátrico ambulatorial.

## Estrutura do Projeto

```
aura-platform-frontend/
├── lib/
│   ├── main.dart                        # Ponto de entrada
│   ├── config/
│   │   └── supabase_config.dart         # Configuração de conexões
│   ├── models/
│   │   ├── mood_record.dart             # Modelo de humor
│   │   └── crisis_record.dart          # Modelo de crise
│   ├── services/
│   │   ├── auth_service.dart            # Autenticação Supabase
│   │   ├── api_service.dart             # Chamadas ao backend
│   │   ├── local_storage_service.dart   # SQLite (offline)
│   │   └── sync_service.dart            # Sincronização offline
│   ├── screens/
│   │   ├── login_screen.dart            # Tela de login
│   │   ├── patient/
│   │   │   ├── home_screen.dart         # Home do paciente
│   │   │   ├── mood_screen.dart         # Registro de humor
│   │   │   └── crisis_screen.dart      # Registro de crise
│   │   └── doctor/                     # (Em desenvolvimento)
│   └── widgets/                        # (Em desenvolvimento)
├── pubspec.yaml
├── .gitignore
└── README.md
```

## Instalação

### 1. Pré-requisitos

- Flutter SDK 3.0+
- Android Studio ou VS Code
- Dispositivo Android/iOS ou emulador

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

Edite `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://SEU_PROJETO.supabase.co';
  static const String supabaseAnonKey = 'SUA_ANON_KEY';
  static const String apiBaseUrl = 'http://SEU_BACKEND:8000';
}
```

### 5. Executar o app

```bash
# Android/iOS
flutter run

# Web (dashboard médico)
flutter run -d chrome
```

## Módulos Implementados

| Módulo | Status |
|--------|--------|
| Login / Autenticação | ✅ Implementado |
| Registro de Humor | ✅ Implementado |
| Registro de Crise | ✅ Implementado |
| Sincronização Offline | ✅ Implementado |
| Medicações | 🔄 Em desenvolvimento |
| Sono | 🔄 Em desenvolvimento |
| Exercícios | 🔄 Em desenvolvimento |
| Meditação | 🔄 Em desenvolvimento |
| Dashboard Médico | 🔄 Em desenvolvimento |
| Alertas Push | 🔄 Em desenvolvimento |

## Arquitetura

O app segue o padrão **offline-first**:

1. Dados são salvos localmente (SQLite) imediatamente.
2. Quando há internet, o app sincroniza com o backend.
3. Isso garante funcionamento mesmo sem conexão.

## Segurança

- ✅ Autenticação via Supabase Auth (JWT)
- ✅ Token JWT enviado em todas as requisições
- ✅ Dados sensíveis não armazenados em texto plano
- ✅ Firebase credentials não commitadas

## Próximos Passos

- [ ] Implementar tela de medicações
- [ ] Implementar tela de sono
- [ ] Implementar tela de exercícios
- [ ] Implementar tela de meditação
- [ ] Implementar dashboard do médico
- [ ] Integrar Firebase Cloud Messaging
- [ ] Implementar gráficos de tendência
- [ ] Adicionar testes de widget

## Contribuindo

1. Crie uma branch: `git checkout -b feature/minha-feature`
2. Commit: `git commit -am 'Adiciona minha feature'`
3. Push: `git push origin feature/minha-feature`
4. Abra um Pull Request

## Licença

MIT
