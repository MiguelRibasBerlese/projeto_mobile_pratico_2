// Perfil do usuário no Firestore (RF004 — atualização na coleção usuarios)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class UsuarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Stream do perfil em tempo real
  Stream<DocumentSnapshot> streamPerfil() {
    return _db.collection(kColUsuarios).doc(_uid).snapshots();
  }

  // Atualizar perfil (RF004 — coleção usuarios)
  Future<void> atualizarPerfil({
    required String nome,
    required String telefone,
    required String generoFavorito,
  }) async {
    await _db.collection(kColUsuarios).doc(_uid).update({
      'nome':            nome.trim(),
      'telefone':        telefone.trim(),
      'generoFavorito':  generoFavorito.trim(),
    });
  }
}
