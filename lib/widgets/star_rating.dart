// Widget de avaliação por estrelas (1 a 5)
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StarRating extends StatelessWidget {
  final double nota;
  final double tamanho;
  final bool interativo;
  final ValueChanged<double>? onChanged;

  const StarRating({
    super.key,
    required this.nota,
    this.tamanho = 24,
    this.interativo = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final estrela = i + 1;
        return GestureDetector(
          onTap: interativo ? () => onChanged?.call(estrela.toDouble()) : null,
          child: Icon(
            estrela <= nota ? Icons.star : Icons.star_border,
            color: AppTheme.dourado,
            size: tamanho,
          ),
        );
      }),
    );
  }
}
