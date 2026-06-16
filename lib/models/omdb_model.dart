// Model para resposta da API OMDb (RF007)
class OmdbFilme {
  final String imdbId;
  final String titulo;
  final String ano;
  final String genero;
  final String diretor;
  final String sinopse;
  final String poster;
  final String imdbNota;

  OmdbFilme({
    required this.imdbId,
    required this.titulo,
    required this.ano,
    required this.genero,
    required this.diretor,
    required this.sinopse,
    required this.poster,
    required this.imdbNota,
  });

  factory OmdbFilme.fromJson(Map<String, dynamic> json) {
    return OmdbFilme(
      imdbId:    json['imdbID']   ?? '',
      titulo:    json['Title']    ?? '',
      ano:       json['Year']     ?? '',
      genero:    json['Genre']    ?? '',
      diretor:   json['Director'] ?? '',
      sinopse:   json['Plot']     ?? '',
      poster:    json['Poster']   ?? '',
      imdbNota:  json['imdbRating'] ?? 'N/A',
    );
  }
}
