// CRUD de filmes no Firestore
// Todos os dados filtrados por uid — nenhum usuário acessa dados de outro
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/omdb_model.dart';
import '../utils/constants.dart';

class FilmeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Stream em tempo real dos filmes do usuário (RF005 — StreamBuilder)
  Stream<QuerySnapshot> streamFilmes({String? statusFiltro}) {
    if (statusFiltro == null) {
      return _db
          .collection(kColFilmes)
          .where('uid', isEqualTo: _uid)
          .snapshots();
    }
    // Com filtro de status — sem orderBy para evitar índice composto
    return _db
        .collection(kColFilmes)
        .where('uid', isEqualTo: _uid)
        .where('status', isEqualTo: statusFiltro)
        .snapshots();
  }

  // Adicionar filme a partir dos dados da API OMDb (RF003)
  Future<void> adicionarFilme({
    required OmdbFilme omdbFilme,
    required String status,
  }) async {
    // Verificar se já existe para evitar duplicata
    final existente = await _db
        .collection(kColFilmes)
        .where('uid', isEqualTo: _uid)
        .where('imdbId', isEqualTo: omdbFilme.imdbId)
        .get();

    if (existente.docs.isNotEmpty) {
      throw Exception('Este filme já está na sua lista.');
    }

    await _db.collection(kColFilmes).add({
      'uid':            _uid,
      'imdbId':         omdbFilme.imdbId,
      'titulo':         omdbFilme.titulo,
      'tituloLower':    omdbFilme.titulo.toLowerCase(), // RF006 case-insensitive
      'ano':            omdbFilme.ano,
      'genero':         omdbFilme.genero,
      'diretor':        omdbFilme.diretor,
      'poster':         omdbFilme.poster,
      'imdbNota':       omdbFilme.imdbNota,
      'status':         status,
      'dataAdicionado': FieldValue.serverTimestamp(),
    });
  }

  // Atualizar status do filme (RF004)
  Future<void> atualizarStatus(String filmeId, String novoStatus) async {
    await _db.collection(kColFilmes).doc(filmeId).update({
      'status': novoStatus,
    });
  }

  // Excluir filme
  Future<void> excluirFilme(String filmeId) async {
    await _db.collection(kColFilmes).doc(filmeId).delete();
  }

  // Pesquisa case-insensitive por título (RF006)
  // Campo tituloLower armazenado em minúsculas — range query simula LIKE
  Stream<QuerySnapshot> pesquisarFilmes(String termo) {
    if (termo.trim().isEmpty) return streamFilmes();
    final t = termo.trim().toLowerCase();
    return _db
        .collection(kColFilmes)
        .where('uid', isEqualTo: _uid)
        .where('tituloLower', isGreaterThanOrEqualTo: t)
        .where('tituloLower', isLessThan: '${t}z')
        .snapshots();
  }
}
