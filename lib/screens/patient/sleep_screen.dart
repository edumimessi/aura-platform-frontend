/// sleep_screen.dart — Tela de Registro de Sono
///
/// Permite ao paciente registrar qualidade do sono, horários,
/// duração e marcadores clínicos (insônia, pesadelos, medicação).
import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;

  // Horários
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeTime;

  // Qualidade (1-5)
  int _qualityScore = 3;

  // Marcadores clínicos
  bool _hadNightmares = false;
  bool _hadInsomnia = false;
  bool _usedSleepMedication = false;

  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Calcula duração em minutos a partir dos horários
  int? _calculateDuration() {
    if (_sleepTime == null || _wakeTime == null) return null;
    final sleepMinutes = _sleepTime!.hour * 60 + _sleepTime!.minute;
    final wakeMinutes = _wakeTime!.hour * 60 + _wakeTime!.minute;
    // Considera dormir antes da meia-noite e acordar depois
    final diff = wakeMinutes >= sleepMinutes
        ? wakeMinutes - sleepMinutes
        : (24 * 60 - sleepMinutes) + wakeMinutes;
    return diff;
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return 'Não informado';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final data = {
        if (_sleepTime != null)
          'sleep_time': '${_sleepTime!.hour.toString().padLeft(2, '0')}:${_sleepTime!.minute.toString().padLeft(2, '0')}:00',
        if (_wakeTime != null)
          'wake_time': '${_wakeTime!.hour.toString().padLeft(2, '0')}:${_wakeTime!.minute.toString().padLeft(2, '0')}:00',
        'duration_minutes': _calculateDuration(),
        'quality_score': _qualityScore,
        'had_nightmares': _hadNightmares,
        'had_insomnia': _hadInsomnia,
        'used_sleep_medication': _usedSleepMedication,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };

      await _apiService.createModuleRecord('sleep', data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de sono salvo!'),
            backgroundColor: Color(0xFF2196F3),
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
    final duration = _calculateDuration();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Sono'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horários
            const Text('Horários', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TimePickerCard(
                    label: 'Dormi às',
                    value: _formatTime(_sleepTime),
                    icon: Icons.bedtime_outlined,
                    color: const Color(0xFF2196F3),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 22, minute: 0),
                      );
                      if (t != null) setState(() => _sleepTime = t);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimePickerCard(
                    label: 'Acordei às',
                    value: _formatTime(_wakeTime),
                    icon: Icons.wb_sunny_outlined,
                    color: const Color(0xFFFF9800),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 7, minute: 0),
                      );
                      if (t != null) setState(() => _wakeTime = t);
                    },
                  ),
                ),
              ],
            ),

            // Duração calculada
            if (duration != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Duração: ${duration ~/ 60}h ${duration % 60}min',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Qualidade do sono
            const Text('Qualidade do sono', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final val = i + 1;
                final labels = ['Péssimo', 'Ruim', 'Regular', 'Bom', 'Ótimo'];
                final colors = [Colors.red, Colors.orange, Colors.yellow[700]!, Colors.lightGreen, Colors.green];
                return GestureDetector(
                  onTap: () => setState(() => _qualityScore = val),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _qualityScore == val ? colors[i] : Colors.grey[200],
                        child: Text(
                          '$val',
                          style: TextStyle(
                            color: _qualityScore == val ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(labels[i], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Marcadores clínicos
            const Text('Marcadores clínicos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ClinicalToggle(
              label: 'Tive pesadelos',
              value: _hadNightmares,
              onChanged: (v) => setState(() => _hadNightmares = v),
            ),
            _ClinicalToggle(
              label: 'Tive insônia / acordei várias vezes',
              value: _hadInsomnia,
              onChanged: (v) => setState(() => _hadInsomnia = v),
            ),
            _ClinicalToggle(
              label: 'Usei medicação para dormir',
              value: _usedSleepMedication,
              onChanged: (v) => setState(() => _usedSleepMedication = v),
            ),

            const SizedBox(height: 24),

            // Observações
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Como foi seu sono? Algo relevante?',
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
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

class _TimePickerCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TimePickerCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ClinicalToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ClinicalToggle({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF2196F3),
      contentPadding: EdgeInsets.zero,
    );
  }
}
