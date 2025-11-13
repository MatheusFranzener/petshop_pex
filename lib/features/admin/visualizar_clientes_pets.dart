import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petshop_pex/features/nav_button.dart';
import './cards/clientePet_card.dart';

class ClientesPetsPage extends StatelessWidget {
  const ClientesPetsPage({super.key});

  Future<String> _getNomeDono(String uid) async {
    return 'Desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    final petsCollection = FirebaseFirestore.instance.collection('pets');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes e Pets'),
        backgroundColor: Colors.yellow,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar Cliente ou Pet...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                // Implementar a lógica de busca dps qnd tiver a integração
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: petsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
                }

                final pets = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final petData = pets[index].data() as Map<String, dynamic>;
                    final uid = petData['uid'];
                    final fotoPet = petData['fotoPet'] ?? '';
                    final nomePet = petData['nomePet'] ?? '';
                    final idade = petData['idade'] ?? '';
                    final raca = petData['raca'] ?? '';
                    final porte = petData['porte'] ?? '';

                    return FutureBuilder<String>(
                      future: _getNomeDono(uid),
                      builder: (context, nomeDonoSnapshot) {
                        if (nomeDonoSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final nomeDono = nomeDonoSnapshot.data ?? 'Desconhecido';
                        return ClientePetCard(
                          imageUrl: fotoPet,
                          nomeDono: nomeDono,
                          nome: nomePet,
                          idade: idade,
                          raca: raca,
                          porte: porte,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const FloatingNavButton(),
    );
  }
}
