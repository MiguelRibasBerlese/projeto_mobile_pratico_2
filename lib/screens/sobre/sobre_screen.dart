// Tela Sobre — informações do projeto
import 'package:flutter/material.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.movie_filter,
                  size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('CineTrack',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
            const Text('Versão 2.0.0 — Projeto Prático Parte 2',
                style: TextStyle(color: Color(0xFF888888))),
            const SizedBox(height: 32),
            _infoTile('Objetivo',
                'Aplicativo de diário de filmes com Firebase, API OMDb e design Material 3.'),
            _infoTile('Disciplina',
                'AC622 — Programação Mobile II'),
            _infoTile('Instituição',
                'UNAERP — Campus Ribeirão Preto'),
            _infoTile('Professor',
                'Prof. Dr. Samuel Zanferdini Oliva'),
            _infoTile('Integrantes',
                'Miguel Ribas Berlese — 839938\nEnzo Shimada Daun — 840552'),
            _infoTile('Tecnologias',
                'Flutter · Dart · Firebase Auth\nCloud Firestore · API OMDb (REST)\nProvider · Material Design 3'),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String titulo, String conteudo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: const TextStyle(
                    color: Color(0xFFE50914),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            Text(conteudo,
                style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
