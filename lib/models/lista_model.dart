// Model de lista personalizada de filmes (ex: "Favoritos", "Assistir depois")
class ListaModel {
  final String id;
  final String uid;
  final String nome;
  final String descricao;
  final String cor;           // hex string, ex: '#E50914'
  final List<String> filmeIds;
  final DateTime dataCriacao;

  ListaModel({
    required this.id,
    required this.uid,
    required this.nome,
    required this.descricao,
    required this.cor,
    required this.filmeIds,
    required this.dataCriacao,
  });

  factory ListaModel.fromFirestore(Map<String, dynamic> dados, String docId) {
    return ListaModel(
      id:           docId,
      uid:          dados['uid']         ?? '',
      nome:         dados['nome']        ?? '',
      descricao:    dados['descricao']   ?? '',
      cor:          dados['cor']         ?? '#E50914',
      filmeIds:     List<String>.from(dados['filmeIds'] ?? []),
      dataCriacao:  (dados['dataCriacao'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid':          uid,
      'nome':         nome,
      'descricao':    descricao,
      'cor':          cor,
      'filmeIds':     filmeIds,
      'dataCriacao':  dataCriacao,
    };
  }
}
