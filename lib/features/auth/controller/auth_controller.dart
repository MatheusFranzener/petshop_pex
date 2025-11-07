import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petshop_pex/features/pet/pages/home.dart';  // Adicionar essa importação


class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  // Função para login
  Future<void> login(String email, String senha, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Tenta fazer login
      await _auth.signInWithEmailAndPassword(email: email, password: senha);

      // Se o login for bem-sucedido, redireciona para a HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Função para cadastro
  Future<void> cadastrar(String email, String senha, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Cria o usuário no Firebase
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);

      // Notifica o sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );

      Navigator.pop(context); // Volta para a tela de login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

