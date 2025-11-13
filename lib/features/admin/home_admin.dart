import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:petshop_pex/features/admin/editar_agendamento.dart';
import 'package:petshop_pex/features/nav_button.dart';
import 'package:provider/provider.dart';
import '../auth/controller/auth_controller.dart';
import 'cards/agendamento_card.dart';

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

  // ------- MOCK DATA --------
  final List<Map<String, dynamic>> _mock = [
    {
      'fotoPet': 'https://placecats.com/300/200',
      'nomePet': 'Luna',
      'servico': 'Banho e Tosa',
      'status': 'confirmado',
      'dataHora': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'fotoPet': 'https://placecats.com/300/201',
      'nomePet': 'Thor',
      'servico': 'Banho',
      'status': 'pendente',
      'dataHora': DateTime.now().add(const Duration(days: 1, hours: 1)).toIso8601String(),
    },
    {
      'fotoPet': 'https://placecats.com/300/202',
      'nomePet': 'Mimi',
      'servico': 'Tosa Higiênica',
      'status': 'finalizado',
      'dataHora': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
  ];
  // --------------------------

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
        title: const Text('Agendamentos (Admin)'),
        backgroundColor: Colors.yellow,
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
          Expanded(
            child: widget.useMock ? _buildMockList() : _buildFirestoreList(),
          ),
        ],
      ),
      floatingActionButton: const FloatingNavButton(),
    );
  }

  // ------- LISTA MOCK --------
  Widget _buildMockList() {
    final filtro = _search.text.trim().toLowerCase();

    final itens = _mock.where((m) {
      final nomePet = (m['nomePet'] ?? '').toString().toLowerCase();
      final servico = (m['servico'] ?? '').toString().toLowerCase();
      if (filtro.isEmpty) return true;
      return nomePet.contains(filtro) || servico.contains(filtro);
    }).toList()
      ..sort((a, b) {
        final da = DateTime.tryParse(a['dataHora'] ?? '');
        final db = DateTime.tryParse(b['dataHora'] ?? '');
        return (db ?? DateTime(1900)).compareTo(da ?? DateTime(1900));
      });

    if (itens.isEmpty) {
      return const Center(child: Text('Nenhum agendamento encontrado (mock)'));
    }

    return ListView.builder(
      itemCount: itens.length,
      itemBuilder: (_, i) {
        final m = itens[i];
        final foto = (m['fotoPet'] ?? '').toString();
        final nomePet = (m['nomePet'] ?? '').toString();
        final servico = (m['servico'] ?? '').toString();
        final status = (m['status'] ?? 'pendente').toString();
        final dt = DateTime.tryParse((m['dataHora'] ?? '').toString());

        return AgendamentoCard(
          foto: foto,
          nomePet: nomePet,
          servico: servico,
          dataHora: _fmt(dt),
          status: status,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditAgendamentoPage(
                  agendamento: {
                    'fotoPet': foto,
                    'nomePet': nomePet,
                    'servico': servico,
                    'status': status,
                    'dataHoraFmt': _fmt(dt),
                    'funcionario': m['funcionario'],
                    'observacoes': m['observacoes'],
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ------- LISTA FIRESTORE (original) --------
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

        final itens = docs.where((d) {
          final m = d.data();
          final nomePet = (m['nomePet'] ?? '').toString().toLowerCase();
          final servico = (m['servico'] ?? '').toString().toLowerCase();
          if (filtro.isEmpty) return true;
          return nomePet.contains(filtro) || servico.contains(filtro);
        }).toList();

        if (itens.isEmpty) {
          return const Center(child: Text('Nenhum agendamento encontrado'));
        }

        return ListView.builder(
          itemCount: itens.length,
          itemBuilder: (_, i) {
            final m = itens[i].data();
            final foto = (m['fotoPet'] ?? '').toString();
            final nomePet = (m['nomePet'] ?? '').toString();
            final servico = (m['servico'] ?? '').toString();
            final status = (m['status'] ?? 'pendente').toString();

            DateTime? dt;
            final raw = m['dataHora'];
            if (raw is Timestamp) dt = raw.toDate();
            if (raw is String) dt = DateTime.tryParse(raw);

            return AgendamentoCard(
              foto: foto,
              nomePet: nomePet,
              servico: servico,
              dataHora: _fmt(dt),
              status: status,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditAgendamentoPage(
                      docId: itens[i].id, // id do documento do Firestore
                      agendamento: {
                        'fotoPet': foto,
                        'nomePet': nomePet,
                        'servico': servico,
                        'status': status,
                        'dataHoraFmt': _fmt(dt),
                        'funcionario': m['funcionario'],
                        'observacoes': m['observacoes'],
                      },
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
