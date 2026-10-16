import 'package:flutter/foundation.dart';
import 'book.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  final List<Book> books = const [
    Book(id:'1', title:'Dom Casmurro', author:'Machado de Assis', genre:'Clássico', description:'Um dos grandes romances da literatura brasileira, narrado por Bentinho.', price:29.90),
    Book(id:'2', title:'O Hobbit', author:'J. R. R. Tolkien', genre:'Fantasia', description:'Uma aventura inesperada que leva Bilbo Bolseiro para longe de casa.', price:39.90),
    Book(id:'3', title:'1984', author:'George Orwell', genre:'Ficção', description:'Um romance distópico sobre vigilância, poder e liberdade.', price:34.90),
    Book(id:'4', title:'Orgulho e Preconceito', author:'Jane Austen', genre:'Romance', description:'Uma história sobre relações, primeiras impressões e sociedade.', price:32.50),
    Book(id:'5', title:'O Pequeno Príncipe', author:'Antoine de Saint-Exupéry', genre:'Infantil', description:'Uma narrativa sensível sobre amizade e o que realmente importa.', price:24.90),
    Book(id:'6', title:'Duna', author:'Frank Herbert', genre:'Ficção científica', description:'Intrigas políticas e sobrevivência em um planeta desértico.', price:49.90),
    Book(id:'7', title:'A Revolução dos Bichos', author:'George Orwell', genre:'Clássico', description:'Uma fábula política sobre poder e revolução.', price:22.90),
    Book(id:'8', title:'Percy Jackson', author:'Rick Riordan', genre:'Fantasia', description:'Um adolescente descobre que os mitos gregos estão mais próximos do que imaginava.', price:36.90),
  ];

  final Map<String, Map<String,String>> _users = {
    'nome@email.com': {'name':'Leitor','email':'nome@email.com','phone':'(00) 00000-0000','password':'123456'}
  };

  Map<String,String>? _currentUser;
  Map<String,String>? get currentUser => _currentUser == null ? null : Map.unmodifiable(_currentUser!);
  final Set<String> _favoriteIds = {};
  final Map<String,int> _cart = {};
  List<Book> get favorites => books.where((b)=>_favoriteIds.contains(b.id)).toList();
  Map<String,int> get cart => Map.unmodifiable(_cart);
  int get cartCount => _cart.values.fold(0,(a,b)=>a+b);
  double get cartTotal => _cart.entries.fold(0.0,(sum,e)=>sum + books.firstWhere((b)=>b.id==e.key).price*e.value);
  bool isFavorite(Book b)=>_favoriteIds.contains(b.id);

  String? login(String email,String password) {
    if(email.trim().isEmpty || password.isEmpty) return 'Preencha e-mail e senha.';
    if(!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) return 'Informe um e-mail válido.';
    final user=_users[email.trim().toLowerCase()];
    if(user==null || user['password']!=password) return 'E-mail ou senha incorretos.';
    _currentUser=user; 
    notifyListeners(); 
    return null;
  }

  String? register(String name,String email,String phone,String password,String confirm) {
    if([name,email,phone,password,confirm].any((v)=>v.trim().isEmpty)) return 'Preencha todos os campos.';
    if(name.trim().length<3) return 'O nome deve ter pelo menos 3 caracteres.';
    if(!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) return 'Informe um e-mail válido.';
    if(password!=confirm) return 'As senhas não coincidem.';
    if(password.length<6) return 'A senha deve ter pelo menos 6 caracteres.';
    final key=email.trim().toLowerCase(); if(_users.containsKey(key)) return 'Este e-mail já está cadastrado.';
    _users[key]={'name':name.trim(),'email':key,'phone':phone.trim(),'password':password}; 
    _currentUser=_users[key]; 
    notifyListeners(); 
    return null;
  }

  String? recover(String email) {
    if(email.trim().isEmpty) return 'Informe seu e-mail.';
    if(!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim())) return 'Informe um e-mail válido.';
    if(!_users.containsKey(email.trim().toLowerCase())) return 'Não existe conta com esse e-mail.';
    return null;
  }

  String? updateName(String name) {
    if(_currentUser==null) return 'Faça login novamente.';
    if(name.trim().length<3) return 'O nome deve ter pelo menos 3 caracteres.';
    _currentUser!['name']=name.trim(); 
    _users[_currentUser!['email']!]!['name']=name.trim(); 
    notifyListeners(); 
    return null;
  }
  
  void toggleFavorite(Book b) { 
    if(!_favoriteIds.add(b.id)) _favoriteIds.remove(b.id); notifyListeners(); 
  }
  void addToCart(Book b) { 
    _cart.update(b.id,(n)=>n+1,ifAbsent:()=>1); notifyListeners(); 
  }
  void changeQuantity(Book b,int amount) { 
    final next=(_cart[b.id]??0)+amount; 
    if(next<=0) {_cart.remove(b.id);} 
    else {_cart[b.id]=next;} 
    notifyListeners(); 
  }
  void clearCart() { 
    _cart.clear(); 
    notifyListeners(); 
  }
  void logout() { 
    _currentUser=null; 
    notifyListeners(); 
  }
}
