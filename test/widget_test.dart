// Smoke test do CineTrack — verifica que o app inicia na tela de login
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cine_track/main.dart';

void main() {
  testWidgets('App inicia na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const CineTrackApp());

    expect(find.text('CineTrack'), findsOneWidget);
    expect(find.text('Seu diário de filmes'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
  });
}
