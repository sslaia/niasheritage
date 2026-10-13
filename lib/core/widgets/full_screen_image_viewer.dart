import 'package:flutter/material.dart';
import '../wikimedia/wikimedia_image_helper.dart';

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
          Positioned.fill(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: Hero(
                  tag: imagePath,
                  child: WikimediaImageHelper.buildImage(
                    context: context,
                    imageUrl: effectiveUrl,
                    targetWidth: 1280,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => const SizedBox(
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
          ),
          if (caption != null && caption!.trim().isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
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
            ),
        ],
      ),
    );
  }
}
