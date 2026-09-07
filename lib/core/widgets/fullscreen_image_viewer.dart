import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Opens [url] in a fullscreen, pinch-to-zoom viewer over a black
/// background. Tap the close button, or the app bar back gesture, to exit.
void showFullscreenImage(BuildContext context, String url) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) => _FullscreenImageViewer(url: url),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _FullscreenImageViewer extends StatelessWidget {
  final String url;
  const _FullscreenImageViewer({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      const CircularProgressIndicator(color: Colors.white),
                  errorWidget: (_, _, _) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
