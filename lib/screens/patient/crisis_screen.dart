/// crisis_screen.dart — Tela de Registro de Crise
///
/// Projetada para captura rápida — o paciente em crise não tem
/// paciência para formulários longos.
///
/// CRÍTICO: Gera alerta imediato ao médico.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:aura_app/services/local_storage_service.dart';
import 'package:aura_app/services/sync_service.dart';

class CrisisScreen extends StatefulWidget {
  const CrisisScreen({super.key});

  @override
  State<CrisisScreen> createState() => _CrisisScreenState();
}

class _CrisisScreenState extends State<CrisisScreen> {
  int _intensity = 5;
  final List<String> _selectedTypes = [];
  bool _hasSuicidalIdeation = false;
  final List<String> _selectedCoping = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  final List<String> _crisisTypes = [
    'Ansiedade intensa',
    'Ataque de pânico',
    'Pensamentos intrusivos',
    'Dissociação',
    'Automutilação (vontade)',
    'Ideação suicida',
    'Psicose',
    'Outro',
  ];

  final List<String> _copingStrategies = [
    'Respiração',
    'Ligou para alguém',
    'Tomou medicação',
    'Foi ao pronto-socorro',
    'Meditação',
    'Exercício',
    'Outro',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCrisis() async {
    if (_selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um tipo de crise'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final record = {
        'id': const Uuid().v4(),
        'patient_id': '',
        'intensity': _intensity,
        'crisis_types': _selectedTypes.join(','),
        'has_suicidal_ideation': _hasSuicidalIdeation ? 1 : 0,
        'coping_used': _selectedCoping.join(','),
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
        'occurred_at': DateTime.now().toIso8601String(),
        'synced': 0,
      };

      // 1. Salvar localmente
      final localStorage = LocalStorageService();
      await localStorage.saveCrisisRecord(record);

      // 2. Sincronizar imediatamente (crise é urgente)
      final syncService = SyncService();
      await syncService.syncPendingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Crise registrada. Seu médico foi notificado.'),
            backgroundColor: Colors.orange,
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
        title: const Text('Registrar Crise'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aviso
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este registro será enviado ao seu médico. '
                      'Em emergência, ligue 192 (SAMU) ou 188 (CVV).',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Intensidade
            const Text(
              'Intensidade da crise (1-10)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Leve'),
                Expanded(
                  child: Slider(
                    value: _intensity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: Colors.red,
                    label: _intensity.toString(),
                    onChanged: (v) => setState(() => _intensity = v.toInt()),
                  ),
                ),
                const Text('Emergência'),
              ],
            ),
            const SizedBox(height: 24),

            // Tipo de crise
            const Text(
              'O que está acontecendo?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _crisisTypes.map((type) {
                final isSelected = _selectedTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: Colors.red.shade100,
                  checkmarkColor: Colors.red,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTypes.add(type);
                        if (type == 'Ideação suicida') {
                          _hasSuicidalIdeation = true;
                        }
                      } else {
                        _selectedTypes.remove(type);
                        if (type == 'Ideação suicida') {
                          _hasSuicidalIdeation = false;
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Estratégias de coping
            const Text(
              'O que você fez / está fazendo?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _copingStrategies.map((strategy) {
                final isSelected = _selectedCoping.contains(strategy);
                return FilterChip(
                  label: Text(strategy),
                  selected: isSelected,
                  selectedColor: Colors.orange.shade100,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCoping.add(strategy);
                      } else {
                        _selectedCoping.remove(strategy);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Notas
            const Text(
              'Descreva o que aconteceu (opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'O que desencadeou a crise? Como está se sentindo?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Botão de salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCrisis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
                        'Registrar Crise',
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
