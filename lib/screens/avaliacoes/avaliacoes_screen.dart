// RF005 — StreamBuilder com ListView de avaliações (segunda coleção)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/avaliacao_service.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/empty_state.dart';
import '../../firebase_config.dart';

class AvaliacoesScreen extends StatelessWidget {
  const AvaliacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kFirebaseEnabled) {
      return const EmptyState(
        icone: Icons.star_outline,
        mensagem: 'Suas avaliações aparecem aqui.\n(Firebase necessário)',
      );
    }

    // RF005 — StreamBuilder obrigatório, segunda coleção
    return StreamBuilder<QuerySnapshot>(
      stream: AvaliacaoService().streamAvaliacoes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyState(
            icone: Icons.star_outline,
            mensagem:
                'Nenhuma avaliação ainda.\nAvalte um filme na tela de detalhes!',
          );
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: d['filmePoster'] != null &&
                              d['filmePoster'].isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: d['filmePoster'],
                              width: 45,
                              height: 65,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 45,
                              height: 65,
                              color: const Color(0xFF2A2A2A),
                              child: const Icon(Icons.movie,
                                  color: Color(0xFF444444), size: 20),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d['filmeTitulo'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          StarRating(
                            nota: (d['nota'] as num?)?.toDouble() ?? 0,
                            tamanho: 18,
                          ),
                          if ((d['comentario'] ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(d['comentario'],
                                  style: const TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                        ],
                      ),
                    ),
                    // Editar avaliação (RF004)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: Color(0xFF888888), size: 20),
                      onPressed: () =>
                          _editarAvaliacao(context, docs[i].id, d),
                    ),
                    // Excluir avaliação
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Color(0xFF555555), size: 20),
                      onPressed: () async {
                        await AvaliacaoService()
                            .excluirAvaliacao(docs[i].id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Avaliação removida.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editarAvaliacao(
      BuildContext context, String avaliacaoId, Map<String, dynamic> dados) {
    double nota = (dados['nota'] as num?)?.toDouble() ?? 0;
    final comentCtrl =
        TextEditingController(text: dados['comentario'] ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(dados['filmeTitulo'] ?? 'Editar avaliação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StarRating(
                nota: nota,
                tamanho: 32,
                interativo: true,
                onChanged: (v) => setState(() => nota = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: comentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Comentário (opcional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await AvaliacaoService().atualizarAvaliacao(
                    avaliacaoId: avaliacaoId,
                    nota: nota,
                    comentario: comentCtrl.text,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Avaliação atualizada com sucesso!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
