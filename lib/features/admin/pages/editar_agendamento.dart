import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petshop_pex/features/auth/controller/auth_controller.dart';
import 'package:petshop_pex/features/nav_button.dart';
import 'package:petshop_pex/features/pet/models/pet_model.dart';
import 'package:provider/provider.dart';
import '../cards/agendamento_card.dart';

class EditAgendamentoPage extends StatefulWidget {
  const EditAgendamentoPage({
    super.key,
    required this.agendamento,
    this.docId,
  });

  final Map<String, dynamic> agendamento;
  final String? docId;

  @override
  State<EditAgendamentoPage> createState() => _EditAgendamentoPageState();
}

class _EditAgendamentoPageState extends State<EditAgendamentoPage> {
  final _formKey = GlobalKey<FormState>();

  final _statusOptions = ['Chegou', 'Em Processo', 'Finalizado'];

  String statusLabelFromRaw(dynamic raw) {
    if (raw is int) {
      switch (raw) {
        case 0:
          return 'Chegou';
        case 1:
          return 'Em Processo';
        case 2:
          return 'Finalizado';
        default:
          return 'Desconhecido';
      }
    }
    if (raw is String) {
      if (_statusOptions.contains(raw)) return raw;
      final n = int.tryParse(raw);
      if (n != null) return statusLabelFromRaw(n);
    }
    return 'Desconhecido';
  }

  int statusCodeFromLabel(String label) {
    switch (label) {
      case 'Chegou':
        return 0;
      case 'Em Processo':
        return 1;
      case 'Finalizado':
        return 2;
      default:
        return -1;
    }
  }

  List<String> servicesFromRaw(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      return [raw];
    }
    return [];
  }

  final _servicoOptions = const [
    'Banho completo',
    'Tosa',
    'Veterinário',
  ];

  late String _status;
  late String _servico;
  List<Pet> _pets = [];
  final _funcionarioCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _status = statusLabelFromRaw(widget.agendamento['status']);
    if (!_statusOptions.contains(_status)) {
      _status = 'pendente';
    }

    final services = servicesFromRaw(widget.agendamento['services']);
    final firstService = services.isNotEmpty ? services.first : '';
    _servico = _servicoOptions.contains(firstService) ? firstService : '';

    _funcionarioCtrl.text =
        (widget.agendamento['funcionario'] ?? '').toString();
    _obsCtrl.text =
        (widget.agendamento['observacoes'] ?? '').toString();
  }

  @override
  void dispose() {
    _funcionarioCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save({bool cancel = false}) async {
    if (cancel) _status = 'cancelado';

    if (!cancel && !(_formKey.currentState?.validate() ?? false)) return;

    final payload = {
      'status': statusCodeFromLabel(_status),
      'services': _servico.isEmpty ? [] : [_servico],
      'funcionario': _funcionarioCtrl.text.trim(),
      'observacoes': _obsCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (widget.docId != null) {
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .doc(widget.docId)
          .update(payload);
    }

    if (mounted) Navigator.pop(context, true);
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final foto = (widget.agendamento['fotoPet'] ?? '').toString();
    final nomePet = (widget.agendamento['petNome'] ?? '').toString();
    final services = servicesFromRaw(widget.agendamento['services']);
    final servicoTop = services.join(', ');
    final rawDataHora = widget.agendamento['dataHora'];
    final funcionario = (widget.agendamento['funcionario'] ?? '').toString();
    final observacoes = (widget.agendamento['observacoes'] ?? '').toString();

    DateTime? dt;
    if (rawDataHora is Timestamp) dt = rawDataHora.toDate();
    if (rawDataHora is String) dt = DateTime.tryParse(rawDataHora);

    final statusTop = statusLabelFromRaw(widget.agendamento['status']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Agendamento'),
        backgroundColor: Colors.yellow,
        leading: MainNavMenuButton(pets: _pets),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Sair',
            onPressed: () {
              context.read<AuthController>().logout(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AgendamentoCard(
              foto: foto,
              nomePet: nomePet,
              servico: servicoTop,
              dataHora: _fmt(dt),
              status: statusTop,
              funcionario: funcionario,
              observacoes: observacoes,
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _statusOptions.contains(_status) ? _status : null,
                      items: _statusOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    const Text('Funcionário Responsável:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _funcionarioCtrl,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o responsável' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('Serviço:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _servicoOptions.contains(_servico) ? _servico : null,
                      items: _servicoOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _servico = v ?? _servico),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Escolha um serviço' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('Observações:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _obsCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _save(cancel: true),
                    child: const Text('Cancelar Agendamento'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _save,
                    child: const Text('Salvar Alterações'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}