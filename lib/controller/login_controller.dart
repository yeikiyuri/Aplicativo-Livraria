import '../model/app_state.dart';

class LoginController {
  final AppState state=AppState.instance; String? entrar(
    String email,
    String senha)=>state.login(email,senha); 
}
