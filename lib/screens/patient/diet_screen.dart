/// diet_screen.dart — Tela de Registro de Dieta e Apetite
///
/// Permite ao paciente registrar marcadores clínicos de alimentação:
/// qualidade geral, hidratação, refeições puladas, compulsão e restrição.
import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;

  int _qualityScore = 3;
  bool? _waterIntakeOk;
  int _skippedMeals = 0;
  bool _hadBinge = false;
  bool _hadRestriction = false;

  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final data = {
        'quality_score': _qualityScore,
        if (_waterIntakeOk != null) 'water_intake_ok': _waterIntakeOk,
        'skipped_meals': _skippedMeals,
        'had_binge': _hadBinge,
        'had_restriction': _hadRestriction,
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };

      await _apiService.createModuleRecord('diet', data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de dieta salvo!'),
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
        title: const Text('Dieta e Apetite'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Qualidade geral da alimentação
            const Text('Como foi sua alimentação hoje?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final val = i + 1;
                final labels = ['Muito ruim', 'Ruim', 'Regular', 'Boa', 'Ótima'];
                final emojis = ['🍔', '🍕', '🥗', '🥦', '🥑'];
                return GestureDetector(
                  onTap: () => setState(() => _qualityScore = val),
                  child: Column(
                    children: [
                      Text(emojis[i], style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: _qualityScore == val ? const Color(0xFF4CAF50) : Colors.grey,
                          fontWeight: _qualityScore == val ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _qualityScore == val ? const Color(0xFF4CAF50) : Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Hidratação
            const Text('Hidratação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _HydrationButton(
                  label: '✅ Boa hidratação',
                  selected: _waterIntakeOk == true,
                  color: Colors.blue,
                  onTap: () => setState(() => _waterIntakeOk = true),
                ),
                const SizedBox(width: 12),
                _HydrationButton(
                  label: '❌ Bebi pouco',
                  selected: _waterIntakeOk == false,
                  color: Colors.orange,
                  onTap: () => setState(() => _waterIntakeOk = false),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Refeições puladas
            const Text('Refeições puladas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_skippedMeals > 0) setState(() => _skippedMeals--);
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 32, color: Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      '$_skippedMeals',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                    ),
                    const Text('refeição(ões)', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => setState(() => _skippedMeals++),
                  icon: const Icon(Icons.add_circle_outline, size: 32, color: Color(0xFF4CAF50)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Marcadores clínicos
            const Text('Marcadores clínicos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text(
              'Esses dados ajudam o médico a entender padrões alimentares relacionados ao seu tratamento.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Episódio de compulsão alimentar', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Comer em grande quantidade sem controle', style: TextStyle(fontSize: 12)),
              value: _hadBinge,
              onChanged: (v) => setState(() => _hadBinge = v),
              activeColor: const Color(0xFF4CAF50),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Restrição alimentar intencional', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Evitar comer além do necessário', style: TextStyle(fontSize: 12)),
              value: _hadRestriction,
              onChanged: (v) => setState(() => _hadRestriction = v),
              activeColor: const Color(0xFF4CAF50),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Observações
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Algo relevante sobre sua alimentação hoje?',
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
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
                    : const Text('Salvar Registro', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HydrationButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _HydrationButton({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? color : Colors.grey[300]!),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? color : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
