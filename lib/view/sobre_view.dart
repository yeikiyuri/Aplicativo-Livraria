import 'package:flutter/material.dart'; 
import '../controller/sobre_controller.dart'; 
import 'widgets.dart';

class SobreView extends StatelessWidget{
  const SobreView({super.key});
  @override 
  Widget build(BuildContext context){
    final c=SobreController();
    return Scaffold(
      backgroundColor:paper,
      appBar:AppBar(title:const Text('Sobre o projeto'),backgroundColor:paper),
      body:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[pageTitle(c.nomeAplicativo,'Informações do aplicativo'),
      const SizedBox(height:24),
      const Icon(Icons.menu_book_rounded,size:64,color:accent),
      const SizedBox(height:16),
      const Text('Objetivo',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      Text(c.objetivo),
      const SizedBox(height:24),
      const Text('Equipe de desenvolvimento',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      const Text('Aluno: Yuri Yeiki Perez da Costa'),
      const SizedBox(height:24),
      const Text('Disciplina: Programação para Dispositivos Móveis'),
      const Text('Instituição: Fatec Ribeirão Preto'),
      const Text('Professor(a): Rodrigo de Oliveira Plotze'),
      const Spacer(),
      const Text('Versão demonstrativa',style:TextStyle(color:Colors.black54))]))
    );
  }
}
