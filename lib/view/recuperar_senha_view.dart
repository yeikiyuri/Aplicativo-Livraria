import 'package:flutter/material.dart'; 
import '../controller/recuperar_senha_controller.dart'; 
import 'widgets.dart';

class RecuperarSenhaView extends StatefulWidget{
  const RecuperarSenhaView({super.key});
  @override 
  State<RecuperarSenhaView> createState()=>_RecuperarSenhaViewState();
}

class _RecuperarSenhaViewState extends State<RecuperarSenhaView>{
  final _email=TextEditingController();
  final _controller=RecuperarSenhaController();

  @override 
  void dispose(){_email.dispose();super.dispose();}
  void _solicitar(){
    final e=_controller.solicitar(_email.text);
    if(e!=null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e)));
      return;
    }
    showDialog(
      context:context,
      builder:(c)=>AlertDialog(
        title:const Text('Solicitação validada'),
        content:const Text('A conta foi encontrada. Porém este protótipo não consegue enviar emails.'),
        actions:[
          TextButton(
            onPressed:()=>Navigator.pop(c),
            child:const Text('OK')
          )
        ]
      )
    );
  }
  @override  
  Widget build(BuildContext context)=>Scaffold(backgroundColor:paper,appBar:AppBar(backgroundColor:paper,title:const Text('Recuperar senha')),body:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[pageTitle('Esqueceu a senha?','Informe o e-mail associado à sua conta.'),const SizedBox(height:24),TextField(controller:_email,keyboardType:TextInputType.emailAddress,decoration:fieldDecoration('E-mail',icon:Icons.email_outlined)),const SizedBox(height:18),FilledButton(style:FilledButton.styleFrom(backgroundColor:accent,padding:const EdgeInsets.all(15)),onPressed:_solicitar,child:const Text('Solicitar recuperação'))])));
}
