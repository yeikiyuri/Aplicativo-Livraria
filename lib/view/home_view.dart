import 'package:flutter/material.dart'; 
import '../model/app_state.dart'; 
import '../model/book.dart'; 
import 'widgets.dart';

class HomeView extends StatefulWidget{
  const HomeView({super.key});
  @override 
  State<HomeView> createState()=>_HomeViewState();
}

class _HomeViewState extends State<HomeView>{
  int _index=0;@override Widget build(BuildContext context){
    final pages=[const CatalogContent(),
    const SearchContent(),const FavoritesContent(),
    const CartContent()];return Scaffold(
      backgroundColor:paper,appBar:AppBar(
        backgroundColor:paper,
        title:const Text('Livraria Super Legal',style:TextStyle(fontWeight:FontWeight.bold)),
        actions:[IconButton(tooltip:'Perfil',
        onPressed:()=>Navigator.pushNamed(context,'perfil'),
        icon:const Icon(Icons.person_outline)),
        PopupMenuButton<String>(onSelected:(v){
          if(v=='sobre')Navigator.pushNamed(context,'sobre');
          if(v=='sair'){
            AppState.instance.logout();
            Navigator.pushNamedAndRemoveUntil(context,'login',(r)=>false);
          }
        },
        itemBuilder:(c)=>const [PopupMenuItem(value:'sobre',child:Text('Sobre')),
        PopupMenuItem(value:'sair',child:Text('Sair da conta'))])]
        ),
        body:pages[_index],
        bottomNavigationBar:NavigationBar(
          selectedIndex:_index,
          onDestinationSelected:(i)=>setState(()=>_index=i),
          destinations:[
            const NavigationDestination(icon:Icon(Icons.storefront_outlined),selectedIcon:Icon(Icons.storefront),label:'Catálogo'),
            const NavigationDestination(icon:Icon(Icons.search),label:'Buscar'),
            const NavigationDestination(icon:Icon(Icons.favorite_border),label:'Favoritos'),NavigationDestination(icon:Badge(
              label:Text('${AppState.instance.cartCount}'),isLabelVisible:AppState.instance.cartCount>0,
              child:
              const Icon(Icons.shopping_bag_outlined)
           ),
          label:'Carrinho')
          ]
        )
    );
  }
}

class CatalogContent extends StatelessWidget{
  const CatalogContent({super.key});
  @override
  Widget build(BuildContext context)=>AnimatedBuilder(
    animation:AppState.instance,builder:(context,_)=>CustomScrollView(
      slivers:[
        SliverToBoxAdapter(
          child:
          Padding(padding:const EdgeInsets.fromLTRB(20,18,20,12),
          child:
          Column(crossAxisAlignment:CrossAxisAlignment.start,
          children:
          [Text('Olá, ${AppState.instance.currentUser?['name']??'leitor'}',
          style:
          const TextStyle(color:accent,fontWeight:FontWeight.w600)),
          const SizedBox(height:6),
          pageTitle('Encontre sua próxima leitura','Histórias para todos os momentos.'),
          const SizedBox(height:18),
          Container(
            padding:
            const EdgeInsets.all(18),
            decoration:
            BoxDecoration(color:const Color(0xFFE7D9C9),
            borderRadius:
            BorderRadius.circular(18)),
            child:
            const Row(children:[
              Expanded(
                child:
                Column(
                crossAxisAlignment:CrossAxisAlignment.start,
                children:
                [Text('Um mundo de histórias',
                style:
                TextStyle(fontSize:19,fontWeight:FontWeight.bold,color:ink)),
                SizedBox(height:5),
                Text('Explore os títulos selecionados para você.',style:TextStyle(color:ink))]
               )
            ),
            Icon(Icons.auto_stories,size:52,color:accent)
            ])
          ),
          const SizedBox(height:20),
          const Text('Destaques',style:TextStyle(fontSize:21,fontWeight:FontWeight.bold))
          ]
        )
      )
    ),
    SliverPadding(padding:const EdgeInsets.symmetric(horizontal:16),sliver:SliverGrid(delegate:SliverChildBuilderDelegate((context,i)=>BookTile(book:AppState.instance.books[i]),childCount:AppState.instance.books.length),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:.66,crossAxisSpacing:12,mainAxisSpacing:12)))]
    )
  );
}

class BookTile extends StatelessWidget{
  final Book book;const BookTile({super.key,required this.book});
  @override
  Widget build(BuildContext context)=>InkWell(borderRadius:BorderRadius.circular(14),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>BookDetailView(book:book))),child:Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Center(child:bookCover(book.title,height:120))),const SizedBox(height:8),Text(book.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.bold)),Text(book.author,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,color:Colors.black54)),const Spacer(),Row(children:[Expanded(child:Text('R\$ ${book.price.toStringAsFixed(2)}',style:const TextStyle(fontWeight:FontWeight.bold,color:accent))),IconButton(constraints:const BoxConstraints(),padding:EdgeInsets.zero,icon:Icon(AppState.instance.isFavorite(book)?Icons.favorite:Icons.favorite_border,color:accent,size:21),onPressed:()=>AppState.instance.toggleFavorite(book))])])));
}

class SearchContent extends StatefulWidget{
  const SearchContent({super.key});
  @override 
  State<SearchContent> createState()=>_SearchContentState();
}

