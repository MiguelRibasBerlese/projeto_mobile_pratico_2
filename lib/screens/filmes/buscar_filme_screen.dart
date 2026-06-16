import 'package:flutter/material.dart';
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
  final _controller = TextEditingController();
  final _omdbService = OmdbService();
  final _filmeService = FilmeService();
  Future<List<OmdbFilme>>? _resultados;

  void _buscar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    setState(() {
      _resultados = _omdbService.buscarPorTitulo(texto);
    });
  }

  Future<void> _adicionarFilme(OmdbFilme filme, String status) async {
    if (!kFirebaseEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase não configurado.')),
      );
      return;
    }
    try {
      await _filmeService.adicionarFilme(omdbFilme: filme, status: status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${filme.titulo}" adicionado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Filmes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Digite o título do filme...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _buscar(),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _buscar,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: _resultados == null
                ? const Center(child: Text('Busque um filme pelo título.'))
                : FutureBuilder<List<OmdbFilme>>(
                    future: _resultados,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erro: ${snapshot.error}'));
                      }
                      final filmes = snapshot.data ?? [];
                      if (filmes.isEmpty) {
                        return const Center(
                            child: Text('Nenhum filme encontrado.'));
                      }
                      return ListView.builder(
                        itemCount: filmes.length,
                        itemBuilder: (context, index) {
                          final filme = filmes[index];
                          return _FilmeCard(
                            filme: filme,
                            onQueroVer: () =>
                                _adicionarFilme(filme, 'quero_ver'),
                            onAssistido: () =>
                                _adicionarFilme(filme, 'assistido'),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilmeCard extends StatelessWidget {
  final OmdbFilme filme;
  final VoidCallback onQueroVer;
  final VoidCallback onAssistido;

  const _FilmeCard({
    required this.filme,
    required this.onQueroVer,
    required this.onAssistido,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (filme.poster.isNotEmpty && filme.poster != 'N/A')
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  filme.poster,
                  width: 70,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(width: 70, height: 100),
                ),
              )
            else
              const SizedBox(
                width: 70,
                height: 100,
                child: Icon(Icons.movie, size: 40),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filme.titulo,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (filme.ano.isNotEmpty)
                    Text(filme.ano,
                        style: Theme.of(context).textTheme.bodySmall),
                  if (filme.genero.isNotEmpty)
                    Text(
                      filme.genero,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onQueroVer,
                          child: const Text('Quero Ver'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAssistido,
                          child: const Text('Assistido'),
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
