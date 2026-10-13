import 'package:flutter/material.dart';
import '../wikimedia/wikimedia_image_helper.dart';
import 'full_screen_image_viewer.dart';

/// Data model representing a photograph for heritage galleries.
class HeritagePhoto {
  final String imageUrl;
  final String title;
  final String? caption;

  const HeritagePhoto({
    required this.imageUrl,
    required this.title,
    this.caption,
  });
}

/// Horizontal scroll gallery carousel for heritage photo collections.
class HeritageHorizontalGallery extends StatelessWidget {
  final List<HeritagePhoto> photos;
  final EdgeInsetsGeometry padding;

  const HeritageHorizontalGallery({
    super.key,
    required this.photos,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          final effectiveUrl = photo.imageUrl.startsWith('http')
              ? photo.imageUrl
              : (photo.imageUrl.startsWith('//')
                  ? 'https:${photo.imageUrl}'
                  : photo.imageUrl);

          return GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(
                    imagePath: effectiveUrl,
                    caption: photo.caption ?? photo.title,
                  ),
                ),
              );
            },
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: effectiveUrl,
                      child: WikimediaImageHelper.buildImage(
                        context: context,
                        imageUrl: effectiveUrl,
                        targetWidth: 500,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
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
                        child: Text(
                          (photo.caption ?? photo.title).trim(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
