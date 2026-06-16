// Tela de busca de filmes via API OMDb — RF007
// FutureBuilder correto para chamada HTTP
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/omdb_service.dart';
import '../../services/filme_service.dart';
import '../../models/omdb_model.dart';
import '../../firebase_config.dart';

class BuscarFilmeScreen extends StatefulWidget {
  const BuscarFilmeScreen({super.key});
  @override
  State<BuscarFilmeScreen> createState() => _BuscarFilmeScreenState();
}

class _BuscarFilmeScreenState extends State<BuscarFilmeScreen> {
  final _buscaCtrl = TextEditingController();
  Future<List<OmdbFilme>>? _futureFilmes;
  String _ultimaBusca = '';

  @override
  void dispose() { _buscaCtrl.dispose(); super.dispose(); }

  void _buscar() {
    final termo = _buscaCtrl.text.trim();
    if (termo.isEmpty || termo == _ultimaBusca) return;
    setState(() {
      _ultimaBusca = termo;
      // RF007 — FutureBuilder para API REST
      _futureFilmes = OmdbService().buscarPorTitulo(termo);
    });
  }

  Future<void> _adicionarFilme(OmdbFilme filme, String status) async {
    if (!kFirebaseEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '"${filme.titulo}" adicionado! (modo demo)')),
      );
      return;
    }
    try {
      await FilmeService().adicionarFilme(
          omdbFilme: filme, status: status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('"${filme.titulo}" adicionado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Filme')),
      body: Column(
        children: [
          // Campo de busca + botão
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nome do filme...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _buscar,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 52)),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          // Resultados via FutureBuilder (RF007)
          Expanded(
            child: _futureFilmes == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_filter,
                            size: 64, color: Color(0xFF333333)),
                        SizedBox(height: 12),
                        Text('Digite o nome de um filme para buscar',
                            style: TextStyle(color: Color(0xFF666666))),
                      ],
                    ),
                  )
                : FutureBuilder<List<OmdbFilme>>(
                    future: _futureFilmes,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Erro: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red)),
                        );
                      }
                      final filmes = snapshot.data ?? [];
                      if (filmes.isEmpty) {
                        return const Center(
                          child: Text('Nenhum filme encontrado.',
                              style:
                                  TextStyle(color: Color(0xFF666666))),
                        );
                      }
                      return ListView.builder(
                        itemCount: filmes.length,
                        itemBuilder: (_, i) =>
                            _cardResultado(filmes[i]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cardResultado(OmdbFilme filme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: filme.poster.isNotEmpty && filme.poster != 'N/A'
                  ? CachedNetworkImage(
                      imageUrl: filme.poster,
                      width: 55,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 55,
                      height: 80,
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(Icons.movie,
                          color: Color(0xFF444444)),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(filme.titulo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${filme.ano} • ${filme.genero}',
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 12)),
                  Text('Dir: ${filme.diretor}',
                      style: const TextStyle(
                          color: Color(0xFF666666), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _adicionarFilme(filme, 'quero_ver'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFE50914)),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text('▶ Quero Ver',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _adicionarFilme(filme, 'assistido'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text('✓ Assistido',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
