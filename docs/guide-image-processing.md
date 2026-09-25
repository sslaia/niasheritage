# GUIDE: Full-Width Image Processing & Horizontal Galleries in Flutter

This guide explains how to implement the responsive image processing and horizontal scrolling gallery architecture used in WikiNusa. You can copy and adapt these patterns directly into the **Nias Heritage** app (or any Flutter application) without reinventing the wheel.

---

## 1. Architectural Overview

Mobile article readers face two common issues when rendering raw web or MediaWiki content:
1. **Tiny, Floated Images:** Web articles float 150px–220px thumbnails next to paragraphs, which cram text and look pixelated or cramped on high-DPI smartphone screens.
2. **Rigid Table-like Galleries:** MediaWiki renders galleries as rigid multi-column HTML grid tables (`<li class="gallerybox">`) that break viewport widths or wrap clumsily.

### The Solution: A Two-Stage Pipeline

```
  ┌────────────────────────────────────────────────────────┐
  │ 1. HTML Preprocessing (HtmlProcessor & CoreWikiUtils)  │
  │    - Unwrap <noscript> lazy placeholders               │
  │    - Filter icons, logos, and UI symbols               │
  │    - Extract & deduplicate Hero Header Image           │
  │    - Query high-res (500px) thumbs from Commons API   │
  └───────────────────────────┬────────────────────────────┘
                              │ Processed HTML
                              ▼
  ┌────────────────────────────────────────────────────────┐
  │ 2. Flutter Widget Interception (customWidgetBuilder)   │
  │    - .thumb / figure  ──▶  _buildFullWidthImage()      │
  │    - .gallery         ──▶  _buildNativeGallery()       │
  └────────────────────────────────────────────────────────┘
```

---

## 2. Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_widget_from_html: ^0.15.2 # Robust HTML rendering with customWidgetBuilder
  html: ^0.15.4                     # Lightweight DOM manipulation
  http: ^1.2.0                      # Network requests for thumbnail resolution
```

---

## 3. Image Optimization & Sanitization

Before sending HTML to Flutter's renderer, sanitize and optimize the markup in your data service:

```dart
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'dart:convert';

class HeritageImageProcessor {
  static final Map<String, String> _optimizerCache = {};

  /// Preprocesses raw HTML, resolving lazy loading, hero deduplication, and high-res thumbnails
  static Future<Map<String, dynamic>> processHtml(String rawHtml) async {
    final document = html_parser.parse(rawHtml);

    // 1. Resolve Wikipedia / CMS lazy-loading <noscript> wrappers
    document.querySelectorAll('noscript').forEach((ns) {
      if (ns.innerHtml.contains('<img')) {
        final fragment = html_parser.parseFragment(ns.innerHtml);
        ns.parentNode?.insertBefore(fragment, ns);
      }
      ns.remove();
    });
    document.querySelectorAll('.lazy-image-placeholder').forEach((el) => el.remove());

    // 2. Identify Hero Image Candidate (first non-icon image in the document)
    dom.Element? heroElement;
    final allImages = document.querySelectorAll('img');
    for (final img in allImages) {
      final src = img.attributes['src'] ?? '';
      if (!isIcon(src, img)) {
        heroElement = img;
        break;
      }
    }

    String? heroImageUrl;

    // 3. Parallel Image URL Optimization (Requesting crisp 500px resolution)
    final List<Future<void>> tasks = [];
    for (final img in allImages) {
      final src = img.attributes['src'] ?? '';
      if (src.isNotEmpty) {
        final icon = isIcon(src, img);
        tasks.add(
          optimizeImageUrl(src, width: icon ? 100 : 500).then((optUrl) {
            img.attributes['src'] = optUrl;
            if (icon) img.classes.add('heritage-inline-icon');
            if (img == heroElement) heroImageUrl = optUrl;
          }),
        );
      }
    }
    await Future.wait(tasks);

    // 4. Mark hero container so it doesn't appear twice (once in top header and once in body)
    if (heroElement != null) {
      dom.Element? container = heroElement;
      var parent = heroElement.parent;
      while (parent != null && parent.localName != 'body') {
        if (parent.localName == 'figure' ||
            parent.classes.contains('thumb') ||
            parent.classes.contains('infobox-image')) {
          container = parent;
          break;
        }
        parent = parent.parent;
      }
      container?.classes.add('hidden-hero-container');
    }

    return {
      'html': document.body?.innerHtml ?? '',
      'heroImageUrl': heroImageUrl,
    };
  }

