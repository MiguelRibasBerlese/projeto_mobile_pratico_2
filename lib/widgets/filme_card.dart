// Card de filme na listagem principal
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FilmeCard extends StatelessWidget {
  final String filmeId;
  final String titulo;
  final String ano;
  final String genero;
  final String poster;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onExcluir;

  const FilmeCard({
    super.key,
    required this.filmeId,
    required this.titulo,
    required this.ano,
    required this.genero,
    required this.poster,
    required this.status,
    this.onTap,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Poster do filme
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: poster.isNotEmpty && poster != 'N/A'
                    ? CachedNetworkImage(
                        imageUrl: poster,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _posterPlaceholder(),
                        errorWidget: (_, __, ___) => _posterPlaceholder(),
                      )
                    : _posterPlaceholder(),
              ),
              const SizedBox(width: 12),
              // Informações do filme
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ano • $genero',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Badge de status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: status == 'assistido'
                            ? const Color(0xFF1DB954)
                            : const Color(0xFFE50914),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status == 'assistido' ? '✓ Assistido' : '▶ Quero ver',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Botão excluir
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFF555555)),
                onPressed: onExcluir,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 60,
      height: 90,
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.movie, color: Color(0xFF444444)),
    );
  }
}
