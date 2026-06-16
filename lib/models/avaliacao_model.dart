// Model de avaliação de um filme (nota + comentário)
class AvaliacaoModel {
  final String id;
  final String uid;
  final String filmeId;
  final String filmeTitulo;
  final String filmePoster;
  final double nota;          // 1.0 a 5.0
  final String comentario;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  AvaliacaoModel({
    required this.id,
    required this.uid,
    required this.filmeId,
    required this.filmeTitulo,
    required this.filmePoster,
    required this.nota,
    required this.comentario,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  factory AvaliacaoModel.fromFirestore(Map<String, dynamic> dados, String docId) {
    return AvaliacaoModel(
      id:               docId,
      uid:              dados['uid']            ?? '',
      filmeId:          dados['filmeId']        ?? '',
      filmeTitulo:      dados['filmeTitulo']    ?? '',
      filmePoster:      dados['filmePoster']    ?? '',
      nota:             (dados['nota'] as num?)?.toDouble() ?? 0.0,
      comentario:       dados['comentario']     ?? '',
      dataCriacao:      (dados['dataCriacao'] as dynamic)?.toDate() ?? DateTime.now(),
      dataAtualizacao:  (dados['dataAtualizacao'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid':              uid,
      'filmeId':          filmeId,
      'filmeTitulo':      filmeTitulo,
      'filmePoster':      filmePoster,
      'nota':             nota,
      'comentario':       comentario,
      'dataCriacao':      dataCriacao,
      'dataAtualizacao':  dataAtualizacao,
    };
  }
}
