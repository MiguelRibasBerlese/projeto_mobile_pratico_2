// Model do perfil do usuário salvo no Firestore
class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final String telefone;
  final String generoFavorito;
  final DateTime dataCadastro;

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.generoFavorito,
    required this.dataCadastro,
  });

  factory UsuarioModel.fromFirestore(Map<String, dynamic> dados) {
    return UsuarioModel(
      uid:             dados['uid']             ?? '',
      nome:            dados['nome']            ?? '',
      email:           dados['email']           ?? '',
      telefone:        dados['telefone']        ?? '',
      generoFavorito:  dados['generoFavorito']  ?? '',
      dataCadastro: (dados['dataCadastro'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid':             uid,
      'nome':            nome,
      'email':           email,
      'telefone':        telefone,
      'generoFavorito':  generoFavorito,
      'dataCadastro':    dataCadastro,
    };
  }
}
