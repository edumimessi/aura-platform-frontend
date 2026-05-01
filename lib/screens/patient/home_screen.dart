/// home_screen.dart — Tela Principal do Paciente
///
/// Exibe os módulos ativos e o status de adesão do dia.
/// Permite acesso rápido a cada módulo de registro.

import 'package:flutter/material.dart';
import 'package:aura_app/screens/patient/mood_screen.dart';
import 'package:aura_app/screens/patient/crisis_screen.dart';
import 'package:aura_app/services/auth_service.dart';
import 'package:aura_app/screens/login_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.getCurrentUser();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('AURA'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Text(
              'Olá, ${user?.email?.split('@')[0] ?? 'Paciente'}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Como você está hoje?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Módulos do dia
            const Text(
              'Registros do Dia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Grid de módulos
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _ModuleCard(
                  title: 'Humor',
                  icon: Icons.mood,
                  color: const Color(0xFF6C63FF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MoodScreen()),
                  ),
                ),
                _ModuleCard(
                  title: 'Medicações',
                  icon: Icons.medication_outlined,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    // TODO: Implementar tela de medicações
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Em desenvolvimento...')),
                    );
                  },
                ),
                _ModuleCard(
                  title: 'Sono',
                  icon: Icons.bedtime_outlined,
                  color: const Color(0xFF2196F3),
                  onTap: () {
                    // TODO: Implementar tela de sono
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Em desenvolvimento...')),
                    );
                  },
                ),
                _ModuleCard(
                  title: 'Exercícios',
                  icon: Icons.fitness_center_outlined,
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    // TODO: Implementar tela de exercícios
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Em desenvolvimento...')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botão de crise
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrisisScreen()),
                ),
                icon: const Icon(Icons.warning_amber_outlined,
                    color: Colors.red),
                label: const Text(
                  'Registrar Crise',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de módulo na tela principal
class _ModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
