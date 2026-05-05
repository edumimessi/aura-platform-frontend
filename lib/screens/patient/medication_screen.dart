/// medication_screen.dart — Tela de Registro de Medicações
///
/// Permite ao paciente registrar se tomou, esqueceu ou pulou
/// cada medicação prescrita. Dados críticos para adesão ao tratamento.
import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;

  // Mapa de medication_id → status selecionado
  final Map<String, String> _medicationStatus = {};
  final Map<String, String?> _skipReasons = {};

  // Medicações de exemplo (em produção virão da API via patient_modules)
  final List<Map<String, dynamic>> _medications = [
    {'id': 'med_1', 'name': 'Sertralina 50mg', 'time': 'Manhã'},
    {'id': 'med_2', 'name': 'Clonazepam 0,5mg', 'time': 'Noite'},
    {'id': 'med_3', 'name': 'Quetiapina 25mg', 'time': 'Noite'},
  ];

  final Map<String, TextEditingController> _reasonControllers = {};

  @override
  void initState() {
    super.initState();
    for (final med in _medications) {
      _medicationStatus[med['id']] = 'pending';
      _reasonControllers[med['id']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _reasonControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final pending = _medicationStatus.values.where((s) => s == 'pending').length;
    if (pending > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Medicações pendentes'),
          content: Text('$pending medicação(ões) ainda não foram registradas. Deseja salvar assim mesmo?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Salvar')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isLoading = true);
    try {
      for (final med in _medications) {
        final status = _medicationStatus[med['id']] ?? 'pending';
        if (status == 'pending') continue;

        final data = {
          'medication_id': med['id'],
          'status': status,
          if (status == 'skipped' || status == 'missed')
            'skip_reason': _reasonControllers[med['id']]?.text.isNotEmpty == true
                ? _reasonControllers[med['id']]!.text
                : null,
        };

        await _apiService.createModuleRecord('medications', data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registros de medicação salvos!'),
            backgroundColor: Color(0xFF4CAF50),
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
        title: const Text('Medicações'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medications.length,
              itemBuilder: (context, index) {
                final med = _medications[index];
                final status = _medicationStatus[med['id']] ?? 'pending';
                return _MedicationCard(
                  name: med['name'],
                  time: med['time'],
                  status: status,
                  reasonController: _reasonControllers[med['id']]!,
                  onStatusChanged: (s) => setState(() => _medicationStatus[med['id']] = s),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Salvar Registros', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final String name;
  final String time;
  final String status;
  final TextEditingController reasonController;
  final ValueChanged<String> onStatusChanged;

  const _MedicationCard({
    required this.name,
    required this.time,
    required this.status,
    required this.reasonController,
    required this.onStatusChanged,
  });

  Color get _statusColor {
    switch (status) {
      case 'taken': return Colors.green;
      case 'missed': return Colors.red;
      case 'skipped': return Colors.orange;
      case 'delayed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: _statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Botões de status
            Row(
              children: [
                _StatusButton(label: '✅ Tomei', value: 'taken', current: status, onTap: onStatusChanged),
                const SizedBox(width: 6),
                _StatusButton(label: '⏰ Atrasada', value: 'delayed', current: status, onTap: onStatusChanged),
                const SizedBox(width: 6),
                _StatusButton(label: '⏭️ Pulei', value: 'skipped', current: status, onTap: onStatusChanged),
                const SizedBox(width: 6),
                _StatusButton(label: '❌ Esqueci', value: 'missed', current: status, onTap: onStatusChanged),
              ],
            ),
            // Campo de motivo para skipped/missed
            if (status == 'skipped' || status == 'missed') ...[
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: status == 'skipped' ? 'Por que pulou? (opcional)' : 'O que aconteceu? (opcional)',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  const _StatusButton({required this.label, required this.value, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
