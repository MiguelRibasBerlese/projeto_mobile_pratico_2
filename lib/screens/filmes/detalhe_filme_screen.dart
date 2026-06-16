// Tela de detalhes de um filme — RF004 (atualizar status)
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/filme_service.dart';
import '../../services/avaliacao_service.dart';
import '../../firebase_config.dart';
import '../../widgets/star_rating.dart';

class DetalheFilmeScreen extends StatefulWidget {
  final String filmeId;
  final Map<String, dynamic> dadoFilme;

  const DetalheFilmeScreen({
    super.key,
    required this.filmeId,
    required this.dadoFilme,
  });
  @override
  State<DetalheFilmeScreen> createState() => _DetalheFilmeScreenState();
}

class _DetalheFilmeScreenState extends State<DetalheFilmeScreen> {
  double _nota = 0;
  final _comentCtrl = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() { _comentCtrl.dispose(); super.dispose(); }

  Future<void> _salvarAvaliacao() async {
    if (_nota == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos 1 estrela.')),
      );
      return;
    }
    setState(() => _salvando = true);

    if (!kFirebaseEnabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação salva! (modo demo)')),
        );
      }
      setState(() => _salvando = false);
      return;
    }

    try {
      await AvaliacaoService().adicionarAvaliacao(
        filmeId:     widget.filmeId,
        filmeTitulo: widget.dadoFilme['titulo'] ?? '',
        filmePoster: widget.dadoFilme['poster']  ?? '',
        nota:        _nota,
        comentario:  _comentCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação salva com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _salvando = false);
  }

  Future<void> _alterarStatus(String novoStatus) async {
    if (!kFirebaseEnabled) return;
    try {
      await FilmeService().atualizarStatus(widget.filmeId, novoStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado para "$novoStatus"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dadoFilme;
    return Scaffold(
      appBar: AppBar(title: Text(d['titulo'] ?? 'Detalhes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster + info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: d['poster'] != null &&
                          d['poster'].isNotEmpty &&
                          d['poster'] != 'N/A'
                      ? CachedNetworkImage(
                          imageUrl: d['poster'],
                          width: 120,
                          height: 180,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 120,
                          height: 180,
                          color: const Color(0xFF2A2A2A),
                          child: const Icon(Icons.movie, size: 48,
                              color: Color(0xFF444444)),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['titulo'] ?? '',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${d['ano']} • ${d['genero']}',
                          style: const TextStyle(
                              color: Color(0xFF888888))),
                      Text('Dir: ${d['diretor'] ?? ''}',
                          style: const TextStyle(
                              color: Color(0xFF666666), fontSize: 12)),
                      const SizedBox(height: 12),
                      // Botões de status (RF004)
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('▶ Quero Ver'),
                            onPressed: () => _alterarStatus('quero_ver'),
                            backgroundColor:
                                const Color(0xFFE50914).withValues(alpha: 0.2),
                          ),
                          ActionChip(
                            label: const Text('✓ Assistido'),
                            onPressed: () =>
                                _alterarStatus('assistido'),
                            backgroundColor:
                                const Color(0xFF1DB954).withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            // Formulário de avaliação (RF003 — inserção na coleção avaliacoes)
            const Text('Sua Avaliação',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StarRating(
              nota: _nota,
              tamanho: 36,
              interativo: true,
              onChanged: (v) => setState(() => _nota = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentário (opcional)',
                hintText: 'O que você achou?',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvarAvaliacao,
                child: _salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Salvar Avaliação'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
