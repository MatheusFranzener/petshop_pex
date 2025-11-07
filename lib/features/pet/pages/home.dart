import 'dart:io';
import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../repository/pet_local_repository.dart';
import 'cadastro_pet.dart';
import 'detalhes_pet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = PetLocalRepository();
  List<Pet> _pets = [];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    final data = await _repo.load();
    setState(() => _pets = data);
  }

  Future<void> _goToCadastro() async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPetPage()),
    );
    if (changed == true) _loadPets(); // atualiza sem precisar fechar o app
  }

  Future<void> _goToDetalhes(Pet pet) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesPetPage(pet: pet)),
    );
    if (changed == true) _loadPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.yellow, title: const Text('Meus Pets')),
      body: _pets.isEmpty
          ? const Center(child: Text('Nenhum pet cadastrado'))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1, // quadrado
        ),
        itemBuilder: (_, i) {
          final pet = _pets[i];
          return GestureDetector(
            onTap: () => _goToDetalhes(pet),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(pet.imagePath), fit: BoxFit.cover),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: Text(
                      pet.nome,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCadastro,
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
