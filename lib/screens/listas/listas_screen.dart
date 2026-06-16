// Tela de listas personalizadas — RF003, RF004, RF005
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/lista_service.dart';
import '../../widgets/empty_state.dart';
import '../../firebase_config.dart';

class ListasScreen extends StatelessWidget {
  const ListasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kFirebaseEnabled) {
      return const EmptyState(
        icone: Icons.list_alt,
        mensagem: 'Suas listas aparecem aqui.\n(Firebase necessário)',
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _dialogNovLista(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ListaService().streamListas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyState(
              icone: Icons.list_alt,
              mensagem: 'Nenhuma lista ainda.\nCrie sua primeira lista!',
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final cor = Color(int.parse(
                  (d['cor'] ?? '#E50914').replaceFirst('#', '0xFF')));
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cor.withValues(alpha: 0.2),
                    child: Icon(Icons.list, color: cor),
                  ),
                  title: Text(d['nome'] ?? ''),
                  subtitle: Text(
                    '${(d['filmeIds'] as List?)?.length ?? 0} filmes • ${d['descricao'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Editar (RF004)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 20),
                        onPressed: () => _dialogEditarLista(
                            context, docs[i].id, d),
                      ),
                      // Excluir
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: Color(0xFF555555)),
                        onPressed: () async {
                          try {
                            await ListaService().excluirLista(docs[i].id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Lista removida.')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao remover: $e'),
                                    backgroundColor: Colors.red),
                              );
                            }
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
      ),
    );
  }

  void _dialogNovLista(BuildContext context) {
    _dialogLista(context, null, null);
  }

  void _dialogEditarLista(BuildContext context, String id,
      Map<String, dynamic> dados) {
    _dialogLista(context, id, dados);
  }

  void _dialogLista(BuildContext context, String? id,
      Map<String, dynamic>? dados) {
    final nomeCtrl  = TextEditingController(text: dados?['nome'] ?? '');
    final descCtrl  = TextEditingController(
        text: dados?['descricao'] ?? '');
    String cor = dados?['cor'] ?? '#E50914';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Nova Lista' : 'Editar Lista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (id == null) {
                  await ListaService().criarLista(
                    nome:      nomeCtrl.text,
                    descricao: descCtrl.text,
                    cor:       cor,
                  );
                } else {
                  await ListaService().atualizarLista(
                    listaId:   id,
                    nome:      nomeCtrl.text,
                    descricao: descCtrl.text,
                    cor:       cor,
                  );
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(id == null
                        ? 'Lista criada com sucesso!'
                        : 'Lista atualizada com sucesso!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao salvar: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
