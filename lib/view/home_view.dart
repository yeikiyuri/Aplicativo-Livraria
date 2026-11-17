import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/app_state.dart'; 
import '../model/book.dart'; 
import 'widgets.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class HomeView extends StatefulWidget{
  const HomeView({super.key});
  @override 
  State<HomeView> createState()=>_HomeViewState();
}

class _HomeViewState extends State<HomeView>{
  int _index=0;@override Widget build(BuildContext context){
        final pages = [
        const OrdersContent(),    // 0 - Pedidos
        const CatalogContent(),   // 1 - Catálogo
        const SearchContent(),    // 2 - Buscar
        const FavoritesContent(), // 3 - Favoritos
        const CartContent(),      // 4 - Carrinho
      ];
      return Scaffold(
      backgroundColor:paper,appBar:AppBar(
        backgroundColor:paper,
        title:const Text('Livraria Super Legal',style:TextStyle(fontWeight:FontWeight.bold)),
        actions:[IconButton(tooltip:'Perfil',
        onPressed:()=>Navigator.pushNamed(context,'perfil'),
        icon:const Icon(Icons.person_outline)),
        PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'sobre') {
              Navigator.pushNamed(context, 'sobre');
            }

            if (v == 'sair') {
              await FirebaseAuthService().sair();

              AppState.instance.logout();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                'login',
                (route) => false,
              );
            }
          }, itemBuilder: (BuildContext context) { 
            return [
              const PopupMenuItem<String>(
                value: 'sobre',
                child: Text('Sobre'),
              ),
              const PopupMenuItem<String>(
                value: 'sair',
                child: Text('Sair'),
              ),
            ];
          },
          )
          ]
        ),
        body:pages[_index],
        bottomNavigationBar:NavigationBar(
          selectedIndex:_index,
          onDestinationSelected:(i)=>setState(()=>_index=i),
          destinations:[
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Pedidos',
            ),
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

class BookTile extends StatelessWidget {
  final Book book;

  const BookTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailView(book: book)),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(child: bookCover(book.title, height: 120)),
              ),
              const SizedBox(height: 8),
              Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'R\$ ${book.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ),
                  FavoriteButton(book: book, compact: true),
                ],
              ),
            ],
          ),
        ),
      );
}

class FavoriteButton extends StatefulWidget {
  final Book book;
  final bool compact;

  const FavoriteButton({
    super.key,
    required this.book,
    this.compact = false,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final FirestoreService _service = FirestoreService();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _favoriteStream;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _favoriteStream = _service.favoritoLivroStream(widget.book.id);
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book.id != widget.book.id) {
      _favoriteStream = _service.favoritoLivroStream(widget.book.id);
    }
  }

  Future<void> _toggleFavorite(
    List<String> documentIds,
    bool wasFavorite,
  ) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await _service.alternarFavorito(
        widget.book,
        documentosExistentes: documentIds,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFavorite
                ? 'Livro removido dos favoritos.'
                : 'Livro adicionado aos favoritos.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar favorito: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _favoriteStream,
      builder: (context, snapshot) {
        final documents = snapshot.data?.docs ?? [];
        final documentIds = documents.map((document) => document.id).toList();
        final isFavorite = documents.isNotEmpty;
        final isLoading =
            _isSaving ||
            (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasError);
        final icon = isFavorite ? Icons.favorite : Icons.favorite_border;

        if (widget.compact) {
          return IconButton(
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(icon, color: accent, size: 21),
            onPressed: isLoading
                ? null
                : () => _toggleFavorite(documentIds, isFavorite),
          );
        }

        return OutlinedButton.icon(
          onPressed: () async {
            try {
              await FirestoreService().adicionarFavorito(widget.book);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Livro salvo nos favoritos.'),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro: $e')),
              );
            }
          },
          icon: const Icon(Icons.favorite_border),
          label: const Text('Favoritar'),
        );

      },
    );
  }
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

class BookListTile extends StatelessWidget {
  final Book book;

  const BookListTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        leading: bookCover(book.title, height: 65),
        title: Text(book.title),
        subtitle: Text('${book.author} • ${book.genre}'),
        trailing: Text(
          'R\$ ${book.price.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookDetailView(book: book),
          ),
        ),
      ),
    );
  }
}

class BookDetailView extends StatelessWidget {
  final Book book;

