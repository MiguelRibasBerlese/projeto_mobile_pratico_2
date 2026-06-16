// Widget de estado vazio — exibido quando não há dados
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icone;
  final String mensagem;
  final String? labelBotao;
  final VoidCallback? onBotao;

  const EmptyState({
    super.key,
    required this.icone,
    required this.mensagem,
    this.labelBotao,
    this.onBotao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 72, color: const Color(0xFF333333)),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 16),
            ),
            if (labelBotao != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onBotao,
                child: Text(labelBotao!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
