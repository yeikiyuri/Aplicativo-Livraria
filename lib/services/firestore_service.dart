
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/book.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return user.uid;
  }

  Future<void> adicionarFavorito(Book livro) async {
    final uid = _uid;

    await _db.collection('favoritos').doc(_favoriteDocumentId(uid, livro.id)).set({
      'usuarioId': uid,
      'livroId': livro.id,
      'titulo': livro.title,
      'autor': livro.author,
      'preco': livro.price,
      'dataAdicao': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removerFavorito(String documentoId) async {
    final uid = _uid;

    final ref = _db.collection('favoritos').doc(documentoId);
    final doc = await ref.get();

    if (doc.exists && doc.data()?['usuarioId'] == uid) {
      await ref.delete();
    }
  }

  Future<void> alternarFavorito(
    Book livro, {
    required List<String> documentosExistentes,
  }) async {
    if (documentosExistentes.isEmpty) {
      await adicionarFavorito(livro);
      return;
    }

    final batch = _db.batch();
    for (final documentoId in documentosExistentes) {
      batch.delete(_db.collection('favoritos').doc(documentoId));
    }
    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> favoritoLivroStream(
    String livroId,
  ) {
    return _db
        .collection('favoritos')
        .where('usuarioId', isEqualTo: _uid)
        .where('livroId', isEqualTo: livroId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> favoritosStream() {
    return _db
        .collection('favoritos')
        .where('usuarioId', isEqualTo: _uid)
        .snapshots();
  }

  // REGISTRAR PEDIDO
  Future<void> registrarPedido({
    required List<Map<String, dynamic>> itens,
    required double valorTotal,
    required int quantidadeItens,
  }) async {
    await _db.collection('pedidos').add({
      'usuarioId': _uid,
      'itens': itens,
      'valorTotal': valorTotal,
      'quantidadeItens': quantidadeItens,
      'status': 'Concluído',
      'dataPedido': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pedidosStream() {
    return _db
        .collection('pedidos')
        .where('usuarioId', isEqualTo: _uid)
        .snapshots();
  }

  String _favoriteDocumentId(String uid, String livroId) {
    final encodedId = base64Url.encode(utf8.encode(livroId)).replaceAll('=', '');
    return '${uid}_$encodedId';
  }
}
