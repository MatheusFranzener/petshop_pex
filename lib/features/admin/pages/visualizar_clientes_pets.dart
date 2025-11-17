import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petshop_pex/features/admin/cards/clientePet_card.dart';
import 'package:petshop_pex/features/auth/controller/auth_controller.dart';

import 'package:petshop_pex/features/nav_button.dart';
import 'package:petshop_pex/features/pet/models/pet_model.dart';
import 'package:petshop_pex/features/pet/repository/pet_local_repository.dart';
import 'package:provider/provider.dart';

class ClientesPetsPage extends StatefulWidget {
  const ClientesPetsPage({super.key});

  @override
  State<ClientesPetsPage> createState() => _ClientesPetsPageState();
}

class _ClientesPetsPageState extends State<ClientesPetsPage> {
  final _repo = PetLocalRepository();
  final _searchCtrl = TextEditingController();

  List<Pet> _pets = [];
  String _filtro = '';
  String _nomeDono = 'Desconhecido';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final pets = await _repo.load();
      final ownerName = await _getNomeDonoAtual();
      if (!mounted) return;
      setState(() {
        _pets = pets;
        _nomeDono = ownerName;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pets: $e')),
      );
    }
  }

  Future<String> _getNomeDonoAtual() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Desconhecido';

    try {
      final doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      final nome = data?['nome']?.toString();
      if (nome != null && nome.trim().isNotEmpty) return nome.trim();
      return user.email ?? 'Desconhecido';
    } catch (_) {
      return user.email ?? 'Desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _pets.where((p) {
      if (_filtro.isEmpty) return true;
      final q = _filtro.toLowerCase();
      return p.nome.toLowerCase().contains(q) ||
          _nomeDono.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes e Pets'),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar Cliente ou Pet...',
                prefixIcon: const Icon(Icons.search),
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() => _filtro = value.trim().toLowerCase());
              },
            ),
          ),
          Expanded(
            child: filtrados.isEmpty
                ? const Center(child: Text('Nenhum pet encontrado.'))
                : ListView.builder(
              itemCount: filtrados.length,
              itemBuilder: (context, index) {
                final pet = filtrados[index];
                return ClientePetCard(
                  imagePath: pet.imagePath,
                  nome: pet.nome,
                  nomeDono: _nomeDono,
                  idade: pet.idade.toString(),
                  raca: pet.raca,
                  porte: pet.porte,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}