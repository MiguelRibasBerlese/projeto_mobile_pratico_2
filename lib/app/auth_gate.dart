// AuthGate — boundary de modo dual (mock vs Firebase)
// Decide qual "mundo" renderizar com base em kFirebaseEnabled
import 'package:flutter/material.dart';
import '../firebase_config.dart';
import '../screens/auth/login_screen.dart';

// Importações Firebase — ativas apenas quando kFirebaseEnabled = true
// import 'package:firebase_auth/firebase_auth.dart';
// import '../screens/home/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kFirebaseEnabled) {
      // Modo de desenvolvimento — direto para login
      return const LoginScreen();
    }

    // Modo Firebase — descomentar após flutterfire configure:
    // return StreamBuilder<User?>(
    //   stream: FirebaseAuth.instance.authStateChanges(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Scaffold(
    //         body: Center(child: CircularProgressIndicator()),
    //       );
    //     }
    //     return snapshot.hasData
    //         ? const HomeScreen()
    //         : const LoginScreen();
    //   },
    // );

    return const LoginScreen();
  }
}
