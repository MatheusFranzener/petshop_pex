import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:petshop_pex/features/auth/controller/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../pet/models/pet_model.dart';
import 'status_page.dart';

class StatusPetsPage extends StatefulWidget {
  final List<Pet> pets;

  const StatusPetsPage({super.key, required this.pets});

  @override
  State<StatusPetsPage> createState() => _StatusPetsPageState();
}

class _StatusPetsPageState extends State<StatusPetsPage> {
  bool _loading = true;
  Set<String> _petIdsComAgendamento = {};

  @override
  void initState() {
    super.initState();
    _carregarPetsComAgendamento();
  }

  Future<void> _carregarPetsComAgendamento() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('agendamentos')
          .where('userId', isEqualTo: user.uid)
          .get();

      final ids = snap.docs.map((d) => d['petId'] as String).toSet();

      setState(() {
        _petIdsComAgendamento = ids;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
      );
    }
  }

  Future<void> _abrirStatusDoPet(Pet pet) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snap = await FirebaseFirestore.instance
          .collection('agendamentos')
          .where('userId', isEqualTo: user.uid)
          .where('petId', isEqualTo: pet.id)
          .get();

      if (snap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum agendamento para esse pet')),
        );
        return;
      }

      final docs = snap.docs.toList();
      docs.sort((a, b) {
        final da = (a['dataHora'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final db = (b['dataHora'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return db.compareTo(da); // mais recente primeiro
      });

      final data = docs.first.data();

      final List services = data['services'] ?? [];
      final String servico = services.isEmpty ? 'Serviço' : services.join(', ');

      final int status = (data['status'] ?? 0) as int;
      final List<String> historico = List<String>.from(data['historico'] ?? []);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StatusPage(
            pet: pet,
            servico: servico,
            etapa: status,
            historico: historico,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar status: $e')));
    }
  }

  Widget _buildPetImage(Pet pet) {
    if (pet.imagePath.isEmpty || kIsWeb) {
      return Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.pets, size: 32, color: Colors.white),
      );
    }

    final file = File(pet.imagePath);
    if (!file.existsSync()) {
      return Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.pets, size: 32, color: Colors.white),
      );
    }

    return Image.file(file, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final petsComAgendamento = widget.pets
        .where((p) => _petIdsComAgendamento.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        centerTitle: true,
        title: const Text('Status', style: TextStyle(color: Colors.black)),
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
      body: petsComAgendamento.isEmpty
          ? const Center(child: Text('Você ainda não tem agendamentos'))
          : ListView.builder(
              itemCount: petsComAgendamento.length,
              itemBuilder: (_, i) {
                final pet = petsComAgendamento[i];
                return ListTile(
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildPetImage(pet),
                    ),
                  ),
                  title: Text(pet.nome),
                  subtitle: Text('${pet.raca} • ${pet.porte}'),
                  onTap: () => _abrirStatusDoPet(pet),
                );
              },
            ),
    );
  }
}
