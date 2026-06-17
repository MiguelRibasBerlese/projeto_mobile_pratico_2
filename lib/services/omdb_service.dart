import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/omdb_model.dart';
import '../utils/constants.dart';

class OmdbService {

  Future<List<OmdbFilme>> buscarPorTitulo(String titulo) async {
    if (titulo.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(
          '$kOmdbBaseUrl/?apikey=$kOmdbApiKey'
          '&s=${Uri.encodeComponent(titulo)}&type=movie');

      final resposta = await http.get(uri);

      if (resposta.statusCode != 200) {
        throw Exception('Falha na conexão: ${resposta.statusCode}');
      }

      final json = jsonDecode(resposta.body);

      if (json['Response'] == 'False') return [];

      final List<dynamic> resultados = json['Search'] ?? [];

      final filmes = <OmdbFilme>[];
      for (final item in resultados.take(8)) {
        filmes.add(OmdbFilme(
          imdbId:   item['imdbID'] ?? '',
          titulo:   item['Title']  ?? '',
          ano:      item['Year']   ?? '',
          genero:   item['Genre']  ?? '',
          diretor:  '',
          sinopse:  '',
          poster:   item['Poster'] ?? '',
          imdbNota: 'N/A',
        ));
      }
      return filmes;

    } catch (e) {
      throw Exception('Erro ao buscar filmes: $e');
    }
  }

  Future<OmdbFilme?> buscarPorId(String imdbId) async {
    try {
      final uri = Uri.parse(
          '$kOmdbBaseUrl/?apikey=$kOmdbApiKey&i=$imdbId&plot=short');

      final resposta = await http.get(uri);

      if (resposta.statusCode != 200) return null;

      final json = jsonDecode(resposta.body);

      if (json['Response'] == 'False') return null;

      return OmdbFilme.fromJson(json);

    } catch (e) {
      return null;
    }
  }
}