class _SearchContentState extends State<SearchContent>{
  String query='';String genre='Todos';
  @override 
  Widget build(BuildContext context)=>AnimatedBuilder(animation:AppState.instance,builder:(context,_) {final genres=['Todos',...{...AppState.instance.books.map((b)=>b.genre)}];final results=AppState.instance.books.where((b)=>(b.title.toLowerCase().contains(query.toLowerCase())||b.author.toLowerCase().contains(query.toLowerCase()))&&(genre=='Todos'||b.genre==genre)).toList();return Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[pageTitle('Buscar livros','Pesquise por título, autor ou gênero.'),const SizedBox(height:16),TextField(onChanged:(v)=>setState(()=>query=v),decoration:fieldDecoration('Buscar',icon:Icons.search)),const SizedBox(height:12),DropdownButtonFormField<String>(initialValue:genre,decoration:fieldDecoration('Gênero'),items:genres.map((g)=>DropdownMenuItem(value:g,child:Text(g))).toList(),onChanged:(v)=>setState(()=>genre=v??'Todos')),const SizedBox(height:12),Expanded(child:results.isEmpty?const Center(child:Text('Nenhum livro encontrado.')):ListView.builder(itemCount:results.length,itemBuilder:(context,i)=>BookListTile(book:results[i]))) ]));});
}

class BookListTile extends StatelessWidget{
  final Book book;const BookListTile({super.key,required this.book});
  @override 
  Widget build(BuildContext context)=>Card(color:Colors.white,child:ListTile(leading:bookCover(book.title,height:65),title:Text(book.title),subtitle:Text('${book.author} • ${book.genre}'),trailing:Text('R\$ ${book.price.toStringAsFixed(2)}',style:const TextStyle(fontWeight:FontWeight.bold,color:accent)),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>BookDetailView(book:book)))));
}

class BookDetailView extends StatelessWidget{
  final Book book;const BookDetailView({super.key,required this.book});
  @override 
  Widget build(BuildContext context)=>AnimatedBuilder(animation:AppState.instance,builder:(context,_)=>Scaffold(backgroundColor:paper,appBar:AppBar(backgroundColor:paper,title:const Text('Detalhes do livro')),body:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Center(child:bookCover(book.title,height:220)),const SizedBox(height:22),Text(book.title,style:const TextStyle(fontSize:27,fontWeight:FontWeight.bold,color:ink)),Text(book.author,style:const TextStyle(fontSize:16,color:Colors.black54)),const SizedBox(height:12),Chip(label:Text(book.genre)),Text(book.description,style:const TextStyle(fontSize:16,height:1.5)),const Spacer(),Text('R\$ ${book.price.toStringAsFixed(2)}',style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:accent)),const SizedBox(height:12),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>AppState.instance.toggleFavorite(book),icon:Icon(AppState.instance.isFavorite(book)?Icons.favorite:Icons.favorite_border),label:Text(AppState.instance.isFavorite(book)?'Favoritado':'Favoritar'))),const SizedBox(width:10),Expanded(child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:accent),onPressed:(){AppState.instance.addToCart(book);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Livro adicionado ao carrinho.')));},icon:const Icon(Icons.shopping_bag_outlined),label:const Text('Adicionar')))])]))));
}

class FavoritesContent extends StatelessWidget{
  const FavoritesContent({super.key});
  @override 
  Widget build(BuildContext context)=>AnimatedBuilder(animation:AppState.instance,builder:(context,_)=>Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[pageTitle('Favoritos','Seus livros salvos.'),const SizedBox(height:12),Expanded(child:AppState.instance.favorites.isEmpty?const Center(child:Text('Você ainda não favoritou nenhum livro.')):ListView(children:AppState.instance.favorites.map((b)=>BookListTile(book:b)).toList()))])));
}

class CartContent extends StatelessWidget{
  const CartContent({super.key});
  @override 
  Widget build(BuildContext context)=>AnimatedBuilder(animation:AppState.instance,builder:(context,_) {final state=AppState.instance;final items=state.cart.entries.toList();return Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[pageTitle('Seu carrinho','Confira os livros antes de finalizar.'),const SizedBox(height:12),Expanded(child:items.isEmpty?const Center(child:Text('Seu carrinho está vazio.')):ListView(children:items.map((e){final b=state.books.firstWhere((b)=>b.id==e.key);return Card(color:Colors.white,child:ListTile(leading:bookCover(b.title,height:65),title:Text(b.title),subtitle:Text('R\$ ${b.price.toStringAsFixed(2)} cada'),trailing:Row(mainAxisSize:MainAxisSize.min,children:[IconButton(onPressed:()=>state.changeQuantity(b,-1),icon:const Icon(Icons.remove_circle_outline)),Text('${e.value}'),IconButton(onPressed:()=>state.changeQuantity(b,1),icon:const Icon(Icons.add_circle_outline))])));}).toList())),const Divider(),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Total',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),Text('R\$ ${state.cartTotal.toStringAsFixed(2)}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:accent))]),const SizedBox(height:12),SizedBox(width:double.infinity,child:FilledButton(style:FilledButton.styleFrom(backgroundColor:accent,padding:const EdgeInsets.all(15)),onPressed:items.isEmpty?null:(){showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Compra simulada'),content:Text('Pedido demonstrativo no valor de R\$ ${state.cartTotal.toStringAsFixed(2)}. Nenhum pagamento foi realizado.'),actions:[TextButton(onPressed:(){state.clearCart();Navigator.pop(c);},child:const Text('Concluir'))]));},child:const Text('Finalizar compra')))]));});
}
