import '../model/app_state.dart';

class RecuperarSenhaController { 
  final AppState state=AppState.instance; 
  String? solicitar(String email)=>state.recover(email); 
}
