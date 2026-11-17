import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> cadastrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );

    final user = credential.user!;

    await user.updateDisplayName(nome.trim());

    await _firestore.collection('usuarios').doc(user.uid).set({
      'nome': nome.trim(),
      'email': email.trim().toLowerCase(),
      'telefone': telefone.trim(),
      'uid': user.uid,
      'dataCadastro': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<UserCredential> entrar({
    required String email,
    required String senha,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<void> recuperarSenha(String email) {
    return _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> atualizarNome(String nome) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    await user.updateDisplayName(nome.trim());

    await _firestore.collection('usuarios').doc(user.uid).update({
      'nome': nome.trim(),
    });
  }

  Future<void> sair() {
    return _auth.signOut();
  }

  User? get usuarioAtual => _auth.currentUser;
}
