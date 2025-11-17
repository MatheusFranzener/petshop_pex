import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petshop_pex/features/admin/pages/editar_agendamento.dart';
import 'package:petshop_pex/features/nav_button.dart';
import 'package:petshop_pex/features/pet/models/pet_model.dart';
import 'package:provider/provider.dart';

import '../../auth/controller/auth_controller.dart';
import '../cards/agendamento_card.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({
    super.key,
    this.useMock = false,
    this.skipGate = false,
  });

  final bool useMock;
  final bool skipGate;

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  bool? _isAdmin;
  final _search = TextEditingController();

  final _statusOptions = ['Chegou', 'Em Processo', 'Finalizado'];

  List<Pet> _pets = [];

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

  @override
  void initState() {
    super.initState();
    if (widget.skipGate) {
      _isAdmin = true;
    } else {
      _gate();
    }
  }

  Future<void> _gate() async {
    final auth = context.read<AuthController>();
    final ok = await auth.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() => _isAdmin = ok);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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

  String _statusLabelFromCode(int code) {
    switch (code) {
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

  @override
  Widget build(BuildContext context) {
    if (!widget.skipGate) {
      if (_isAdmin == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (_isAdmin == false) {
        return Scaffold(
          appBar: AppBar(title: const Text('Agendamentos')),
          body: const Center(child: Text('Acesso negado: apenas administradores.')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
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
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Buscar por pet ou serviço...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(child: _buildFirestoreList()),
        ],
      ),
    );
  }

  Widget _buildFirestoreList() {
    final query = FirebaseFirestore.instance
        .collection('agendamentos')
        .orderBy('dataHora', descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Erro: ${snap.error}'));
        }

        final docs = snap.data?.docs ?? [];
        final filtro = _search.text.trim().toLowerCase();

        final itensFiltrados = docs.where((d) {
          final m = d.data();
          final nomePet = (m['petNome'] ?? '').toString().toLowerCase();
          final services = servicesFromRaw(m['services']);
          final servicoTxt = services.join(', ').toLowerCase();
          if (filtro.isEmpty) return true;
          return nomePet.contains(filtro) || servicoTxt.contains(filtro);
        }).toList();

        if (itensFiltrados.isEmpty) {
          return const Center(child: Text('Nenhum agendamento encontrado'));
        }

        return ListView.builder(
          itemCount: itensFiltrados.length,
          itemBuilder: (_, i) {
            final doc = itensFiltrados[i];
            final m = doc.data();

            final foto = (m['fotoPet'] ?? '').toString();
            final nomePet = (m['petNome'] ?? '').toString();
            final services = servicesFromRaw(m['services']);
            final servicoTxt = services.join(', ');
            final funcionario = (m['funcionario'] ?? '').toString();
            final observacoes = (m['observacoes'] ?? '').toString();

            final statusLabel = statusLabelFromRaw(m['status']);

            DateTime? dt;
            final raw = m['dataHora'];
            if (raw is Timestamp) dt = raw.toDate();
            if (raw is String) dt = DateTime.tryParse(raw);

            return AgendamentoCard(
              foto: foto,
              nomePet: nomePet,
              servico: servicoTxt,
              dataHora: _fmt(dt),
              status: statusLabel,
              funcionario: funcionario,
              observacoes: observacoes,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditAgendamentoPage(
                      docId: doc.id,
                      agendamento: m,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
