// Tela principal com BottomNavigationBar
// RF005 — StreamBuilder com ListView de filmes (coleção 1)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/filme_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/filme_card.dart';
import '../../widgets/empty_state.dart';
import '../../firebase_config.dart';
import '../filmes/buscar_filme_screen.dart';
import '../filmes/pesquisa_screen.dart';
import '../filmes/detalhe_filme_screen.dart';
import '../avaliacoes/avaliacoes_screen.dart';
import '../listas/listas_screen.dart';
import '../sobre/sobre_screen.dart';
import '../perfil/perfil_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _abaSelecionada = 0;
  String? _filtroStatus; // null = todos, 'assistido', 'quero_ver'

  final _abas = const [
    NavigationDestination(icon: Icon(Icons.movie), label: 'Filmes'),
    NavigationDestination(icon: Icon(Icons.star), label: 'Avaliações'),
    NavigationDestination(icon: Icon(Icons.list), label: 'Listas'),
  ];

  Future<void> _logout() async {
    await AuthService().logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 CineTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pesquisar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PesquisaScreen()),
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'perfil', child: Text('Perfil')),
              const PopupMenuItem(value: 'sobre', child: Text('Sobre')),
              const PopupMenuItem(value: 'sair',  child: Text('Sair')),
            ],
            onSelected: (v) {
              if (v == 'perfil') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen()));
              } else if (v == 'sobre') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SobreScreen()));
              } else if (v == 'sair') {
                _logout();
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _abaSelecionada,
        children: [
          _buildFilmes(),
          const AvaliacoesScreen(),
          const ListasScreen(),
        ],
      ),
      floatingActionButton: _abaSelecionada == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuscarFilmeScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Filme'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _abaSelecionada,
        onDestinationSelected: (i) => setState(() => _abaSelecionada = i),
        destinations: _abas,
        backgroundColor: const Color(0xFF1A1A1A),
        indicatorColor: const Color(0xFFE50914).withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  // RF005 — StreamBuilder obrigatório com ListView (coleção filmes)
  Widget _buildFilmes() {
    return Column(
      children: [
        // Chips de filtro
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _chipFiltro('Todos',       null),
              const SizedBox(width: 8),
              _chipFiltro('Quero Ver',   'quero_ver'),
              const SizedBox(width: 8),
              _chipFiltro('Assistidos',  'assistido'),
            ],
          ),
        ),
        Expanded(
          child: kFirebaseEnabled
              ? StreamBuilder<QuerySnapshot>(
                  stream: FilmeService().streamFilmes(
                      statusFiltro: _filtroStatus),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Erro: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return EmptyState(
                        icone: Icons.movie_outlined,
                        mensagem:
                            'Nenhum filme na sua lista.\nToque em + para adicionar!',
                        labelBotao: 'Buscar Filme',
                        onBotao: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BuscarFilmeScreen()),
                        ),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final d = docs[i].data() as Map<String, dynamic>;
                        return FilmeCard(
                          filmeId: docs[i].id,
                          titulo:  d['titulo']  ?? '',
                          ano:     d['ano']     ?? '',
                          genero:  d['genero']  ?? '',
                          poster:  d['poster']  ?? '',
                          status:  d['status']  ?? 'quero_ver',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalheFilmeScreen(
                                filmeId:  docs[i].id,
                                dadoFilme: d,
                              ),
                            ),
                          ),
                          onExcluir: () => _confirmarExclusao(docs[i].id),
                        );
                      },
                    );
                  },
                )
              // Modo mock — lista estática de demonstração
              : _listaFilmesMock(),
        ),
      ],
    );
  }

  Widget _chipFiltro(String label, String? valor) {
    final selecionado = _filtroStatus == valor;
    return FilterChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) => setState(() => _filtroStatus = valor),
      selectedColor: const Color(0xFFE50914).withValues(alpha: 0.3),
      checkmarkColor: const Color(0xFFE50914),
    );
  }

  Widget _listaFilmesMock() {
    // Dados estáticos para demonstração sem Firebase
    final mock = [
      {'titulo': 'Interstellar',   'ano': '2014', 'genero': 'Sci-Fi',  'status': 'assistido',  'poster': ''},
      {'titulo': 'The Dark Knight','ano': '2008', 'genero': 'Ação',    'status': 'assistido',  'poster': ''},
      {'titulo': 'Inception',      'ano': '2010', 'genero': 'Thriller','status': 'quero_ver',  'poster': ''},
    ];
    return ListView.builder(
      itemCount: mock.length,
      itemBuilder: (_, i) => FilmeCard(
        filmeId:  'mock_$i',
        titulo:   mock[i]['titulo']!,
        ano:      mock[i]['ano']!,
        genero:   mock[i]['genero']!,
        poster:   mock[i]['poster']!,
        status:   mock[i]['status']!,
      ),
    );
  }

  Future<void> _confirmarExclusao(String filmeId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir filme'),
        content: const Text('Deseja remover este filme da sua lista?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmar == true && kFirebaseEnabled) {
      await FilmeService().excluirFilme(filmeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filme removido.')),
        );
      }
    }
  }
}
