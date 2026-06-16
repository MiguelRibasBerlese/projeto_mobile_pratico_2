// RF006 — Tela EXCLUSIVA de pesquisa (tela separada, não aba nem inline)
// Interface gráfica própria, ordenação por múltiplos critérios
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/filme_service.dart';
import '../../widgets/filme_card.dart';
import '../../firebase_config.dart';

class PesquisaScreen extends StatefulWidget {
  const PesquisaScreen({super.key});
  @override
  State<PesquisaScreen> createState() => _PesquisaScreenState();
}

class _PesquisaScreenState extends State<PesquisaScreen> {
  final _buscaCtrl = TextEditingController();
  String _termo     = '';
  String _ordenacao = 'titulo_az';

  @override
  void dispose() { _buscaCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar Filmes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _buscaCtrl,
              decoration: const InputDecoration(
                hintText: 'Buscar por título...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _termo = v),
            ),
          ),
          // Dropdown de ordenação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              initialValue: _ordenacao,
              decoration: const InputDecoration(
                labelText: 'Ordenar por',
                prefixIcon: Icon(Icons.sort),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'titulo_az',
                    child: Text('Título (A → Z)')),
                DropdownMenuItem(
                    value: 'titulo_za',
                    child: Text('Título (Z → A)')),
                DropdownMenuItem(
                    value: 'ano_novo',
                    child: Text('Ano (mais recente)')),
                DropdownMenuItem(
                    value: 'ano_antigo',
                    child: Text('Ano (mais antigo)')),
                DropdownMenuItem(
                    value: 'data_add',
                    child: Text('Data adicionado')),
              ],
              onChanged: (v) => setState(() => _ordenacao = v!),
            ),
          ),
          const SizedBox(height: 8),
          // Resultados
          Expanded(
            child: kFirebaseEnabled
                ? StreamBuilder<QuerySnapshot>(
                    stream: FilmeService().pesquisarFilmes(_termo),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            _termo.isEmpty
                                ? 'Digite algo para pesquisar'
                                : 'Nenhum resultado para "$_termo"',
                            style: const TextStyle(
                                color: Color(0xFF666666)),
                          ),
                        );
                      }
                      // Ordenação client-side
                      final docs = _ordenar(snapshot.data!.docs);
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final d =
                              docs[i].data() as Map<String, dynamic>;
                          return FilmeCard(
                            filmeId: docs[i].id,
                            titulo:  d['titulo']  ?? '',
                            ano:     d['ano']     ?? '',
                            genero:  d['genero']  ?? '',
                            poster:  d['poster']  ?? '',
                            status:  d['status']  ?? '',
                          );
                        },
                      );
                    },
                  )
                // Modo mock
                : const Center(
                    child: Text(
                      'Pesquisa disponível com Firebase ativo.',
                      style: TextStyle(color: Color(0xFF666666)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<QueryDocumentSnapshot> _ordenar(
      List<QueryDocumentSnapshot> docs) {
    final lista = docs.toList();
    switch (_ordenacao) {
      case 'titulo_az':
        lista.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          return (da['titulo'] as String)
              .compareTo(db['titulo'] as String);
        });
        break;
      case 'titulo_za':
        lista.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          return (db['titulo'] as String)
              .compareTo(da['titulo'] as String);
        });
        break;
      case 'ano_novo':
        lista.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          return (db['ano'] as String).compareTo(da['ano'] as String);
        });
        break;
      case 'ano_antigo':
        lista.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          return (da['ano'] as String).compareTo(db['ano'] as String);
        });
        break;
      case 'data_add':
        lista.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          final ta = da['dataAdicionado'] as Timestamp?;
          final tb = db['dataAdicionado'] as Timestamp?;
          if (ta == null || tb == null) return 0;
          return tb.compareTo(ta); // mais recente primeiro
        });
        break;
    }
    return lista;
  }
}
