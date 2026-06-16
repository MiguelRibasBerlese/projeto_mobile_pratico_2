// Tela de cadastro — RF002
// Coleta nome, telefone, e-mail e senha com validação robusta
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_button.dart';
import '../../firebase_config.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nomeCtrl  = TextEditingController();
  final _telCtrl   = TextEditingController();
  final _generoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confCtrl  = TextEditingController();
  bool _carregando = false;
  bool _verSenha   = false;

  @override
  void dispose() {
    _nomeCtrl.dispose(); _telCtrl.dispose(); _generoCtrl.dispose();
    _emailCtrl.dispose(); _senhaCtrl.dispose(); _confCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    if (!kFirebaseEnabled) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso! (modo demo)')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      setState(() => _carregando = false);
      return;
    }

    final erro = await AuthService().cadastrar(
      email:           _emailCtrl.text,
      senha:           _senhaCtrl.text,
      nome:            _nomeCtrl.text,
      telefone:        _telCtrl.text,
      generoFavorito:  _generoCtrl.text,
    );

    if (mounted) {
      setState(() => _carregando = false);
      if (erro != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaCtrl,
                  obscureText: !_verSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_verSenha
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _verSenha = !_verSenha),
                    ),
                  ),
                  validator: Validators.senhaCadastro,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar senha',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (v) =>
                      Validators.confirmarSenha(v, _senhaCtrl.text),
                ),
                const SizedBox(height: 32),
                LoadingButton(
                  label: 'Criar Conta',
                  carregando: _carregando,
                  onPressed: _cadastrar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
