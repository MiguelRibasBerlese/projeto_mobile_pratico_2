// Tela de perfil — RF004 (atualização na coleção usuarios)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/usuario_service.dart';
import '../../widgets/loading_button.dart';
import '../../utils/validators.dart';
import '../../firebase_config.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nomeCtrl    = TextEditingController();
  final _telCtrl     = TextEditingController();
  final _generoCtrl  = TextEditingController();
  bool _carregando   = false;
  bool _carregou     = false;

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    if (!kFirebaseEnabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado! (modo demo)')),
        );
      }
      setState(() => _carregando = false);
      return;
    }

    try {
      await UsuarioService().atualizarPerfil(
        nome:           _nomeCtrl.text,
        telefone:       _telCtrl.text,
        generoFavorito: _generoCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _carregando = false);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _telCtrl.dispose();
    _generoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: !kFirebaseEnabled
          ? _buildFormulario(modoDemo: true)
          : StreamBuilder<DocumentSnapshot>(
              stream: UsuarioService().streamPerfil(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                final d = snapshot.data?.data() as Map<String, dynamic>?;
                if (d != null && !_carregou) {
                  _nomeCtrl.text   = d['nome']           ?? '';
                  _telCtrl.text    = d['telefone']       ?? '';
                  _generoCtrl.text = d['generoFavorito'] ?? '';
                  _carregou = true;
                }
                return _buildFormulario(modoDemo: false, email: d?['email']);
              },
            ),
    );
  }

  Widget _buildFormulario({required bool modoDemo, String? email}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email != null) ...[
              Text(email,
                  style: const TextStyle(color: Color(0xFF888888))),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome completo',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (v) => Validators.obrigatorio(v, 'O nome'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) => Validators.obrigatorio(v, 'O telefone'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _generoCtrl,
              decoration: const InputDecoration(
                labelText: 'Gênero de filme favorito',
                prefixIcon: Icon(Icons.local_movies_outlined),
              ),
              validator: (v) => Validators.obrigatorio(v, 'O gênero favorito'),
            ),
            const SizedBox(height: 32),
            LoadingButton(
              label: 'Salvar Alterações',
              carregando: _carregando,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
