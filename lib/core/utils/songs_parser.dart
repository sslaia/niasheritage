import 'package:html/parser.dart' as html_parser;
import 'package:drift/drift.dart';
import '../database/database.dart';

List<SongsCompanion> parseSongsPage({
  required String wikitext,
  required String htmlText,
  required int pageId,
  String category = 'sinunö',
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
      genre: const Value(null),
      released: const Value(null),
      recorded: const Value(null),
      studio: const Value(null),
      label: const Value(null),
      url: const Value(null),
      youtube: const Value(null),
    ),
  ];
}

// Backwards compatibility alias
const parseSongPage = parseSongsPage;
