import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:petshop_pex/features/nav_button.dart';

import '../models/pet_model.dart';
import '../repository/pet_local_repository.dart';
import 'cadastro_pet.dart';
import 'detalhes_pet.dart';
import 'servicos_cliente.dart';
// import 'status_page.dart'; // <-- NÃO PRECISA MAIS AQUI
import 'status_pets_page.dart'; // usa essa

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
    if (changed == true) _loadPets();
  }

  Future<void> _goToDetalhes(Pet pet) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalhesPetPage(pet: pet)),
    );
    if (changed == true) _loadPets();
  }

  void _goToServicosCliente() {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cadastre um pet primeiro')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServicosClientePage(pets: _pets)),
    );
  }

  // AGORA: vai pra lista de pets com agendamento (StatusPetsPage)
  void _goToStatus() {
    if (_pets.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cadastre um pet primeiro')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StatusPetsPage(pets: _pets)),
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Cadastrar pets'),
              onTap: () {
                Navigator.pop(context);
                _goToCadastro();
              },
            ),
            ListTile(
              leading: const Icon(Icons.miscellaneous_services),
              title: const Text('Serviços'),
              onTap: () {
                Navigator.pop(context);
                _goToServicosCliente();
              },
            ),
            ListTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Status'),
              onTap: () {
                Navigator.pop(context);
                _goToStatus();
              },
            ),
          ],
        );
      },
    );
  }

  // ------- WIDGET DA FOTO DO PET (WEB + MOBILE) -------
  Widget _buildPetImage(Pet pet) {
    if (pet.imagePath.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.pets, size: 48, color: Colors.white),
      );
    }

    if (kIsWeb) {
      return Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.pets, size: 48, color: Colors.white),
      );
    }

    final file = File(pet.imagePath);
    if (!file.existsSync()) {
      return Container(
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.pets, size: 48, color: Colors.white),
      );
    }

    return Image.file(file, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: _openMenu,
        ),
        title: const Text(
          'Meus Pets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _pets.isEmpty
          ? const Center(child: Text('Nenhum pet cadastrado'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
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
                        _buildPetImage(pet),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
