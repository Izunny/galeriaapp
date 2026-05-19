import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  // Pantalla de error genérica que muestra un mensaje y una imagen, con opción de reintentar la acción que causó el error.
  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });
  // El widget se construye con una imagen (un gato triste), el título del error, el mensaje descriptivo y un botón para reintentar la acción.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            child: Image.asset(
              'assets/images/sad_cat.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) {
                return Image.asset('assets/images/icon.png', height: 140);
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onBackground.withAlpha(0xDD),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(retryLabel ?? 'Reintentar'),
          ),
        ],
      ),
    );
  }
}
