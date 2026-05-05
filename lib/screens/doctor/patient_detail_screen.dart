/// patient_detail_screen.dart — Detalhe Clínico do Paciente
///
/// Exibe o resumo clínico de um paciente para o médico:
/// humor, sono, adesão a medicações, alertas e crises recentes.

import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _summary;
  List<dynamic> _modules = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final summary = await _api.getPatientSummary(widget.patientId);
      final modules = await _api.getPatientModules(widget.patientId);
      setState(() {
        _summary = summary;
        _modules = modules;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: Text(widget.patientName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _error != null
              ? Center(child: Text('Erro: $_error'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHumorCard(),
                        const SizedBox(height: 12),
                        _buildSleepMedCard(),
                        const SizedBox(height: 12),
                        _buildAlertsCard(),
                        const SizedBox(height: 12),
                        _buildModulesCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHumorCard() {
    final s = _summary!;
    final lastScore = s['last_mood_score'];
    final avg7 = s['avg_mood_7d'];
    final avg30 = s['avg_mood_30d'];
    final daysWithout = s['days_without_record'] ?? 0;

    Color scoreColor = Colors.green;
    if (lastScore != null) {
      if (lastScore <= 3) scoreColor = Colors.red;
      else if (lastScore <= 5) scoreColor = Colors.orange;
    }

    return _buildCard(
      title: 'Humor',
      icon: Icons.mood,
      iconColor: scoreColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Último', lastScore?.toString() ?? '—', scoreColor, '/10'),
              _buildMetric('Média 7d', avg7?.toString() ?? '—', Colors.blue, '/10'),
              _buildMetric('Média 30d', avg30?.toString() ?? '—', Colors.indigo, '/10'),
            ],
          ),
          if (daysWithout > 0) ...[
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  daysWithout >= 5 ? Icons.error : Icons.info_outline,
                  color: daysWithout >= 5 ? Colors.red : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '$daysWithout dia(s) sem registro',
                  style: TextStyle(
                    color: daysWithout >= 5 ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepMedCard() {
    final s = _summary!;
    final sleepHours = s['last_sleep_hours'];
    final sleepQuality = s['last_sleep_quality'];
    final medAdherence = s['medication_adherence_7d'];

    return _buildCard(
      title: 'Sono e Medicação',
      icon: Icons.bedtime_outlined,
      iconColor: Colors.indigo,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Último sono',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  sleepHours != null ? '${sleepHours}h' : '—',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (sleepQuality != null)
                  Text('Qualidade: $sleepQuality/10',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: Colors.grey.shade200),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adesão medicação (7d)',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    medAdherence != null ? '$medAdherence%' : '—',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: medAdherence != null
                          ? (medAdherence >= 80 ? Colors.green : Colors.red)
                          : Colors.grey,
                    ),
                  ),
                  if (medAdherence != null && medAdherence < 80)
                    const Text('Abaixo do ideal',
                        style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard() {
    final openAlerts = (_summary!['open_alerts'] as List?) ?? [];
    final crisisCount = _summary!['recent_crisis_count'] ?? 0;

    return _buildCard(
      title: 'Alertas e Crises',
      icon: Icons.warning_amber_outlined,
      iconColor: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (crisisCount > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.crisis_alert, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('$crisisCount crise(s) nos últimos 30 dias',
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          if (crisisCount > 0 && openAlerts.isNotEmpty)
            const SizedBox(height: 8),
          if (openAlerts.isEmpty && crisisCount == 0)
            const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 8),
                Text('Nenhum alerta aberto', style: TextStyle(color: Colors.green)),
              ],
            ),
          ...openAlerts.take(3).map((alert) => _buildAlertItem(alert)),
          if (openAlerts.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${openAlerts.length - 3} alertas adicionais',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final severity = alert['severity'] ?? 'low';
    Color color;
    switch (severity) {
      case 'critical': color = Colors.red; break;
      case 'high': color = Colors.orange; break;
      case 'medium': color = Colors.amber; break;
      default: color = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 10),
          const SizedBox(width: 8),
          Expanded(
            child: Text(alert['message'] ?? '',
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesCard() {
    return _buildCard(
      title: 'Módulos Ativos',
      icon: Icons.grid_view_outlined,
      iconColor: const Color(0xFF6C63FF),
      child: _modules.isEmpty
          ? const Text('Nenhum módulo configurado.',
              style: TextStyle(color: Colors.grey))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _modules.map<Widget>((m) {
                final isActive = m['is_active'] == true;
                final code = m['modules']?['code'] ?? m['module_id'] ?? '';
                final name = m['modules']?['name'] ?? code;
                return Chip(
                  label: Text(name,
                      style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey,
                          fontSize: 12)),
                  backgroundColor: isActive
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade200,
                );
              }).toList(),
            ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color, String suffix) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(suffix, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
