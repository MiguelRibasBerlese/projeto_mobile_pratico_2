// Serviço de consumo da API REST pública OMDb (RF007)
// Documentação: https://www.omdbapi.com
// Chave gratuita: cadastre em omdbapi.com (1.000 req/dia)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/omdb_model.dart';
import '../utils/constants.dart';

class OmdbService {
  // Buscar filmes por título — retorna lista de resultados
  Future<List<OmdbFilme>> buscarPorTitulo(String titulo) async {
    if (titulo.trim().isEmpty) return [];

    final uri = Uri.parse(
      '$kOmdbBaseUrl/?apikey=$kOmdbApiKey&s=${Uri.encodeComponent(titulo)}&type=movie',
    );

    final resposta = await http.get(uri);

    if (resposta.statusCode != 200) {
      throw Exception('Falha na conexão com OMDb: ${resposta.statusCode}');
    }

    final json = jsonDecode(resposta.body);

    // OMDb retorna Response: 'False' quando não encontra resultados
    if (json['Response'] == 'False') return [];

    final List<dynamic> resultados = json['Search'] ?? [];
    // Buscar detalhes completos de cada resultado (poster, diretor, etc.)
    final filmes = <OmdbFilme>[];
    for (final item in resultados.take(10)) {
      final detalhe = await buscarPorId(item['imdbID']);
      if (detalhe != null) filmes.add(detalhe);
    }
    return filmes;
  }

  // Buscar detalhes completos por imdbID
  Future<OmdbFilme?> buscarPorId(String imdbId) async {
    final uri = Uri.parse(
      '$kOmdbBaseUrl/?apikey=$kOmdbApiKey&i=$imdbId&plot=short',
    );

    final resposta = await http.get(uri);
    if (resposta.statusCode != 200) return null;

    final json = jsonDecode(resposta.body);
    if (json['Response'] == 'False') return null;

    return OmdbFilme.fromJson(json);
  }
}
