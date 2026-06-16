// CRUD de avaliações no Firestore (RF003, RF004, RF005)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class AvaliacaoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Stream em tempo real das avaliações (RF005 — segunda coleção)
  Stream<QuerySnapshot> streamAvaliacoes() {
    return _db
        .collection(kColAvaliacoes)
        .where('uid', isEqualTo: _uid)
        .snapshots();
  }

  // Adicionar avaliação (RF003)
  Future<void> adicionarAvaliacao({
    required String filmeId,
    required String filmeTitulo,
    required String filmePoster,
    required double nota,
    required String comentario,
  }) async {
    final agora = FieldValue.serverTimestamp();
    await _db.collection(kColAvaliacoes).add({
      'uid':              _uid,
      'filmeId':          filmeId,
      'filmeTitulo':      filmeTitulo,
      'filmePoster':      filmePoster,
      'nota':             nota,
      'comentario':       comentario.trim(),
      'dataCriacao':      agora,
      'dataAtualizacao':  agora,
    });
  }

  // Atualizar avaliação existente (RF004)
  Future<void> atualizarAvaliacao({
    required String avaliacaoId,
    required double nota,
    required String comentario,
  }) async {
    await _db.collection(kColAvaliacoes).doc(avaliacaoId).update({
      'nota':             nota,
      'comentario':       comentario.trim(),
      'dataAtualizacao':  FieldValue.serverTimestamp(),
    });
  }

  // Excluir avaliação
  Future<void> excluirAvaliacao(String avaliacaoId) async {
    await _db.collection(kColAvaliacoes).doc(avaliacaoId).delete();
  }

  // Buscar avaliação de um filme específico do usuário
  Future<QuerySnapshot> buscarAvaliacaoDoFilme(String filmeId) {
    return _db
        .collection(kColAvaliacoes)
        .where('uid', isEqualTo: _uid)
        .where('filmeId', isEqualTo: filmeId)
        .get();
  }
}
