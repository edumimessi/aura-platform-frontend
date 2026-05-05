/// meditation_screen.dart — Tela de Registro de Meditação
///
/// Permite ao paciente registrar a prática de meditação prescrita:
/// técnica, duração e foco percebido.
import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;

  String? _technique;
  int _durationMinutes = 10;
  int _focusScore = 3;

  final _notesController = TextEditingController();

  final List<String> _techniques = [
    'Respiração diafragmática',
    'Mindfulness',
    'Body scan',
    'Meditação guiada',
    'Visualização',
    'Mantra',
    'Outra',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_technique == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a técnica utilizada')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'technique': _technique,
        'duration_minutes': _durationMinutes,
        'focus_score': _focusScore,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };

      await _apiService.createModuleRecord('meditation', data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de meditação salvo!'),
            backgroundColor: Color(0xFF9C27B0),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Meditação'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Técnica
            const Text('Técnica utilizada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _techniques.map((t) {
                final isSelected = _technique == t;
                return GestureDetector(
                  onTap: () => setState(() => _technique = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF9C27B0) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF9C27B0) : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Duração
            const Text('Duração', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_durationMinutes > 5) setState(() => _durationMinutes -= 5);
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 32, color: Color(0xFF9C27B0)),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      '$_durationMinutes',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
                    ),
                    const Text('minutos', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() => _durationMinutes += 5),
                  icon: const Icon(Icons.add_circle_outline, size: 32, color: Color(0xFF9C27B0)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Foco percebido
            const Text('Nível de foco percebido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Muito disperso', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Muito focado', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            Slider(
              value: _focusScore.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: const Color(0xFF9C27B0),
              label: ['', 'Disperso', 'Pouco foco', 'Regular', 'Bom foco', 'Muito focado'][_focusScore],
              onChanged: (v) => setState(() => _focusScore = v.round()),
            ),
            Center(
              child: Text(
                ['', 'Disperso', 'Pouco foco', 'Regular', 'Bom foco', 'Muito focado'][_focusScore],
                style: const TextStyle(color: Color(0xFF9C27B0), fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 24),

            // Observações
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Como foi a prática? Algo relevante?',
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Salvar Registro', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
