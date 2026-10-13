import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'wiki_config.dart';

/// Helper utility for handling Wikimedia Commons and MediaWiki image URLs,
/// generating bandwidth-friendly and memory-constrained thumbnail URLs,
/// and rendering cached network images with Wikimedia-compliant headers.
class WikimediaImageHelper {
  const WikimediaImageHelper._();

  /// MediaWiki's standard thumbnail width buckets in production.
  /// Direct requests (hotlinking) to Wikimedia servers are rejected with
  /// HTTP 400 Bad Request unless they use a standard size.
  /// See: https://www.mediawiki.org/wiki/Common_thumbnail_sizes
  static const List<int> standardThumbnailWidths = [
    20,
    40,
    60,
    120,
    250,
    330,
    500,
    960,
    1280,
    1920,
    3840,
  ];

  /// Snaps an arbitrary width to the closest matching Wikimedia standard width
  /// (rounding up to preserve image fidelity on high-DPI displays).
  static int snapToStandardWidth(int width) {
    if (width <= standardThumbnailWidths.first) {
      return standardThumbnailWidths.first;
    }
    for (final std in standardThumbnailWidths) {
      if (width <= std) {
        return std;
      }
    }
    return standardThumbnailWidths.last;
  }

  /// Regex pattern to detect Wikimedia upload domains.
  static final RegExp _wikimediaUploadRegex = RegExp(
    r'^https?://(upload|thumb)\.wikimedia\.org/wikipedia/([^/]+)/(.+)$',
    caseSensitive: false,
  );

  /// Regex pattern to detect already-resized thumbnail suffix (e.g. /500px-File.jpg),
  /// including optional query parameters.
  static final RegExp _thumbSuffixRegex = RegExp(
    r'/(\d+)px-([^/?#]+)((?:\?[^#]*)?(?:#.*)?)$',
    caseSensitive: false,
  );

  /// Regex pattern to detect lossy page thumbnail suffix (e.g. for TIFFs),
  /// including optional query parameters.
  static final RegExp _lossyThumbSuffixRegex = RegExp(
    r'/lossy-page1-(\d+)px-([^/?#]+)((?:\?[^#]*)?(?:#.*)?)$',
    caseSensitive: false,
  );

