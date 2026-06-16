// Validadores de formulário do CineTrack
class Validators {
  // Validar e-mail
  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O e-mail é obrigatório.';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(valor.trim())) {
      return 'Formato de e-mail inválido.';
    }
    return null;
  }

  // Senha para cadastro — RF002 exige validação robusta
  // Mínimo 8 chars, 1 maiúscula, 1 minúscula, 1 número, 1 especial
  static String? senhaCadastro(String? valor) {
    if (valor == null || valor.isEmpty) return 'A senha é obrigatória.';
    if (valor.length < 8) return 'Mínimo 8 caracteres.';
    if (!RegExp(r'[A-Z]').hasMatch(valor)) return 'Inclua pelo menos uma maiúscula.';
    if (!RegExp(r'[a-z]').hasMatch(valor)) return 'Inclua pelo menos uma minúscula.';
    if (!RegExp(r'[0-9]').hasMatch(valor)) return 'Inclua pelo menos um número.';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(valor)) {
      return 'Inclua pelo menos um caractere especial.';
    }
    return null;
  }

  // Senha para login — só verifica preenchimento
  static String? senhaLogin(String? valor) {
    if (valor == null || valor.isEmpty) return 'A senha é obrigatória.';
    return null;
  }

  // Confirmar senha
  static String? confirmarSenha(String? valor, String senha) {
    if (valor == null || valor.isEmpty) return 'Confirme a senha.';
    if (valor != senha) return 'As senhas não coincidem.';
    return null;
  }

  // Campo obrigatório genérico
  static String? obrigatorio(String? valor, String nomeCampo) {
    if (valor == null || valor.trim().isEmpty) return '$nomeCampo é obrigatório.';
    return null;
  }
}
