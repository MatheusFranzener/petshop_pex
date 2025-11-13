import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cards/agendamento_card.dart';

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

  final _statusOptions = const ['pendente', 'confirmado', 'finalizado', 'cancelado'];
  final _servicoOptions = const [
    'Banho',
    'Tosa',
    'Banho e Tosa',
    'Tosa Higiênica',
    'Hidratação',
    'Consulta Veterinária',
  ];

  late String _status;
  late String _servico;
  final _funcionarioCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = (widget.agendamento['status'] ?? 'pendente').toString();
    _servico = (widget.agendamento['servico'] ?? '').toString();
    _funcionarioCtrl.text = (widget.agendamento['funcionario'] ?? '').toString();
    _obsCtrl.text = (widget.agendamento['observacoes'] ?? '').toString();
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
      'status': _status,
      'servico': _servico,
      'funcionario': _funcionarioCtrl.text.trim(),
      'observacoes': _obsCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (widget.docId != null) {
      // Firestore
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .doc(widget.docId)
          .update(payload);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final foto = (widget.agendamento['fotoPet'] ?? '').toString();
    final nomePet = (widget.agendamento['nomePet'] ?? '').toString();
    final servicoTop = (widget.agendamento['servico'] ?? '').toString();
    final dataHoraFmt = (widget.agendamento['dataHoraFmt'] ?? '').toString();
    final statusTop = (widget.agendamento['status'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Agendamento'),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AgendamentoCard(
              foto: foto,
              nomePet: nomePet,
              servico: servicoTop,
              dataHora: dataHoraFmt,
              status: statusTop,
            ),
            const SizedBox(height: 12),

            // Form
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
                      value: _status,
                      items: _statusOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    const Text('Funcionário Responsável:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _funcionarioCtrl,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o responsável' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('Serviço:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _servico.isEmpty ? null : _servico,
                      items: _servicoOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _servico = v ?? _servico),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.isEmpty) ? 'Escolha um serviço' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('Observações:', style: TextStyle(fontWeight: FontWeight.bold)),
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