  /// Filters out icons, small badges, and UI logos
  static bool isIcon(String src, [dom.Element? element]) {
    final lower = src.toLowerCase();
    if (lower.contains('.svg') ||
        lower.contains('/static/') ||
        lower.contains('icon') ||
        lower.contains('logo') ||
        lower.contains('symbol')) {
      return true;
    }
    if (element != null) {
      final width = int.tryParse(element.attributes['width'] ?? '');
      if (width != null && width <= 60) return true;
    }
    return false;
  }

  /// Normalizes protocol and upgrades Wikimedia Commons thumbs to requested width
  static Future<String> optimizeImageUrl(String url, {int width = 500}) async {
    String normalized = url;
    if (url.startsWith('//')) {
      normalized = 'https:$url';
    } else if (url.startsWith('/')) {
      normalized = 'https://upload.wikimedia.org$url';
    }

    // Extract Commons filename from thumb URL if applicable
    if (normalized.contains('/thumb/')) {
      try {
        final segments = Uri.parse(normalized).pathSegments;
        for (final segment in segments) {
          if (segment.contains('.') && !segment.contains('px-')) {
            final fileName = "File:$segment";
            if (_optimizerCache.containsKey('${fileName}_$width')) {
              return _optimizerCache['${fileName}_$width']!;
            }
            final apiUrl =
                'https://commons.wikimedia.org/w/api.php?action=query&titles=${Uri.encodeComponent(fileName)}&prop=imageinfo&iiprop=url&iiurlwidth=$width&format=json';
            final res = await http.get(Uri.parse(apiUrl), headers: {
              'User-Agent': 'NiasHeritageApp/1.0',
            });
            if (res.statusCode == 200) {
              final data = json.decode(res.body);
              final pages = data['query']?['pages'] as Map<String, dynamic>?;
              if (pages != null && pages.isNotEmpty) {
                final page = pages.values.first;
                final imageInfo = page['imageinfo'] as List<dynamic>?;
                if (imageInfo != null && imageInfo.isNotEmpty) {
                  final thumbUrl = imageInfo[0]['thumburl'] as String?;
                  if (thumbUrl != null) {
                    final cleanUrl = thumbUrl.split('?').first;
                    _optimizerCache['${fileName}_$width'] = cleanUrl;
                    return cleanUrl;
                  }
                }
              }
            }
          }
        }
      } catch (_) {}
    }
    return normalized;
  }
}
```

---

## 4. Flutter Screen-Wide & Gallery Widgets

### The HTML Renderer Integration

In your screen's `build` method, pass `customWidgetBuilder` to `HtmlWidget`:

```dart
HtmlWidget(
  processedHtml,
  customWidgetBuilder: (element) {
    // 1. Intercept galleries (<ul class="gallery"> or <div class="gallery">)
    if (element.classes.contains('gallery')) {
      return buildNativeGallery(context, element);
    }

    // 2. Intercept single images & figures (<figure typeof="mw:File/Thumb"> or .thumb)
    final isThumb = element.classes.contains('thumb') ||
        (element.localName == 'figure' &&
            element.attributes['typeof']?.contains('mw:File/Thumb') == true);

    if (isThumb) {
      // Don't re-render hero image if already displayed in header
      if (element.classes.contains('hidden-hero-container')) {
        return const SizedBox.shrink();
      }

      final img = element.localName == 'img' ? element : element.querySelector('img');
      if (img != null && !img.classes.contains('heritage-inline-icon')) {
        final caption = element.querySelector('.caption')?.text ??
            element.querySelector('.thumbcaption')?.text ??
            element.querySelector('figcaption')?.text;

        return buildFullWidthImage(context, img, caption);
      }
    }

    return null; // Fallback to default HTML rendering for other tags
  },
)
```

---

### Full-Width Screen Image Builder

This widget renders each photo **edge-to-edge** within standard screen padding, rounded with a clean card radius and an italicized caption below:

```dart
Widget buildFullWidthImage(BuildContext context, dom.Element img, String? caption) {
  final src = img.attributes['src'] ?? '';
  if (src.isEmpty) return const SizedBox.shrink();
  final fullImageUrl = src.startsWith('http') ? src : 'https:$src';
  final theme = Theme.of(context);

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageViewer(imagePath: fullImageUrl),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Hero(
              tag: fullImageUrl,
              child: Image.network(
                fullImageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: double.infinity,
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                  child: const Center(child: Icon(Icons.broken_image, size: 36)),
                ),
              ),
            ),
          ),
        ),
        if (caption != null && caption.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Text(
              caption.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    ),
  );
}
```

---

### Horizontal Carousel Gallery Builder

Replaces rigid multi-line HTML galleries with a smooth, touch-friendly horizontal card carousel:

```dart
Widget buildNativeGallery(BuildContext context, dom.Element galleryElement) {
  final items = galleryElement.querySelectorAll('.gallerybox');
  if (items.isEmpty) return const SizedBox.shrink();

  return Container(
    height: 280,
    margin: const EdgeInsets.symmetric(vertical: 24),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final box = items[index];
        final img = box.querySelector('img');
        final caption = box.querySelector('.gallerytext')?.text ?? '';

        if (img == null) return const SizedBox.shrink();
        final src = img.attributes['src'] ?? '';
        final fullImageUrl = src.startsWith('http') ? src : 'https:$src';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageViewer(imagePath: fullImageUrl),
              ),
            );
          },
          child: Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full cover photo
                  Hero(
                    tag: fullImageUrl,
                    child: Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Dark gradient backdrop ensuring caption text is always readable
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
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Text(
                        caption.trim(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
```

---

## 5. Non-HTML Data Model Usage (Pure Flutter)

If your Nias Heritage app loads data from **JSON** or local assets (e.g., historical artifacts, traditional houses *Omo Hada*, stone monuments *Megalit*, gold ornaments) rather than HTML, you can use the exact same visual presentation with standard Dart objects:

```dart
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

class HeritageHorizontalGallery extends StatelessWidget {
  final List<HeritagePhoto> photos;

  const HeritageHorizontalGallery({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(imagePath: photo.imageUrl),
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
                      tag: photo.imageUrl,
                      child: Image.network(
                        photo.imageUrl,
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
                          photo.caption ?? photo.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
```

---

## 6. Full-Screen Interactive Pinch-to-Zoom Viewer

When a user taps either a screen-wide image or a gallery card, navigate them to an interactive zoomable full-screen viewer:

```dart
class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;

  const FullScreenImageViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: imagePath,
            child: Image.network(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 7. Key Best Practices

1. **Card Dimensions:** Standardizing gallery items to `width: 300` and `height: 280` ensures cards have a comfortable aspect ratio on both phones and tablets without letterboxing.
2. **Hero Tag Uniqueness:** Always use the full image URL as the `Hero` tag. This connects the in-article image or gallery card seamlessly with the full-screen zoomable viewer.
3. **Contrast Gradient:** Always apply a `LinearGradient` ending with `Colors.black.withValues(alpha: 0.8)` over the bottom 25% of gallery cards so captions remain readable over white or bright photos.
4. **Shimmer / Placeholder:** Provide a lightweight placeholder in `loadingBuilder` with `theme.colorScheme.onSurface.withValues(alpha: 0.05)` to eliminate layout jumps while high-resolution photos stream in.
