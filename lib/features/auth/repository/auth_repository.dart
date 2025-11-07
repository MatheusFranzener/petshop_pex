import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String senha) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return credential.user;
    } catch (e) {
      print('Erro ao fazer login: $e');
      rethrow;
    }
  }

  Future<User?> cadastrar(String email, String senha) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return credential.user;
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      rethrow;
    }
  }
}
