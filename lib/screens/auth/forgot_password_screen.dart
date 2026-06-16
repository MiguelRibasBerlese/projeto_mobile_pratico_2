// Tela de recuperação de senha — RF001
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_button.dart';
import '../../firebase_config.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _recuperar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    if (!kFirebaseEnabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail de recuperação enviado! (modo demo)'),
          ),
        );
        Navigator.pop(context);
      }
      setState(() => _carregando = false);
      return;
    }

    final erro = await AuthService().recuperarSenha(_emailCtrl.text);
    if (mounted) {
      setState(() => _carregando = false);
      if (erro != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail de recuperação enviado com sucesso!'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.lock_reset, size: 64, color: Color(0xFFE50914)),
              const SizedBox(height: 16),
              const Text(
                'Informe seu e-mail para receber as instruções de redefinição de senha.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF888888)),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Enviar e-mail',
                carregando: _carregando,
                onPressed: _recuperar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
