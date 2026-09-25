import 'package:html/parser.dart' as html_parser;
import 'package:drift/drift.dart';
import '../database/database.dart';
import 'title_sanitizer.dart';

List<SongsCompanion> parseSongsPage({
  required String wikitext,
  required String htmlText,
  required int pageId,
  String category = 'sinunö',
  String? pageTitle,
  String? url,
}) {
  final doc = html_parser.parse(htmlText);

  // Prefer canonical pageTitle over internal body headings
  String rawCandidate = (pageTitle != null && pageTitle.trim().isNotEmpty)
      ? pageTitle
      : '';
  if (rawCandidate.isEmpty) {
    final headings = doc.querySelectorAll('h1, h2, h3, .firstHeading, #firstHeading');
    if (headings.isNotEmpty && headings.first.text.trim().isNotEmpty) {
      rawCandidate = headings.first.text.trim();
    }
  }
  final title = sanitizeArticleTitle(rawCandidate, fallbackLabel: 'Lö hadöi töi');

  // Strip styles, scripts, links, references, table of contents, and edit links
  doc.querySelectorAll(
    'style, script, link, meta, sup.reference, ol.references, .reflist, '
    '.mw-cite-backlink, nav, .toc, .mw-editsection, .mw-editsection-bracket, '
    '.mw-editsection-divider, .catlinks, #catlinks, .printfooter'
  ).forEach((e) => e.remove());
  final rawText = doc.body?.text.trim() ?? wikitext;
  final textContent = rawText.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return [
    SongsCompanion(
      pageId: Value(pageId),
      title: Value(title),
      textContent: Value(textContent),
      category: Value(category),
      type: const Value(null),
      artist: const Value(null),
      writer: const Value(null),
      producer: const Value(null),
      album: const Value(null),
      genre: Value(category != 'sinunö' ? category : null),
      released: const Value(null),
      recorded: const Value(null),
      studio: const Value(null),
      label: const Value(null),
      url: Value(url),
      youtube: const Value(null),
    ),
  ];
}
