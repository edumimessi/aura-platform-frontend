/// main.dart — Ponto de entrada da aplicação AURA
///
/// Inicializa Supabase e define o roteamento inicial.
/// Fluxo: Login → Verificar consentimento LGPD → Home

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura_app/config/supabase_config.dart';
import 'package:aura_app/screens/login_screen.dart';
import 'package:aura_app/screens/consent_screen.dart';
import 'package:aura_app/screens/patient/home_screen.dart';
import 'package:aura_app/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

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

/// _AuthGate — Triagem de autenticação e consentimento LGPD
///
/// Fluxo:
/// 1. Sem sessão → LoginScreen
/// 2. Com sessão, sem consentimento → ConsentScreen
/// 3. Com sessão e consentimento aceito → PatientHomeScreen
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
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return const LoginScreen();
        }

        // Autenticado — verificar se já aceitou o consentimento LGPD
        return FutureBuilder<bool>(
          future: ApiService().hasActiveConsent(),
          builder: (context, consentSnapshot) {
            if (consentSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                ),
              );
            }

            final hasConsent = consentSnapshot.data ?? false;

            if (!hasConsent) {
              // Primeiro acesso — mostrar termo de consentimento LGPD
              return const ConsentScreen();
            }

            // Tudo certo — ir para home
            return const PatientHomeScreen();
          },
        );
      },
    );
  }
}
