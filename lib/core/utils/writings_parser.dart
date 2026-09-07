import 'package:html/parser.dart' as html_parser;
import 'package:drift/drift.dart';
import '../database/database.dart';

List<ArticlesCompanion> parseWritingsPage({
  required String wikitext,
  required String htmlText,
  required int pageId,
  String category = 'general',
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
    ArticlesCompanion(
      pageId: Value(pageId),
      category: Value(category),
      title: Value(title),
      textContent: Value(textContent),
      description: const Value(null),
      editor: const Value(null),
    ),
  ];
}

// Backwards compatibility alias
const parseArticlePage = parseWritingsPage;
