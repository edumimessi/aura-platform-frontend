/// main.dart — Ponto de entrada da aplicação AURA
///
/// Inicializa Supabase, Firebase e define o roteamento inicial.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura_app/config/supabase_config.dart';
import 'package:aura_app/screens/login_screen.dart';
import 'package:aura_app/screens/patient/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // TODO: Inicializar Firebase quando as credenciais estiverem configuradas
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const _AuthGate(),
    );
  }
}

/// _AuthGate — Decide qual tela mostrar baseado no estado de autenticação
///
/// Analogia médica: é como a triagem — antes de entrar no sistema,
/// verificamos se o usuário já está autenticado ou precisa fazer login.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Enquanto carrega
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C63FF),
              ),
            ),
          );
        }

        // Verificar se há sessão ativa
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          // Usuário autenticado — ir para home
          return const PatientHomeScreen();
        } else {
          // Não autenticado — ir para login
          return const LoginScreen();
        }
      },
    );
  }
}
