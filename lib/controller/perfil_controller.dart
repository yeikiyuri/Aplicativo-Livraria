import '../model/app_state.dart';

class PerfilController { 
  final AppState state=AppState.instance;
   String? salvarNome(String nome)=>state.updateName(nome); 
}
