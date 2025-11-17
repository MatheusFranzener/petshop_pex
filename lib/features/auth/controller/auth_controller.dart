import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petshop_pex/features/admin/pages/home_admin.dart';
import 'package:petshop_pex/features/auth/pages/login.dart';
import 'package:petshop_pex/features/auth/repository/auth_repository.dart';
import 'package:petshop_pex/features/pet/pages/home.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();

  bool isLoading = false;

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  Future<bool> isCurrentUserAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;

    final data = doc.data();
    return (data?['isAdmin'] as bool?) ?? false;
  }

  // Função para login
  Future<void> login(String email, String senha, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final uid = cred.user!.uid;

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final isAdmin = (snap.data()?['isAdmin'] as bool?) ?? false;

      if (context.mounted) {
        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeAdmin(
              useMock: false,
              skipGate: true,
            )),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      }
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

      await _authRepository.cadastrar(email, senha);

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

