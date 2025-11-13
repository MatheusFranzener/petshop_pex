import 'package:cloud_firestore/cloud_firestore.dart';

class PetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para salvar o pet
  Future<void> salvarPet(String nome, String idade, String raca, String porte, String imageUrl, String uid) async {
    try {
      await _firestore.collection('pets').add({
        'nome': nome,
        'idade': idade,
        'raca': raca,
        'porte': porte,
        'imageUrl': imageUrl,
        'uid': uid,
      });
    } catch (e) {
      print('Erro ao salvar pet: $e');
      throw Exception('Erro ao salvar pet');
    }
  }

  // Função para obter todos os pets
  Future<List<Map<String, dynamic>>> obterPets() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('pets').get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nome': doc['nome'],
          'idade': doc['idade'],
          'raca': doc['raca'],
          'porte': doc['porte'],
          'imageUrl': doc['imageUrl'],
        };
      }).toList();
    } catch (e) {
      print('Erro ao obter pets: $e');
      throw Exception('Erro ao obter pets');
    }
  }
}
