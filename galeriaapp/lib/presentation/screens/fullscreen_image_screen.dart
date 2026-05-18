import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullscreenImageScreen extends StatefulWidget {
  final String imageUrl;
  final String tag;

  const FullscreenImageScreen({
    super.key,
    required this.imageUrl,
    required this.tag,
  });

  @override
  State<FullscreenImageScreen> createState() => _FullscreenImageScreenState();
}

class _FullscreenImageScreenState extends State<FullscreenImageScreen> {
  final TransformationController _transformationController =
      TransformationController();
  bool _zoomedIn = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    setState(() {
      _zoomedIn = !_zoomedIn;
      final double scale = _zoomedIn ? 2.5 : 1.0;
      _transformationController.value = Matrix4.diagonal3Values(
        scale,
        scale,
        1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: GestureDetector(
        onDoubleTap: _toggleZoom,
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: SizedBox.expand(
              child: Hero(
                tag: widget.tag,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
