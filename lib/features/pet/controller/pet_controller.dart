import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetController extends ChangeNotifier {
  bool isLoading = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> cadastrarPet(String nome, String tipo, String idade,
      File? imagemPet, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      String? urlImagem;

      // Se houver imagem, faz upload no Firebase Storage
      if (imagemPet != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('pets/${DateTime.now().millisecondsSinceEpoch}.png');
        await ref.putFile(imagemPet);
        urlImagem = await ref.getDownloadURL();
      }

      // Salva as informações no Firestore
      await _db.collection('pets').add({
        'nome': nome,
        'tipo': tipo,
        'idade': idade,
        'imagem': urlImagem ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet cadastrado com sucesso!')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar pet: $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
