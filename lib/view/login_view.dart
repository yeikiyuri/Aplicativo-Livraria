import 'package:flutter/material.dart';
import '../controller/login_controller.dart'; 
import 'widgets.dart';

class LoginView extends StatefulWidget { 
  const LoginView({super.key}); 
  @override 
  State<LoginView> createState()=>_LoginViewState(); 
}

class _LoginViewState extends State<LoginView>{ 
  final _form=GlobalKey<FormState>(); 
  final _email=TextEditingController(text:''); 
  final _senha=TextEditingController(); 
  final _controller=LoginController();
   bool _obscure=true;
  void _entrar(){
    if(!_form.currentState!.validate())return; 
      final erro=_controller.entrar(_email.text,_senha.text); 
    if(erro!=null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(erro)));
      return;
    } 
    Navigator.pushReplacementNamed(context,'home');
  }
  @override 
  void dispose(){
    _email.dispose();
    _senha.dispose();
    super.dispose();}
  @override 
  Widget build(BuildContext context)=>Scaffold(
    backgroundColor:paper,
    body:SafeArea(
      child:Center(
        child:SingleChildScrollView(
          padding:const EdgeInsets.all(24),
          child:ConstrainedBox(
            constraints:const BoxConstraints(maxWidth:440),
            child:Form(
              key:_form,
              child:Column(
                crossAxisAlignment:CrossAxisAlignment.stretch,
                children:[
                  Container(height:90,alignment:Alignment.center,child:const Icon(Icons.menu_book_rounded,size:64,color:accent)),
                  const Text(
                    'Livraria Super Legal',
                    textAlign:TextAlign.center,
                    style:TextStyle(
                      fontSize:30,
                      fontWeight:FontWeight.bold,color:ink
                    )
                  ),
                  const SizedBox(height:8),
                  const Text('Melhor livraria virtual.',
                  textAlign:TextAlign.center),
                  const SizedBox(height:32),
                  TextFormField(
                    controller:_email,decoration:fieldDecoration('E-mail',icon:Icons.email_outlined),
                    keyboardType:TextInputType.emailAddress,
                    validator:(v){
                      if(v==null||v.trim().isEmpty)return 'Informe o e-mail.';
                      if(!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()))return 'E-mail inválido.';return null;
                    }
                  ),
                  const SizedBox(height:14),
                  TextFormField(
                    controller:_senha,obscureText:_obscure,
                    decoration:fieldDecoration('Senha',icon:Icons.lock_outline).copyWith(suffixIcon:IconButton(icon:Icon(_obscure?Icons.visibility:Icons.visibility_off),onPressed:()=>setState(()=>_obscure=!_obscure))),validator:(v)=>v==null||v.isEmpty?'Informe a senha.':null
                  ),
                  Align(
                    alignment:Alignment.centerRight,
                    child:TextButton(
                      onPressed:()=>Navigator.pushNamed(context,'recuperar_senha'),
                      child:const Text('Esqueceu a senha?')
                    )
                  ),
                  const SizedBox(height:8),
                  FilledButton(style:FilledButton.styleFrom(backgroundColor:accent,padding:const EdgeInsets.all(16)),onPressed:_entrar,child:const Text('Entrar')),
                  TextButton(onPressed:()=>Navigator.pushNamed(context,'cadastro_usuario'),child:const Text('Criar uma conta')),
                  const SizedBox(height:18),
                  const Text('Exemplo: nome@email.com / 123456',textAlign:TextAlign.center,style:TextStyle(fontSize:12,color:Colors.black54))
                ]
              )
            )
          )
        )
      )
    )
  ); 
}
