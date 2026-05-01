/// mood_screen.dart — Tela de Registro de Humor
///
/// Permite ao paciente registrar seu humor diário.
/// Salva localmente (SQLite) e sincroniza com o backend.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:aura_app/services/local_storage_service.dart';
import 'package:aura_app/services/sync_service.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int _selectedScore = 5;
  final List<String> _selectedEmotions = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  final List<Map<String, dynamic>> _emotions = [
    {'label': 'Ansioso', 'icon': '😰'},
    {'label': 'Triste', 'icon': '😢'},
    {'label': 'Irritável', 'icon': '😠'},
    {'label': 'Esperançoso', 'icon': '🌟'},
    {'label': 'Calmo', 'icon': '😌'},
    {'label': 'Energizado', 'icon': '⚡'},
    {'label': 'Cansado', 'icon': '😴'},
    {'label': 'Confuso', 'icon': '😕'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Retorna a cor correspondente ao score de humor
  Color _getMoodColor(int score) {
    if (score <= 2) return Colors.red;
    if (score <= 4) return Colors.orange;
    if (score <= 6) return Colors.yellow.shade700;
    if (score <= 8) return Colors.lightGreen;
    return Colors.green;
  }

  /// Retorna o emoji correspondente ao score de humor
  String _getMoodEmoji(int score) {
    if (score <= 2) return '😢';
    if (score <= 4) return '😕';
    if (score <= 6) return '😐';
    if (score <= 8) return '🙂';
    return '😄';
  }

  /// Salva o registro de humor
  Future<void> _saveMoodRecord() async {
    setState(() => _isSaving = true);

    try {
      final record = {
        'id': const Uuid().v4(),
        'patient_id': '', // Preenchido pelo backend
        'score': _selectedScore,
        'emotions': _selectedEmotions.join(','),
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'record_date': DateTime.now().toIso8601String().split('T')[0],
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      };

      // 1. Salvar localmente (offline-first)
      final localStorage = LocalStorageService();
      await localStorage.saveMoodRecord(record);

      // 2. Tentar sincronizar com o backend
      final syncService = SyncService();
      await syncService.syncPendingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Humor do Dia'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji e score
            Center(
              child: Column(
                children: [
                  Text(
                    _getMoodEmoji(_selectedScore),
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedScore.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getMoodColor(_selectedScore),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Slider de humor
            const Text(
              'Como você está se sentindo?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Muito mal', style: TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _selectedScore.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: _getMoodColor(_selectedScore),
                    label: _selectedScore.toString(),
                    onChanged: (value) {
                      setState(() => _selectedScore = value.toInt());
                    },
                  ),
                ),
                const Text('Excelente', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 24),

            // Seleção de emoções
            const Text(
              'Emoções identificadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emotions.map((emotion) {
                final label = emotion['label'] as String;
                final icon = emotion['icon'] as String;
                final isSelected = _selectedEmotions.contains(label);

                return FilterChip(
                  label: Text('$icon $label'),
                  selected: isSelected,
                  selectedColor:
                      const Color(0xFF6C63FF).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF6C63FF),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedEmotions.add(label);
                      } else {
                        _selectedEmotions.remove(label);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Campo de notas
            const Text(
              'Observações (opcional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Descreva como se sente, o que aconteceu hoje...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Botão de salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMoodRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Salvar Registro',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
