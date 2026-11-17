
import 'package:firebase_auth/firebase_auth.dart';

import '../model/app_state.dart';
import '../services/firebase_auth_service.dart';

class LoginController {
  final FirebaseAuthService _service = FirebaseAuthService();

  Future<String?> entrar(String email, String senha) async {
    try {
      final credential = await _service.entrar(
        email: email,
        senha: senha,
      );

      final user = credential.user!;

      AppState.instance.setAuthenticatedUser(
        name: user.displayName ?? 'Leitor',
        email: user.email ?? email,
        phone: '',
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'E-mail ou senha incorretos.';
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-disabled':
          return 'Esta conta foi desativada.';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde.';
        default:
          return 'Não foi possível entrar: ${e.message}';
      }
    } catch (_) {
      return 'Ocorreu um erro ao realizar o login.';
    }
  }
}
