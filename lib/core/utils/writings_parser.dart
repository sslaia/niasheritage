import 'package:html/parser.dart' as html_parser;
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../wikimedia/html_processor.dart';

List<ArticlesCompanion> parseWritingsPage({
  required String wikitext,
  required String htmlText,
  required int pageId,
  String category = 'general',
  String? pageTitle,
  String? url,
}) {
  final doc = html_parser.parse(htmlText);

  final isFeatured = category == 'featured' || (pageTitle != null && pageTitle.contains('Sura amilita'));

  // Check if this is an excerpt rotation template (e.g. Wikipedia:Sura amilita/1)
  final isFeaturedSnippet = pageTitle != null &&
      (pageTitle.startsWith('Wikipedia:Sura amilita/') ||
          pageTitle.startsWith('Sura amilita/'));

  String title = '';
  if (isFeaturedSnippet) {
    // 1. Try {{Baso|...}} template from wikitext
    final basoMatch = RegExp(r'\{\{Baso\|([^}]+)\}\}').firstMatch(wikitext);
    if (basoMatch != null) {
      title = basoMatch.group(1)!.replaceAll('_', ' ').trim();
    }
    if (title.isEmpty) {
      final linkMatch = RegExp(r'\[\[([^|\]]+)\|[^\]]*Baso', caseSensitive: false).firstMatch(wikitext);
      if (linkMatch != null) {
        title = linkMatch.group(1)!.replaceAll('_', ' ').trim();
      }
    }
    // 3. Try bold title in wikitext (allowing apostrophes within Nias words e.g. Sura Ni'amoni'ö)
    if (title.isEmpty) {
      final boldMatch = RegExp(r"'''((?:(?!''')[\s\S])+)'''").firstMatch(wikitext);
      if (boldMatch != null) {
        title = boldMatch.group(1)!.replaceAll(RegExp(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]'), r'$1').trim();
      }
    }
  }

  // Prefer canonical pageTitle over internal body headings for regular pages and articles
  if (title.isEmpty) {
    title = (pageTitle != null && pageTitle.trim().isNotEmpty)
        ? pageTitle.replaceFirst('Wb/nia/', '').replaceAll('_', ' ').trim()
        : '';
  }
  if (title.isEmpty) {
    final headings = doc.querySelectorAll('h1, h2, h3, .firstHeading, #firstHeading');
    if (headings.isNotEmpty && headings.first.text.trim().isNotEmpty) {
      title = headings.first.text.trim();
    }
  }
  if (title.isEmpty) title = 'Lö hadöi töi';

  // If wikitext is available, use cleaned wikitext to preserve images, headings, and formatting
  String textContent = '';
  if (wikitext.trim().isNotEmpty) {
    var wt = wikitext;
    // Clean templates with balanced braces (e.g. {{Infobox ...}}, {{Wb/nia/Nav...}}, {{reflist}})
    wt = removeWikiTemplates(wt);
    // Remove category tags
    wt = wt.replaceAll(RegExp(r'\[\[(?:Kategori|Category):[^\]]+\]\]\s*', caseSensitive: false), '');
    if (isFeatured) {
      wt = wt.replaceAll(RegExp(r'\(?\s*Baso (?:dohu-tohunia|zanandrösa[^\)]*)\s*\)?', caseSensitive: false), '');
    }
    textContent = wt.trim();
  } else {
    // Strip styles, scripts, links, references, table of contents, edit links, and infoboxes
    doc.querySelectorAll(
      'style, script, link, meta, sup.reference, ol.references, .reflist, '
      '.mw-cite-backlink, nav, .toc, .mw-editsection, .mw-editsection-bracket, '
      '.mw-editsection-divider, .catlinks, #catlinks, .printfooter, '
      'table.infobox, .infobox, .infobox_v3, .infobox_v2, .infobox-subbox, .sidebar, .vertical-navbox, table.vcard'
    ).forEach((e) => e.remove());
    var rawText = doc.body?.text.trim() ?? '';
    if (isFeatured) {
      rawText = rawText.replaceAll(RegExp(r'\(?\s*Baso (?:dohu-tohunia|zanandrösa[^\)]*)\s*\)?', caseSensitive: false), '').trim();
    }
    textContent = rawText.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  return [
    ArticlesCompanion(
      pageId: Value(pageId),
      category: Value(isFeatured ? 'featured' : category),
      title: Value(title),
      textContent: Value(textContent),
      description: Value(isFeatured ? 'Wikipedia Nias' : null),
      editor: const Value(null),
    ),
  ];
}