  const BookDetailView({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: paper,
        appBar: AppBar(
          backgroundColor: paper,
          title: const Text('Detalhes do livro'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: bookCover(book.title, height: 220)),
              const SizedBox(height: 22),
              Text(
                book.title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: ink,
                ),
              ),
              Text(
                book.author,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Chip(label: Text(book.genre)),
              Text(
                book.description,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              Text(
                'R\$ ${book.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: FavoriteButton(book: book)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: accent),
                      onPressed: () {
                        AppState.instance.addToCart(book);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Livro adicionado ao carrinho.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('Adicionar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class FavoritesContent extends StatelessWidget {
  const FavoritesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageTitle('Favoritos', 'Seus livros salvos.'),
          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder(
              stream: service.favoritosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Erro ao carregar favoritos.',
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Tente novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final documentos =
                    snapshot.data?.docs ?? [];

                if (documentos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Você ainda não favoritou nenhum livro.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: documentos.length,
                  itemBuilder: (context, index) {
                    final doc = documentos[index];
                    final dados = doc.data();

                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: bookCover(
                          dados['titulo'] ?? '',
                          height: 65,
                        ),
                        title: Text(
                          dados['titulo'] ?? 'Livro',
                        ),
                        subtitle: Text(
                          dados['autor'] ?? '',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            try {
                              await service.removerFavorito(
                                doc.id,
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Favorito removido.',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Erro ao remover favorito: $e',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class CartContent extends StatelessWidget {
  const CartContent({super.key});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: AppState.instance,
        builder: (context, _) {
          final state = AppState.instance;
          final items = state.cart.entries.toList();

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageTitle(
                  'Seu carrinho',
                  'Confira os livros antes de finalizar.',
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('Seu carrinho está vazio.'))
                      : ListView(
                          children: items.map((entry) {
                            final book = state.books
                                .firstWhere((book) => book.id == entry.key);

                            return Card(
                              color: Colors.white,
                              child: ListTile(
                                leading: bookCover(book.title, height: 65),
                                title: Text(book.title),
                                subtitle: Text(
                                  'R\$ ${book.price.toStringAsFixed(2)} cada',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          state.changeQuantity(book, -1),
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),
                                    Text('${entry.value}'),
                                    IconButton(
                                      onPressed: () =>
                                          state.changeQuantity(book, 1),
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${state.cartTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.all(15),
                    ),
                    
                    onPressed: items.isEmpty
                     ? null
                     : () async {
                      try {
                        final itensPedido = items.map((entry) {
                          final livro = state.books.firstWhere(
                            (b) => b.id == entry.key,
                          );

                          return {
                            'livroId': livro.id,
                            'titulo': livro.title,
                            'autor': livro.author,
                            'preco': livro.price,
                            'quantidade': entry.value,
                          };
                        }).toList();

                        await FirestoreService().registrarPedido(
                          itens: itensPedido,
                          valorTotal: state.cartTotal,
                          quantidadeItens: state.cartCount,
                        );

                        state.clearCart();

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pedido registrado com sucesso!'),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao registrar pedido: $e'),
                          ),
                        );
                      }
                    }, child: const Text('Finalizar compra'),

                  ),
                ),
              ],
            ),
          );
        },
      );
}


class OrdersContent extends StatelessWidget {
  const OrdersContent({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageTitle(
            'Meus pedidos',
            'Histórico das suas compras.',
          ),
          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder(
              stream: service.pedidosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Não foi possível carregar os pedidos.',
                    ),
                  );
                }

                final documentos =
                    snapshot.data?.docs ?? [];

                if (documentos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Você ainda não realizou pedidos.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: documentos.length,
                  itemBuilder: (context, index) {
                    final pedido = documentos[index].data();

                    final itens = pedido['itens'] as List? ?? [];

                    final total =
                        (pedido['valorTotal'] as num?)
                                ?.toDouble() ??
                            0.0;

                    final quantidade =
                        pedido['quantidadeItens'] ?? 0;

                    final status =
                        pedido['status'] ?? 'Sem status';

                    final data =
                        pedido['dataPedido'] as Timestamp?;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),

                            const SizedBox(height: 8),

                            ...itens.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Text(
                                  '${item['titulo']} '
                                  '(${item['quantidade']}x)',
                                ),
                              );
                            }),

                            const Divider(),

                            Text('Quantidade: $quantidade itens'),

                            Text(
                              'Total: R\$ ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),

                            Text('Status: $status'),

                            if (data != null)
                              Text(
                                'Data: ${data.toDate().toLocal().toString().substring(0, 16)}',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
