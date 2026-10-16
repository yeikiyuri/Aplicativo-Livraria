import 'package:flutter/material.dart'; 
import '../controller/perfil_controller.dart'; 
import '../model/app_state.dart'; 
import 'widgets.dart';

class PerfilView extends StatefulWidget{
  const PerfilView({super.key});
  @override 
  State<PerfilView> createState()=>_PerfilViewState();
}

class _PerfilViewState extends State<PerfilView>{
  final _nome=TextEditingController();
  final _controller=PerfilController();
  
  @override 
  void initState(){
    super.initState();_nome.text=AppState.instance.currentUser?['name']??'';
  }

  @override 
  void dispose(){
    _nome.dispose();super.dispose();
  }

  @override 
  Widget build(BuildContext context)=>AnimatedBuilder(
    animation:AppState.instance,builder:(context,_) {
      final user=AppState.instance.currentUser;
      if(user==null){
        return const Scaffold(body:Center(child:Text('Faça login para acessar seu perfil.')));
      }
      if(_nome.text!=user['name']&&_nome.text.isEmpty)_nome.text=user['name']??'';
      return Scaffold(
        backgroundColor:paper,
        appBar:AppBar(title:const Text('Meu perfil'),
        backgroundColor:paper),
        body:Padding(
          padding:const EdgeInsets.all(24),
          child:Column(
            crossAxisAlignment:CrossAxisAlignment.stretch,
            children:[
              pageTitle('Meu perfil','Atualize suas informações.'),
              const SizedBox(height:24),
              const CircleAvatar(
                radius:38,backgroundColor:Color(0xFFE7D9C9),
                child:Icon(Icons.person,size:42,color:accent)
              ),
              const SizedBox(height:24),
              TextField(
                controller:_nome,
                decoration:fieldDecoration('Nome',icon:Icons.person_outline)
              ),
              const SizedBox(height:14),
              TextFormField(
                initialValue:user['email'],
                readOnly:true,
                decoration:fieldDecoration('E-mail',icon:Icons.email_outlined)
              ),
              const SizedBox(height:22),
              FilledButton(
                style:FilledButton.styleFrom(backgroundColor:accent,padding:const EdgeInsets.all(15)),
                onPressed:(){
                  final e=_controller.salvarNome(_nome.text);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e??'Perfil atualizado.')));
                },
                child:const Text('Salvar alterações')
              )
            ]
          )
        )
      );
    }
  );
}
