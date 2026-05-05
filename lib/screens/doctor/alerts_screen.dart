/// alerts_screen.dart — Tela de Alertas Clínicos
///
/// Lista todos os alertas clínicos abertos dos pacientes do médico.
/// Ordenados por severidade: critical > high > medium > low.

import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _api = ApiService();
  List<dynamic> _alerts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final alerts = await _api.getDashboardAlerts();
      setState(() { _alerts = alerts; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _resolveAlert(String alertId) async {
    try {
      await _api.resolveAlert(alertId);
      setState(() {
        _alerts.removeWhere((a) => a['id'] == alertId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta resolvido.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        title: const Text('Alertas Clínicos',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAlerts),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _error != null
              ? Center(child: Text('Erro: $_error'))
              : _alerts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text('Nenhum alerta aberto.',
                              style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAlerts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _alerts.length,
                        itemBuilder: (context, index) =>
                            _buildAlertCard(_alerts[index]),
                      ),
                    ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final severity = alert['severity'] ?? 'low';
    Color color;
    IconData icon;
    String severityLabel;

    switch (severity) {
      case 'critical':
        color = Colors.red;
        icon = Icons.error;
        severityLabel = 'CRÍTICO';
        break;
      case 'high':
        color = Colors.orange;
        icon = Icons.warning_amber;
        severityLabel = 'ALTO';
        break;
      case 'medium':
        color = Colors.amber.shade700;
        icon = Icons.info;
        severityLabel = 'MÉDIO';
        break;
      default:
        color = Colors.blue;
        icon = Icons.notifications;
        severityLabel = 'BAIXO';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(severityLabel,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text(
                  _formatDate(alert['created_at']),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Paciente
            if (alert['patient_name'] != null)
              Text(
                alert['patient_name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            const SizedBox(height: 4),

            // Mensagem
            Text(
              alert['message'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Botão resolver
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _resolveAlert(alert['id']),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Marcar como resolvido'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
