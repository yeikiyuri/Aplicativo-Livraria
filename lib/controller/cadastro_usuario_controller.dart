import '../model/app_state.dart';

class CadastroUsuarioController { 
  final AppState state=AppState.instance; String? cadastrar(
    String nome,
    String email,
    String telefone,
    String senha,
    String confirmar)=>state.register(nome,email,telefone,senha,confirmar); 
}
