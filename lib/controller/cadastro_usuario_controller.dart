
import 'package:firebase_auth/firebase_auth.dart';

import '../model/app_state.dart';
import '../services/firebase_auth_service.dart';

class CadastroUsuarioController {
  final FirebaseAuthService _service = FirebaseAuthService();

  Future<String?> cadastrar(
    String nome,
    String email,
    String telefone,
    String senha,
    String confirmar,
  ) async {
    if (nome.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres.';
    }

    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    if (senha != confirmar) {
      return 'As senhas não coincidem.';
    }

    try {
      await _service.cadastrar(
        nome: nome,
        email: email,
        telefone: telefone,
        senha: senha,
      );

      AppState.instance.setAuthenticatedUser(
        name: nome.trim(),
        email: email.trim(),
        phone: telefone.trim(),
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este e-mail já está cadastrado.';
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'weak-password':
          return 'A senha é muito fraca.';
        default:
          return 'Não foi possível cadastrar: ${e.message}';
      }
    } catch (_) {
      return 'Ocorreu um erro ao criar a conta.';
    }
  }
}
