// Serviço de autenticação com Firebase Authentication
// Todos os comentários em português conforme padrão da disciplina
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream do estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuário logado atualmente
  User? get usuarioAtual => _auth.currentUser;

  // Login com e-mail e senha (RF001)
  Future<String?> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return null; // null = sucesso
    } on FirebaseAuthException catch (e) {
      return _traduzirErro(e.code);
    }
  }

  // Cadastro de novo usuário (RF002)
  Future<String?> cadastrar({
    required String email,
    required String senha,
    required String nome,
    required String telefone,
    required String generoFavorito,
  }) async {
    try {
      final resultado = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      // Salvar campos adicionais na coleção "usuarios" do Firestore
      await _db.collection(kColUsuarios).doc(resultado.user!.uid).set({
        'uid':             resultado.user!.uid,
        'nome':            nome.trim(),
        'email':           email.trim(),
        'telefone':        telefone.trim(),
        'generoFavorito':  generoFavorito.trim(),
        'dataCadastro':    FieldValue.serverTimestamp(),
      });

      // Criar listas padrão para o novo usuário
      await _criarListasPadrao(resultado.user!.uid);

      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzirErro(e.code);
    }
  }

  // Recuperação de senha por e-mail (RF001)
  Future<String?> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzirErro(e.code);
    }
  }

  // Logout
  Future<void> logout() async => await _auth.signOut();

  // Criar listas padrão ao cadastrar usuário
  Future<void> _criarListasPadrao(String uid) async {
    final listas = [
      {'nome': 'Favoritos',        'descricao': 'Meus filmes favoritos', 'cor': '#F5C518'},
      {'nome': 'Assistir Depois',  'descricao': 'Lista para ver mais tarde', 'cor': '#E50914'},
      {'nome': 'Já Assisti',       'descricao': 'Filmes que já vi', 'cor': '#1DB954'},
    ];
    final batch = _db.batch();
    for (final l in listas) {
      final ref = _db.collection(kColListas).doc();
      batch.set(ref, {
        ...l,
        'uid':          uid,
        'filmeIds':     [],
        'dataCriacao':  FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // Tradução dos códigos de erro do Firebase para português
  String _traduzirErro(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Formato de e-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter no mínimo 6 caracteres.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      default:
        return 'Erro ao autenticar. Tente novamente.';
    }
  }
}
