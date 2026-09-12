import 'package:html/parser.dart' as html_parser;
import 'package:drift/drift.dart';
import '../database/database.dart';

List<RecitationsCompanion> parseRecitationPage({
  required String wikitext,
  required String htmlText,
  required int pageId,
}) {
  final doc = html_parser.parse(htmlText);
  final headings = doc.querySelectorAll('h1, h2, h3, .firstHeading, #firstHeading');
  String title = 'Lö hadöi töi';
  if (headings.isNotEmpty) {
    title = headings.first.text.trim();
  }

  doc.querySelectorAll('sup.reference, ol.references, .mw-cite-backlink, nav, .toc').forEach((e) => e.remove());
  final textContent = doc.body?.text.trim() ?? wikitext;

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
      url: const Value(null),
    ),
  ];
}

// Backward-compatibility aliases
const parseEpicPage = parseRecitationPage;
const parseHohoPage = parseRecitationPage;
