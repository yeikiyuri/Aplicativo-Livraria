
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firebase_auth_service.dart';

class PerfilController {
  final FirebaseAuthService _service = FirebaseAuthService();

  Future<String?> salvarNome(String nome) async {
    if (nome.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres.';
    }

    try {
      await _service.atualizarNome(nome);
      return null;
    } on FirebaseAuthException catch (e) {
      return 'Não foi possível atualizar: ${e.message}';
    } catch (_) {
      return 'Ocorreu um erro ao atualizar o perfil.';
    }
  }
}
