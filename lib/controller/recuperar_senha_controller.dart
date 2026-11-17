
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firebase_auth_service.dart';

class RecuperarSenhaController {
  final FirebaseAuthService _service = FirebaseAuthService();

  Future<String?> solicitar(String email) async {
    if (email.trim().isEmpty) {
      return 'Informe seu e-mail.';
    }

    try {
      await _service.recuperarSenha(email);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-not-found':
          return 'Não existe uma conta com esse e-mail.';
        default:
          return 'Não foi possível enviar o e-mail: ${e.message}';
      }
    } catch (_) {
      return 'Ocorreu um erro ao solicitar a recuperação.';
    }
  }
}
