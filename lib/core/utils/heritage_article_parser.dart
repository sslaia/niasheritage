import 'dart:convert';
import 'package:html/parser.dart' as html_parser;
import 'package:drift/drift.dart';
import '../database/database.dart';

class ArticleFootnote {
  final int index;
  final String id;
  final String text;
  final String? url;

  const ArticleFootnote({
    required this.index,
    required this.id,
    required this.text,
    this.url,
  });

  Map<String, dynamic> toJson() => {
        'index': index,
        'id': id,
        'text': text,
        'url': url,
      };

  factory ArticleFootnote.fromJson(Map<String, dynamic> json) => ArticleFootnote(
        index: json['index'] as int? ?? 1,
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        url: json['url'] as String?,
      );
}

class ParsedHeritageArticle {
  final String title;
  final String textContent;
  final String? htmlContent;
  final String? imageUrl;
  final List<ArticleFootnote> footnotes;

  const ParsedHeritageArticle({
    required this.title,
    required this.textContent,
    this.htmlContent,
    this.imageUrl,
    this.footnotes = const [],
  });
}

/// Normalizes Wikimedia image URLs:
/// 1. Prepends https: to protocol-relative URLs (//upload...)
/// 2. Strips query parameters (e.g. ?utm_source=...)
/// 3. Normalizes thumbnail widths to 500px, which is a standard supported thumbnail step on Wikimedia servers
String cleanWikimediaImageUrl(String rawSrc) {
  var src = rawSrc.trim();
  if (src.isEmpty) return '';

  if (src.startsWith('//')) {
    src = 'https:$src';
  }

  // Strip query parameters
  if (src.contains('?')) {
    src = src.split('?').first;
  }

  // Replace &amp; with & just in case
  src = src.replaceAll('&amp;', '&');

  // If thumbnail, scale to standard 500px width
  if (src.contains('/thumb/')) {
    final parts = src.split('/');
    final last = parts.last;
    final match = RegExp(r'^\d+px-(.+)').firstMatch(last);
    if (match != null) {
      final originalName = match.group(1)!;
      parts.removeLast();
      parts.add('500px-$originalName');
      src = parts.join('/');
    }
  }

  return src;
}

/// Parses the MediaWiki HTML returned by action=parse for a Wikipedia page on nia.wikipedia.org.
/// Extracts citations and footnotes, removes the Umbu section, and prepares clean offline content.
ParsedHeritageArticle parseHeritageArticleHtml({
  required String htmlText,
  required String defaultTitle,
}) {
  final doc = html_parser.parse(htmlText);

  // 1. Extract Footnotes / References from <ol class="references"> or <li id="cite_note-...">
  final List<ArticleFootnote> footnotes = [];
  final refElements = doc.querySelectorAll('ol.references > li, li[id^="cite_note-"]');

  int fallbackIndex = 1;
  for (final ref in refElements) {
    final rawId = ref.attributes['id'] ?? 'cite_note-$fallbackIndex';
    // Clean out backlink (e.g. "↑" arrow)
    ref.querySelectorAll('.mw-cite-backlink, a[href^="#cite_ref-"]').forEach((el) => el.remove());

    final refText = ref.text.trim();
    // Try finding external URLs inside citation
    String? refUrl;
    final link = ref.querySelector('a.external, a[href^="http"]');
    if (link != null) {
      refUrl = link.attributes['href'];
    }

    footnotes.add(ArticleFootnote(
      index: fallbackIndex,
      id: rawId,
      text: refText,
      url: refUrl,
    ));
    fallbackIndex++;
  }

  // 2. Extract Featured Image from <figure> or <img> if present
  String? featuredImageUrl;
  final imgElements = doc.querySelectorAll('figure img, .thumbimage, img.mw-file-element');
  for (final img in imgElements) {
    final rawSrc = img.attributes['src'] ?? '';
    final lower = rawSrc.toLowerCase();
    if (lower.contains('gnome') ||
        lower.contains('ambox') ||
        lower.contains('question_book') ||
        lower.contains('disambig') ||
        lower.contains('edit-clear') ||
        lower.contains('padlock') ||
        lower.contains('wikimedia-button')) {
      continue;
    }
    final cleaned = cleanWikimediaImageUrl(rawSrc);
    if (cleaned.isNotEmpty) {
      featuredImageUrl = cleaned;
      break;
    }
  }

  // 3. Extract Title
  final heading = doc.querySelector('#firstHeading, .firstHeading, h1');
  final title = heading?.text.trim().isNotEmpty == true ? heading!.text.trim() : defaultTitle;

  // 4. Clean only MediaWiki technical clutter, scripts, styles, and edit buttons
  doc.querySelectorAll('.mw-empty-elt, nav, .toc, #toc, .mw-editsection, style, script, .mw-cite-backlink').forEach((el) => el.remove());

  // Clean raw textContent and htmlContent
  final container = doc.querySelector('.mw-parser-output, .mw-content-ltr') ?? doc.body;
  final textContent = container?.text.trim() ?? '';
  final htmlContent = container?.innerHtml.trim() ?? doc.body?.innerHtml.trim();

  return ParsedHeritageArticle(
    title: title,
    textContent: textContent,
    htmlContent: htmlContent,
    imageUrl: featuredImageUrl,
    footnotes: footnotes,
  );
}

HeritageArticlesCompanion createHeritageArticleCompanion({
  required int pageId,
  required String category,
  required String pageTitle,
  required String wikiHost,
  required ParsedHeritageArticle parsed,
  int lastRevid = 0,
}) {
  final footnotesJson = jsonEncode(parsed.footnotes.map((f) => f.toJson()).toList());

  return HeritageArticlesCompanion(
    pageId: Value(pageId),
    category: Value(category),
    wikiHost: Value(wikiHost),
    pageTitle: Value(pageTitle),
    title: Value(parsed.title),
    textContent: Value(parsed.textContent),
    htmlContent: Value(parsed.htmlContent),
    footnotes: Value(footnotesJson),
    imageUrl: Value(parsed.imageUrl),
    lastRevid: Value(lastRevid),
    lastUpdated: Value(DateTime.now()),
  );
}
