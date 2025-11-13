import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _adicionarIsAdminNoFirestore(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // Verificar se o campo isAdmin já existe no Firestore
    final doc = await userRef.get();
    if (!doc.exists || !doc.data()!.containsKey('isAdmin')) {
      await userRef.set({
        'isAdmin': false,  // Definindo isAdmin como false por padrão
      }, SetOptions(merge: true));
    }
  }

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

      await _adicionarIsAdminNoFirestore(credential.user!.uid);

      return credential.user;
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      rethrow;
    }
  }
}
