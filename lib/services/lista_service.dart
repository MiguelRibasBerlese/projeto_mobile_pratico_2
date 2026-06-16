// CRUD de listas personalizadas no Firestore (RF003, RF004, RF005)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class ListaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Stream em tempo real das listas (RF005 — terceira coleção)
  Stream<QuerySnapshot> streamListas() {
    return _db
        .collection(kColListas)
        .where('uid', isEqualTo: _uid)
        .orderBy('dataCriacao')
        .snapshots();
  }

  // Criar nova lista (RF003)
  Future<void> criarLista({
    required String nome,
    required String descricao,
    required String cor,
  }) async {
    await _db.collection(kColListas).add({
      'uid':          _uid,
      'nome':         nome.trim(),
      'descricao':    descricao.trim(),
      'cor':          cor,
      'filmeIds':     [],
      'dataCriacao':  FieldValue.serverTimestamp(),
    });
  }

  // Atualizar lista (RF004)
  Future<void> atualizarLista({
    required String listaId,
    required String nome,
    required String descricao,
    required String cor,
  }) async {
    await _db.collection(kColListas).doc(listaId).update({
      'nome':      nome.trim(),
      'descricao': descricao.trim(),
      'cor':       cor,
    });
  }

  // Adicionar filme a uma lista
  Future<void> adicionarFilmeNaLista(String listaId, String filmeId) async {
    await _db.collection(kColListas).doc(listaId).update({
      'filmeIds': FieldValue.arrayUnion([filmeId]),
    });
  }

  // Remover filme de uma lista
  Future<void> removerFilmeDaLista(String listaId, String filmeId) async {
    await _db.collection(kColListas).doc(listaId).update({
      'filmeIds': FieldValue.arrayRemove([filmeId]),
    });
  }

  // Excluir lista
  Future<void> excluirLista(String listaId) async {
    await _db.collection(kColListas).doc(listaId).delete();
  }
}
