// Botão com estado de carregamento — feedback visual durante operações async
import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final String label;
  final bool carregando;
  final VoidCallback? onPressed;

  const LoadingButton({
    super.key,
    required this.label,
    required this.carregando,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: carregando ? null : onPressed,
      child: carregando
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
