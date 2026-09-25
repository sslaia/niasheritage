import 'package:flutter/material.dart';
import '../wikimedia/wiki_config.dart';

/// Interactive full-screen image viewer supporting pinch-to-zoom and panning.
class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String? caption;

  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = imagePath.startsWith('http')
        ? imagePath
        : (imagePath.startsWith('//') ? 'https:$imagePath' : imagePath);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: caption != null && caption!.trim().isNotEmpty
            ? Text(
                caption!.trim(),
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : null,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: imagePath,
                child: Image.network(
                  effectiveUrl,
                  fit: BoxFit.contain,
                  headers: WikiConfig.headers,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    final total = progress.expectedTotalBytes;
                    final loaded = progress.cumulativeBytesLoaded;
                    final value = total != null && total > 0 ? loaded / total : null;
                    return Center(
                      child: CircularProgressIndicator(
                        value: value,
                        color: Colors.white70,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(
                      child: Icon(Icons.broken_image, size: 54, color: Colors.white54),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (caption != null && caption!.trim().isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Text(
                    caption!.trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
