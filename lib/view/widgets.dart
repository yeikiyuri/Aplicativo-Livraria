import 'package:flutter/material.dart';

const ink=Color(0xFF2F2925); 
const paper=Color(0xFFF8F5F0); 
const accent=Color(0xFF7A4E35);

InputDecoration fieldDecoration(String label,{IconData? icon})=>InputDecoration(
  labelText:label,
  prefixIcon:icon==null?null:Icon(icon),
  border:OutlineInputBorder(borderRadius:BorderRadius.circular(14)),
  filled:true,
  fillColor:Colors.white
);
Widget pageTitle(String title,String subtitle)=>Column(
  crossAxisAlignment:CrossAxisAlignment.start,
  children:[
    Text(
      title,style:const TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:ink)
    ),
    const SizedBox(height:6),
    Text(
      subtitle,
      style:TextStyle(color:ink.withValues(alpha: .65))
    )
  ]
);
Widget bookCover(String title,{double height=145})=>Container(
  height:height,
  width:100,
  decoration:BoxDecoration(color:const Color(0xFFE7D9C9),
  borderRadius:BorderRadius.circular(10)),
  child:Center(
    child:Padding(
      padding:const EdgeInsets.all(8),
      child:Icon(Icons.menu_book_rounded,size:42,color:accent)
    )
  )
);
