/// exercise_screen.dart — Tela de Registro de Exercício
///
/// Permite ao paciente registrar tipo, duração, intensidade
/// e como se sentiu após o exercício.
import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;

  String? _exerciseType;
  int? _durationMinutes;
  String? _intensity;
  int _moodAfter = 3;

  final _notesController = TextEditingController();
  final _durationController = TextEditingController();

  final List<Map<String, dynamic>> _exerciseTypes = [
    {'label': 'Caminhada', 'icon': Icons.directions_walk},
    {'label': 'Corrida', 'icon': Icons.directions_run},
    {'label': 'Musculação', 'icon': Icons.fitness_center},
    {'label': 'Yoga', 'icon': Icons.self_improvement},
    {'label': 'Natação', 'icon': Icons.pool},
    {'label': 'Ciclismo', 'icon': Icons.directions_bike},
    {'label': 'Outro', 'icon': Icons.sports},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_exerciseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de exercício')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'exercise_type': _exerciseType,
        if (_durationController.text.isNotEmpty)
          'duration_minutes': int.tryParse(_durationController.text),
        if (_intensity != null) 'intensity': _intensity,
        'mood_after': _moodAfter,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };

      await _apiService.createModuleRecord('exercise', data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de exercício salvo!'),
            backgroundColor: Color(0xFFFF9800),
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
        title: const Text('Registro de Exercício'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de exercício
            const Text('Tipo de exercício', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _exerciseTypes.map((e) {
                final isSelected = _exerciseType == e['label'];
                return GestureDetector(
                  onTap: () => setState(() => _exerciseType = e['label']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF9800) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF9800) : Colors.grey[300]!,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(e['icon'] as IconData, size: 16, color: isSelected ? Colors.white : Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          e['label'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Duração
            const Text('Duração (minutos)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Ex: 30',
                border: OutlineInputBorder(),
                suffixText: 'min',
              ),
            ),

            const SizedBox(height: 24),

            // Intensidade
            const Text('Intensidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                {'label': 'Leve', 'value': 'light', 'color': Colors.green},
                {'label': 'Moderada', 'value': 'moderate', 'color': Colors.orange},
                {'label': 'Intensa', 'value': 'intense', 'color': Colors.red},
              ].map((item) {
                final isSelected = _intensity == item['value'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _intensity = item['value'] as String),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? item['color'] as Color : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: (item['color'] as Color).withOpacity(0.5)),
                      ),
                      child: Text(
                        item['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Humor após exercício
            const Text('Como se sentiu após?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final val = i + 1;
                final emojis = ['😞', '😕', '😐', '🙂', '😄'];
                return GestureDetector(
                  onTap: () => setState(() => _moodAfter = val),
                  child: Column(
                    children: [
                      Text(emojis[i], style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _moodAfter == val ? const Color(0xFFFF9800) : Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Observações
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
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
