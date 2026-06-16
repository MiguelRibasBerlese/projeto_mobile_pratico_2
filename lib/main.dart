// Ponto de entrada do CineTrack
// Firebase inicializado condicionalmente via kFirebaseEnabled
import 'package:flutter/material.dart';
import 'firebase_config.dart';
import 'app/auth_gate.dart';
import 'utils/app_theme.dart';

// Descomentar após flutterfire configure:
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kFirebaseEnabled) {
    // Descomentar após flutterfire configure:
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  }

  runApp(const CineTrackApp());
}

class CineTrackApp extends StatelessWidget {
  const CineTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
    );
  }
}
