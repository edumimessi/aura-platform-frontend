/// dashboard_screen.dart — Dashboard Principal do Médico
///
/// Exibe: lista de pacientes com status de adesão e alertas abertos.
/// Ponto de entrada do médico após login.

import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';
import 'package:aura_app/screens/doctor/patient_detail_screen.dart';
import 'package:aura_app/screens/doctor/alerts_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final _api = ApiService();
  List<dynamic> _patients = [];
  List<dynamic> _alerts = [];
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
      final patients = await _api.getDashboardPatients();
      final alerts = await _api.getDashboardAlerts();
      setState(() {
        _patients = patients;
        _alerts = alerts;
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
        title: const Text('AURA — Dashboard Médico',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Badge de alertas
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AlertsScreen())),
              ),
              if (_alerts.isNotEmpty)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text('${_alerts.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: CustomScrollView(
                    slivers: [
                      // Resumo de alertas críticos
                      if (_alerts.any((a) => a['severity'] == 'critical'))
                        SliverToBoxAdapter(child: _buildCriticalBanner()),

                      // Estatísticas rápidas
                      SliverToBoxAdapter(child: _buildStatsRow()),

                      // Lista de pacientes
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Pacientes (${_patients.length})',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildPatientCard(_patients[index]),
                          childCount: _patients.length,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCriticalBanner() {
    final criticalCount = _alerts.where((a) => a['severity'] == 'critical').length;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$criticalCount alerta(s) crítico(s)',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                const Text('Requer atenção imediata.',
                    style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AlertsScreen())),
            child: const Text('Ver', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final critical = _patients.where((p) => p['adherence_status'] == 'critical').length;
    final alert = _patients.where((p) => p['adherence_status'] == 'alert').length;
    final ok = _patients.where((p) => p['adherence_status'] == 'ok').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _buildStatCard('Em dia', ok.toString(), Colors.green),
          const SizedBox(width: 8),
          _buildStatCard('Atenção', alert.toString(), Colors.orange),
          const SizedBox(width: 8),
          _buildStatCard('Crítico', critical.toString(), Colors.red),
          const SizedBox(width: 8),
          _buildStatCard('Alertas', _alerts.length.toString(), const Color(0xFF6C63FF)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final adherence = patient['adherence_status'] ?? 'ok';
    final daysWithout = patient['days_without_record'];
    final openAlerts = patient['open_alerts_count'] ?? 0;

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (adherence) {
      case 'critical':
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        statusLabel = daysWithout != null ? '$daysWithout dias sem registro' : 'Sem registros';
        break;
      case 'alert':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber_outlined;
        statusLabel = '$daysWithout dias sem registro';
        break;
      case 'warning':
        statusColor = Colors.amber;
        statusIcon = Icons.info_outline;
        statusLabel = '$daysWithout dias sem registro';
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusLabel = 'Em dia';
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(
              patientId: patient['id'],
              patientName: patient['full_name'] ?? 'Paciente',
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.15),
                child: Text(
                  (patient['full_name'] ?? 'P').substring(0, 1).toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient['full_name'] ?? 'Paciente',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(statusLabel,
                            style: TextStyle(color: statusColor, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              // Alertas
              if (openAlerts > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text('$openAlerts alertas',
                      style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Erro ao carregar dados.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error ?? '', textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadData, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
