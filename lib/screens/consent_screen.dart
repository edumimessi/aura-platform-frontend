/// consent_screen.dart — Consentimento LGPD
///
/// Exibida no primeiro login do paciente.
/// O usuário deve aceitar explicitamente antes de acessar o app.
/// O aceite é registrado no backend com timestamp e versão do termo.
///
/// Base legal: LGPD Art. 7º, inciso I — consentimento do titular.
/// CFM Resolução 2.314/2022 — prontuário eletrônico e dados sensíveis.

import 'package:flutter/material.dart';
import 'package:aura_app/services/api_service.dart';
import 'package:aura_app/screens/patient/home_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _hasReadTerms = false;
  bool _acceptedConsent = false;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Versão do termo — deve ser incrementada a cada alteração do texto
  static const String _consentVersion = '1.0';

  @override
  void initState() {
    super.initState();
    // Detectar quando o usuário chegou ao final do texto
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_hasReadTerms) {
          setState(() => _hasReadTerms = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _acceptConsent() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      await api.registerConsent({
        'consent_type': 'data_processing',
        'version': _consentVersion,
        'accepted': true,
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar consentimento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _declineConsent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recusar consentimento'),
        content: const Text(
          'Sem o consentimento, não é possível utilizar o aplicativo AURA. '
          'Seus dados não serão coletados ou armazenados.\n\n'
          'Deseja sair do aplicativo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Fazer logout e voltar para login
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Termo de Consentimento'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Banner informativo
          Container(
            width: double.infinity,
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Leia o termo completo antes de aceitar. '
                    'Role até o final para habilitar o botão de aceite.',
                    style: TextStyle(
                      color: const Color(0xFF6C63FF),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Texto do termo — rolável
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle('TERMO DE CONSENTIMENTO LIVRE E ESCLARECIDO'),
                  _buildTitle('Plataforma AURA — Acompanhamento Psiquiátrico Ambulatorial'),
                  const SizedBox(height: 8),
                  _buildText('Versão $_consentVersion — ${DateTime.now().year}'),
                  const Divider(height: 32),

                  _buildSection('1. O QUE É O AURA'),
                  _buildText(
                    'O AURA é uma plataforma digital de apoio ao acompanhamento psiquiátrico '
                    'ambulatorial, desenvolvida para uso complementar às consultas médicas. '
                    'O aplicativo permite o registro diário de humor, sono, medicações, '
                    'exercícios, alimentação, meditação e sintomas, além do relato de crises.',
                  ),

                  _buildSection('2. QUAIS DADOS SERÃO COLETADOS'),
                  _buildText(
                    'Serão coletados os seguintes dados pessoais e de saúde:\n\n'
                    '• Dados de identificação: nome, data de nascimento, gênero e e-mail.\n'
                    '• Dados clínicos: registros de humor, sono, medicações, sintomas, '
                    'exercícios, alimentação, meditação e crises.\n'
                    '• Dados de uso: horários de acesso e módulos utilizados.\n'
                    '• Dados do dispositivo: modelo e token para notificações push.',
                  ),

                  _buildSection('3. FINALIDADE DO USO DOS DADOS'),
                  _buildText(
                    'Seus dados serão utilizados exclusivamente para:\n\n'
                    '• Apoiar o acompanhamento clínico pelo seu médico responsável.\n'
                    '• Gerar alertas automáticos em situações de crise ou baixa adesão.\n'
                    '• Produzir relatórios para uso nas consultas.\n'
                    '• Identificar padrões clínicos relevantes para o tratamento.\n\n'
                    'Seus dados NÃO serão utilizados para fins comerciais, publicidade '
                    'ou compartilhados com terceiros sem sua autorização explícita.',
                  ),

                  _buildSection('4. BASE LEGAL (LGPD — Lei 13.709/2018)'),
                  _buildText(
                    'O tratamento dos seus dados é realizado com base no:\n\n'
                    '• Art. 7º, inciso I: consentimento do titular.\n'
                    '• Art. 11, inciso II, alínea "f": tutela da saúde, em procedimento '
                    'realizado por profissional de saúde.\n\n'
                    'Dados de saúde são classificados como dados sensíveis e recebem '
                    'proteção especial conforme o Art. 11 da LGPD.',
                  ),

                  _buildSection('5. ARMAZENAMENTO E SEGURANÇA'),
                  _buildText(
                    'Seus dados são armazenados em servidores seguros com:\n\n'
                    '• Criptografia em trânsito (HTTPS/TLS).\n'
                    '• Controle de acesso por autenticação JWT.\n'
                    '• Políticas de segurança por linha (Row Level Security).\n'
                    '• Logs de auditoria de todos os acessos.\n'
                    '• Acesso restrito ao médico responsável pelo seu tratamento.',
                  ),

                  _buildSection('6. SEUS DIREITOS'),
                  _buildText(
                    'Conforme a LGPD, você tem direito a:\n\n'
                    '• Confirmar a existência de tratamento dos seus dados.\n'
                    '• Acessar seus dados a qualquer momento.\n'
                    '• Corrigir dados incompletos ou incorretos.\n'
                    '• Solicitar a exclusão dos seus dados.\n'
                    '• Revogar este consentimento a qualquer momento.\n'
                    '• Exportar seus dados em formato estruturado.\n\n'
                    'Para exercer qualquer desses direitos, entre em contato com '
                    'o consultório do Dr. Eduardo D\'Angelo Mimessi.',
                  ),

                  _buildSection('7. REVOGAÇÃO DO CONSENTIMENTO'),
                  _buildText(
                    'Você pode revogar este consentimento a qualquer momento, '
                    'sem prejuízo ao seu atendimento médico. A revogação pode ser '
                    'solicitada diretamente ao médico ou pela secretaria do consultório. '
                    'Após a revogação, seus dados serão anonimizados ou excluídos '
                    'conforme sua solicitação.',
                  ),

                  _buildSection('8. CONTATO'),
                  _buildText(
                    'Responsável pelo tratamento dos dados:\n'
                    'Dr. Eduardo D\'Angelo Mimessi — CRM [número]\n'
                    'Para dúvidas ou exercício de direitos, entre em contato '
                    'pelo e-mail ou telefone do consultório.',
                  ),

                  const Divider(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: const Text(
                      'Ao aceitar este termo, você confirma que leu, compreendeu '
                      'e concorda com o tratamento dos seus dados conforme descrito acima.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Área de aceite — fixada na parte inferior
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Checkbox de aceite — só habilitado após ler o termo
                CheckboxListTile(
                  value: _acceptedConsent,
                  onChanged: _hasReadTerms
                      ? (val) => setState(() => _acceptedConsent = val ?? false)
                      : null,
                  title: Text(
                    'Li e aceito o Termo de Consentimento',
                    style: TextStyle(
                      color: _hasReadTerms ? Colors.black87 : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  activeColor: const Color(0xFF6C63FF),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                if (!_hasReadTerms)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Role até o final do termo para habilitar o aceite',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    // Botão recusar
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _declineConsent,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Recusar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botão aceitar — só habilitado com checkbox marcado
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: (_acceptedConsent && !_isLoading)
                            ? _acceptConsent
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Aceitar e Continuar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6C63FF),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSection(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.6,
      ),
    );
  }
}
