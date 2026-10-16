import 'package:flutter/material.dart'; 
import '../controller/cadastro_usuario_controller.dart'; 
import 'widgets.dart';

class CadastroUsuarioView extends StatefulWidget{
  const CadastroUsuarioView({super.key});
  @override 
  State<CadastroUsuarioView> createState()=>_CadastroUsuarioViewState();
}

class _CadastroUsuarioViewState extends State<CadastroUsuarioView>{
  final _form=GlobalKey<FormState>();
  final _nome=TextEditingController();
  final _email=TextEditingController();
  final _fone=TextEditingController();
  final _senha=TextEditingController();
  final _conf=TextEditingController();
  final _controller=CadastroUsuarioController();

  @override 
  void dispose(){
    for(final c in [_nome,_email,_fone,_senha,_conf]){
      c.dispose();
    }
    super.dispose(); 
  }

  void _cadastrar(){
    if(!_form.currentState!.validate())return;
    final e=_controller.cadastrar(_nome.text,_email.text,_fone.text,_senha.text,_conf.text);
    if(e!=null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e)));
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context,'home',(r)=>false);
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:paper,
      appBar:AppBar(title:const Text('Criar conta'),
      backgroundColor:paper),
      body:SafeArea(
        child:Center(
          child:SingleChildScrollView(
            padding:const EdgeInsets.all(22),
            child:ConstrainedBox(
              constraints:const BoxConstraints(maxWidth:480),
              child:Form(
                key:_form,
                child:Column(
                  crossAxisAlignment:CrossAxisAlignment.stretch,
                  children:[
                    pageTitle('Boas-vindas','Cadastre-se para explorar a livraria.'),
                    const SizedBox(height:24),
                    TextFormField(
                      controller:_nome,
                      decoration:fieldDecoration('Nome completo',icon:Icons.person_outline),
                      validator:(v)=>v==null||v.trim().length<3?'Informe um nome com pelo menos 3 caracteres.':null),
                      const SizedBox(height:12),
                      TextFormField(controller:_email,decoration:fieldDecoration('E-mail',icon:Icons.email_outlined),keyboardType:TextInputType.emailAddress,validator:(v)=>v==null||!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())?'Informe um e-mail válido.':null),
                      const SizedBox(height:12),
                      TextFormField(controller:_fone,decoration:fieldDecoration('Telefone',icon:Icons.phone_outlined),keyboardType:TextInputType.phone,validator:(v)=>v==null||v.trim().isEmpty?'Informe o telefone.':null),
                      const SizedBox(height:12),
                      TextFormField(controller:_senha,decoration:fieldDecoration('Senha',icon:Icons.lock_outline),obscureText:true,validator:(v)=>v==null||v.length<6?'Use pelo menos 6 caracteres.':null),
                      const SizedBox(height:12),
                      TextFormField(controller:_conf,decoration:fieldDecoration('Confirmar senha',icon:Icons.lock_reset),obscureText:true,validator:(v)=>v!=_senha.text?'As senhas não coincidem.':null),
                      const SizedBox(height:22),
                      FilledButton(style:FilledButton.styleFrom(backgroundColor:accent,padding:const EdgeInsets.all(15)),onPressed:_cadastrar,child:const Text('Cadastrar')
                    )
                  ]
                )
              )
            )
          )
        )
      )
    );
  }
}
