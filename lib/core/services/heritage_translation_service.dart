import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/heritage_article_parser.dart';
import 'article_encryption_service.dart';

class HeritageDisplayArticle {
  final String title;
  final String markdownContent;
  final String textContent;
  final String? imageUrl;
  final List<ArticleFootnote> footnotes;
  final String lang;
  final bool isTranslated;

  const HeritageDisplayArticle({
    required this.title,
    required this.markdownContent,
    required this.textContent,
    this.imageUrl,
    this.footnotes = const [],
    required this.lang,
    required this.isTranslated,
  });

  // Backward compatibility getter for any callers expecting htmlContent
  String? get htmlContent => markdownContent;
}

class HeritageArticleQueryParam {
  final String category;
  final int pageId;
  final String lang;

  const HeritageArticleQueryParam({
    required this.category,
    required this.pageId,
    required this.lang,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeritageArticleQueryParam &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          pageId == other.pageId &&
          lang == other.lang;

  @override
  int get hashCode => category.hashCode ^ pageId.hashCode ^ lang.hashCode;
}

const Map<String, String> _categoryHeroImages = {
  'architecture': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/omo_hada.jpg',
  'megalith': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/gowe.jpg',
  'arts': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/famaena.jpg',
  'clothing': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/oholu.jpg',
  'village': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/banua.jpg',
  'origin': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/origin.jpg',
  'timeline': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/timeline.jpg',
};

final heritageDisplayArticleProvider =
    FutureProvider.family<HeritageDisplayArticle?, HeritageArticleQueryParam>((ref, param) async {
  // Normalize category: 'dance' -> 'arts'
  final category = param.category == 'dance' ? 'arts' : param.category;

  // 1. Try requested language: assets/articles/${category}_${lang}.bin / .md
  HeritageDisplayArticle? article = await _loadMarkdownArticle(category, param.lang);
  if (article != null) return article;

  // 2. Fallbacks: 'id' -> 'en' -> 'nia'
  for (final fallbackLang in ['id', 'en', 'nia']) {
    if (fallbackLang == param.lang) continue;
    article = await _loadMarkdownArticle(category, fallbackLang);
    if (article != null) return article;
  }

  return null;
});

Future<HeritageDisplayArticle?> _loadMarkdownArticle(String category, String lang) async {
  try {
    String? content;

    // 1. Try loading encrypted binary (.bin) first
    try {
      final binPath = 'assets/articles/${category}_$lang.bin';
      final byteData = await rootBundle.load(binPath);
      final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      content = ArticleEncryptionService.decryptMarkdown(bytes);
    } catch (_) {
      // 2. Fallback to unencrypted .md (for local development before encryption)
      try {
        final mdPath = 'assets/articles/${category}_$lang.md';
        content = await rootBundle.loadString(mdPath);
      } catch (_) {
        return null;
      }
    }

    final trimmed = content.trim();
    if (trimmed.isEmpty) return null;

    // Extract title from first line / heading
    String title = category;
    final lines = trimmed.split('\n');
    for (final line in lines) {
      final t = line.trim();
      if (t.startsWith('# ')) {
        title = t.substring(2).trim();
        break;
      } else if (t.startsWith('**') && t.endsWith('**')) {
        title = t.replaceAll('**', '').split('\n').first.trim();
        break;
      }
    }

    return HeritageDisplayArticle(
      title: title,
      markdownContent: trimmed,
      textContent: trimmed,
      imageUrl: _categoryHeroImages[category],
      footnotes: const [],
      lang: lang,
      isTranslated: lang != 'nia',
    );
  } catch (_) {
    return null;
  }
}