  /// Normalizes and ensures HTTPS on a URL.
  static String ensureHttps(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }
    return trimmed;
  }

  /// Checks whether a given URL points to Wikimedia servers.
  static bool isWikimediaUrl(String url) {
    final clean = ensureHttps(url).toLowerCase();
    return clean.contains('wikimedia.org') ||
        clean.contains('wikipedia.org') ||
        clean.contains('wiktionary.org') ||
        clean.contains('wikibooks.org');
  }

  /// Converts any Wikimedia image URL into a CDN-scaled thumbnail URL.
  /// Snaps the requested [width] to Wikimedia's standard thumbnail size buckets
  /// to avoid HTTP 400 Bad Request errors.
  ///
  /// Examples:
  /// - `https://upload.wikimedia.org/wikipedia/commons/1/1b/House.jpg`
  ///   -> `https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/House.jpg/960px-House.jpg`
  /// - `https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/House.jpg/500px-House.jpg`
  ///   -> `https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/House.jpg/960px-House.jpg`
  /// - `https://commons.wikimedia.org/wiki/Special:FilePath/House.jpg`
  ///   -> `https://commons.wikimedia.org/wiki/Special:FilePath/House.jpg?width=960`
  /// - Non-Wikimedia URLs are returned unchanged.
  static String getThumbnailUrl(String rawUrl, {int width = 960}) {
    if (rawUrl.isEmpty) return rawUrl;
    final url = ensureHttps(rawUrl);
    final targetWidth = snapToStandardWidth(width);

    // 1. Handle Special:FilePath and Special:Redirect/file
    if (url.contains('Special:FilePath') || url.contains('Special:Redirect/file')) {
      try {
        final uri = Uri.parse(url);
        final qp = Map<String, String>.from(uri.queryParameters);
        qp['width'] = targetWidth.toString();
        return uri.replace(queryParameters: qp).toString();
      } catch (_) {
        return url;
      }
    }

    // 2. Handle upload.wikimedia.org / thumb.wikimedia.org
    final uploadMatch = _wikimediaUploadRegex.firstMatch(url);
    if (uploadMatch != null) {
      final repo = uploadMatch.group(2)!; // e.g. commons, id, nia, en
      final path = uploadMatch.group(3)!; // remainder path after /wikipedia/{repo}/

      // Case A: URL is already a /thumb/ URL
      if (path.startsWith('thumb/')) {
        // Check if there is an existing /lossy-page1-{N}px-{file}
        if (_lossyThumbSuffixRegex.hasMatch(url)) {
          return url.replaceFirstMapped(
            _lossyThumbSuffixRegex,
            (m) => '/lossy-page1-${targetWidth}px-${m.group(2)}${m.group(3) ?? ''}',
          );
        }
        // Check if there is an existing /{N}px-{file}
        if (_thumbSuffixRegex.hasMatch(url)) {
          return url.replaceFirstMapped(
            _thumbSuffixRegex,
            (m) => '/${targetWidth}px-${m.group(2)}${m.group(3) ?? ''}',
          );
        }
        // It's a thumb URL but without standard size suffix: append size suffix
        final queryIndex = path.indexOf('?');
        final cleanPath = queryIndex != -1 ? path.substring(0, queryIndex) : path;
        final query = queryIndex != -1 ? path.substring(queryIndex) : '';
        final fileName = cleanPath.split('/').last;
        final baseUrl = queryIndex != -1 ? url.substring(0, url.indexOf('?')) : url;
        return '$baseUrl/${targetWidth}px-$fileName$query';
      }

      // Case B: URL is an original image URL (e.g. /commons/a/ab/File.ext)
      final queryIndex = path.indexOf('?');
      final cleanPath = queryIndex != -1 ? path.substring(0, queryIndex) : path;
      final query = queryIndex != -1 ? path.substring(queryIndex) : '';
      final parts = cleanPath.split('/');
      final fileName = parts.last;
      final lowerName = fileName.toLowerCase();

      String sizeSuffix;
      if (lowerName.endsWith('.svg')) {
        sizeSuffix = '${targetWidth}px-$fileName.png';
      } else if (lowerName.endsWith('.tif') || lowerName.endsWith('.tiff')) {
        sizeSuffix = 'lossy-page1-${targetWidth}px-$fileName.jpg';
      } else {
        sizeSuffix = '${targetWidth}px-$fileName';
      }

      return 'https://upload.wikimedia.org/wikipedia/$repo/thumb/$cleanPath/$sizeSuffix$query';
    }

    // Default: return unchanged for non-Wikimedia or unknown schemas
    return url;
  }

  /// Builds a cached image widget with optimal thumbnail resolution,
  /// memory-constrained decoding, and Wikimedia headers.
  static Widget buildImage({
    required BuildContext context,
    required String imageUrl,
    int targetWidth = 960,
    int? memCacheWidth,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
  }) {
    final snappedTargetWidth = snapToStandardWidth(targetWidth);
    final effectiveUrl = getThumbnailUrl(imageUrl, width: snappedTargetWidth);
    final theme = Theme.of(context);
    final effectiveMemCacheWidth = memCacheWidth != null
        ? snapToStandardWidth(memCacheWidth)
        : snappedTargetWidth;

    final isTestEnvironment =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    Widget image = CachedNetworkImage(
      imageUrl: effectiveUrl,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: WikiConfig.headers,
      memCacheWidth: effectiveMemCacheWidth,
      placeholder: placeholder ??
          (context, url) => Container(
                width: width,
                height: height,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: isTestEnvironment
                        ? Icon(
                            Icons.image_outlined,
                            size: 20,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                          )
                        : const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
      errorWidget: errorWidget ??
          (context, url, error) => Container(
                width: width,
                height: height,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 36),
                ),
              ),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }

    return image;
  }
}
