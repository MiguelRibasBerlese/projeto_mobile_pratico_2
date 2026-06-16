// Model de filme salvo no Firestore pelo usuário
class FilmeModel {
  final String id;          // ID do documento Firestore
  final String uid;         // ID do usuário dono
  final String imdbId;      // ID do filme na OMDb
  final String titulo;
  final String tituloLower; // para pesquisa case-insensitive (RF006)
  final String ano;
  final String genero;
  final String diretor;
  final String poster;
  final String status;      // 'quero_ver' ou 'assistido'
  final DateTime dataAdicionado;

  FilmeModel({
    required this.id,
    required this.uid,
    required this.imdbId,
    required this.titulo,
    required this.tituloLower,
    required this.ano,
    required this.genero,
    required this.diretor,
    required this.poster,
    required this.status,
    required this.dataAdicionado,
  });

  factory FilmeModel.fromFirestore(Map<String, dynamic> dados, String docId) {
    return FilmeModel(
      id:             docId,
      uid:            dados['uid']          ?? '',
      imdbId:         dados['imdbId']       ?? '',
      titulo:         dados['titulo']       ?? '',
      tituloLower:    dados['tituloLower']  ?? '',
      ano:            dados['ano']          ?? '',
      genero:         dados['genero']       ?? '',
      diretor:        dados['diretor']      ?? '',
      poster:         dados['poster']       ?? '',
      status:         dados['status']       ?? 'quero_ver',
      dataAdicionado: (dados['dataAdicionado'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid':            uid,
      'imdbId':         imdbId,
      'titulo':         titulo,
      'tituloLower':    titulo.toLowerCase(),
      'ano':            ano,
      'genero':         genero,
      'diretor':        diretor,
      'poster':         poster,
      'status':         status,
      'dataAdicionado': dataAdicionado,
    };
  }
}
