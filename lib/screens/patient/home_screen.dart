/// home_screen.dart — Tela Principal do Paciente
///
/// Exibe os módulos ativos e o status de adesão do dia.
/// Permite acesso rápido a cada módulo de registro.

import 'package:flutter/material.dart';
import 'package:aura_app/screens/patient/mood_screen.dart';
import 'package:aura_app/screens/patient/crisis_screen.dart';
import 'package:aura_app/screens/patient/sleep_screen.dart';
import 'package:aura_app/screens/patient/exercise_screen.dart';
import 'package:aura_app/screens/patient/meditation_screen.dart';
import 'package:aura_app/screens/patient/diet_screen.dart';
import 'package:aura_app/screens/patient/medication_screen.dart';
import 'package:aura_app/screens/patient/symptom_screen.dart';
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
        title: const Text('AURA', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
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
              'Olá, ${user?.email?.split('@')[0] ?? 'Paciente'} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Como você está hoje?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Módulos do dia
            const Text(
              'Registros do Dia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Grid de módulos — todos os 7 módulos ativos
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MedicationScreen()),
                  ),
                ),
                _ModuleCard(
                  title: 'Sono',
                  icon: Icons.bedtime_outlined,
                  color: const Color(0xFF2196F3),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SleepScreen()),
                  ),
                ),
                _ModuleCard(
                  title: 'Exercícios',
                  icon: Icons.fitness_center_outlined,
                  color: const Color(0xFFFF9800),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExerciseScreen()),
                  ),
                ),
                _ModuleCard(
                  title: 'Meditação',
                  icon: Icons.self_improvement,
                  color: const Color(0xFF9C27B0),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MeditationScreen()),
                  ),
                ),
                _ModuleCard(
                  title: 'Dieta',
                  icon: Icons.restaurant_outlined,
                  color: const Color(0xFF009688),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DietScreen()),
                  ),
                ),
                _ModuleCard(
                  title: 'Sintomas',
                  icon: Icons.monitor_heart_outlined,
                  color: const Color(0xFFE91E63),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SymptomScreen()),
                  ),
                ),
                _ModuleCard(
                  title: 'Histórico',
                  icon: Icons.history,
                  color: const Color(0xFF607D8B),
                  onTap: () {
                    // TODO: Fase 2 — tela de histórico longitudinal
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Histórico disponível em breve')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botão de crise — sempre visível e destacado
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                title: const Text(
                  'Registrar Crise',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Toque aqui se estiver em sofrimento intenso',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrisisScreen()),
                ),
              ),
            ),

            const SizedBox(height: 16),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
