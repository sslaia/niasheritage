import 'package:html/parser.dart' as html_parser;
import 'package:drift/drift.dart';
import '../database/database.dart';
import 'title_sanitizer.dart';

List<RecitationsCompanion> parseRecitationPage({
  required String wikitext,
  required String htmlText,
  required int pageId,
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
    RecitationsCompanion(
      pageId: Value(pageId),
      title: Value(title),
      textContent: Value(textContent),
      description: const Value(null),
      descId: const Value(null),
      descEn: const Value(null),
      editor: const Value(null),
      source: const Value(null),
      url: Value(url),
    ),
  ];
}
