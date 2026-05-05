/// symptom_screen.dart — Tela de Registro de Sintomas Customizáveis
///
/// Permite ao paciente registrar sintomas configurados pelo médico:
/// ansiedade, tristeza, irritabilidade, energia, etc.
/// Suporta escalas numéricas, booleanas e de frequência.
import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';

class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;

  // Sintomas de exemplo (em produção virão da API via custom_symptoms do paciente)
  final List<Map<String, dynamic>> _symptoms = [
    {'id': 'sym_1', 'name': 'Ansiedade', 'scale_type': 'numeric', 'icon': '😰'},
    {'id': 'sym_2', 'name': 'Tristeza', 'scale_type': 'numeric', 'icon': '😢'},
    {'id': 'sym_3', 'name': 'Irritabilidade', 'scale_type': 'frequency', 'icon': '😠'},
    {'id': 'sym_4', 'name': 'Energia', 'scale_type': 'numeric', 'icon': '⚡'},
    {'id': 'sym_5', 'name': 'Pensamentos acelerados', 'scale_type': 'boolean', 'icon': '🌀'},
  ];

  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    for (final s in _symptoms) {
      if (s['scale_type'] == 'numeric') _values[s['id']] = 5.0;
      if (s['scale_type'] == 'boolean') _values[s['id']] = false;
      if (s['scale_type'] == 'frequency') _values[s['id']] = 'never';
      _noteControllers[s['id']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _noteControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      for (final symptom in _symptoms) {
        final val = _values[symptom['id']];
        final data = {
          'symptom_id': symptom['id'],
          if (symptom['scale_type'] == 'numeric') 'numeric_value': (val as double).roundToDouble(),
          if (symptom['scale_type'] == 'boolean') 'boolean_value': val as bool,
          if (symptom['scale_type'] == 'frequency') 'frequency_value': val as String,
          if (_noteControllers[symptom['id']]!.text.isNotEmpty)
            'notes': _noteControllers[symptom['id']]!.text,
        };
        await _apiService.createModuleRecord('symptoms', data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sintomas registrados!'),
            backgroundColor: Color(0xFFE91E63),
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

  Widget _buildSymptomWidget(Map<String, dynamic> symptom) {
    final id = symptom['id'] as String;
    final type = symptom['scale_type'] as String;

    switch (type) {
      case 'numeric':
        final val = (_values[id] as double?) ?? 5.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sem sintoma', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text(val.round().toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFE91E63))),
                const Text('Intenso', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            Slider(
              value: val,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: const Color(0xFFE91E63),
              onChanged: (v) => setState(() => _values[id] = v),
            ),
          ],
        );

      case 'boolean':
        final val = (_values[id] as bool?) ?? false;
        return Row(
          children: [
            const Text('Não', style: TextStyle(color: Colors.grey)),
            Switch(
              value: val,
              onChanged: (v) => setState(() => _values[id] = v),
              activeColor: const Color(0xFFE91E63),
            ),
            const Text('Sim', style: TextStyle(color: Colors.grey)),
          ],
        );

      case 'frequency':
        final val = (_values[id] as String?) ?? 'never';
        final options = [
          {'value': 'never', 'label': 'Nunca'},
          {'value': 'sometimes', 'label': 'Às vezes'},
          {'value': 'often', 'label': 'Frequente'},
          {'value': 'always', 'label': 'Sempre'},
        ];
        return Row(
          children: options.map((opt) {
            final isSelected = val == opt['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _values[id] = opt['value']),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE91E63) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    opt['label']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sintomas'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _symptoms.length,
              itemBuilder: (context, index) {
                final symptom = _symptoms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(symptom['icon'], style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text(
                              symptom['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSymptomWidget(symptom),
                      ],
                    ),
                  ),
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
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Salvar Sintomas', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
