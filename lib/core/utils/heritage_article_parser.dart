import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../wikimedia/html_processor.dart';

export 'title_sanitizer.dart' show sanitizeArticleTitle, unescapeHtmlEntities;

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

class ParsedWikitextResult {
  final String title;
  final String markdown;
  final List<ArticleFootnote> footnotes;

  const ParsedWikitextResult({
    required this.title,
    required this.markdown,
    required this.footnotes,
  });
}

/// Converts MediaWiki wikitext from Nias Wikipedia into clean Markdown and extracts footnotes.
ParsedWikitextResult parseHeritageWikitext(String wikitext, {String defaultTitle = ''}) {
  var text = wikitext;

  // 1. Remove categories [[Kategori:...]] or [[Category:...]]
  text = text.replaceAll(RegExp(r'\[\[(Kategori|Category):[^\]]+\]\]', caseSensitive: false), '');

  // 2. Remove references section tags <references .../> or <references>...</references> or {{Reflist}}
  text = text.replaceAll(RegExp(r'<references\s*/\s*>', caseSensitive: false), '');
  text = text.replaceAll(RegExp(r'<references[^>]*>.*?</references>', caseSensitive: false, dotAll: true), '');
  text = text.replaceAll(RegExp(r'\{\{(reflist|references)[^\}]*\}\}', caseSensitive: false), '');

  // 3. Extract Footnotes / References from <ref ...>...</ref> or <ref name="..." />
  final List<ArticleFootnote> footnotes = [];
  final Map<String, int> namedRefIndices = {};
  int footnoteCounter = 1;

  final refRegex = RegExp(
    r'''<ref(?:\s+name\s*=\s*["']?([^"' >/]+)["']?)?\s*(?:/>|>(.*?)</ref>)''',
    dotAll: true,
    caseSensitive: false,
  );

  text = text.replaceAllMapped(refRegex, (match) {
    final name = match.group(1);
    final content = match.group(2);

    if (content == null || content.trim().isEmpty) {
      // Self-closing ref: <ref name="x" />
      if (name != null && namedRefIndices.containsKey(name)) {
        final idx = namedRefIndices[name]!;
        return ' [**[$idx]**](#footnote-$idx)';
      }
      return '';
    }

    final int currentIndex = footnoteCounter++;
    if (name != null) {
      namedRefIndices[name] = currentIndex;
    }

    // Clean inner wikitext links in footnote: [[Target|Label]] -> Label
    var cleanFootnote = content.replaceAll(RegExp(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]'), r'$1').trim();
    cleanFootnote = cleanFootnote.replaceAll("'''", '').replaceAll("''", '');

    String? url;
    final urlMatch = RegExp(r'https?://[^\s\]]+').firstMatch(cleanFootnote);
    if (urlMatch != null) {
      url = urlMatch.group(0);
    }

    footnotes.add(ArticleFootnote(
      index: currentIndex,
      id: name ?? 'cite_note-$currentIndex',
      text: cleanFootnote,
      url: url,
    ));

    return ' [**[$currentIndex]**](#footnote-$currentIndex)';
  });

  // 4. Convert MediaWiki Headings
  text = text.replaceAllMapped(RegExp(r'^\s*====\s*(.*?)\s*====\s*$', multiLine: true), (m) => '#### ${m.group(1)?.trim()}');
  text = text.replaceAllMapped(RegExp(r'^\s*===\s*(.*?)\s*===\s*$', multiLine: true), (m) => '### ${m.group(1)?.trim()}');
  text = text.replaceAllMapped(RegExp(r'^\s*==\s*(.*?)\s*==\s*$', multiLine: true), (m) => '## ${m.group(1)?.trim()}');

  // 5. Convert Bold & Italic
  text = text.replaceAllMapped(RegExp(r"'''''(.*?)'''''"), (m) => '***${m.group(1)}***');
  text = text.replaceAllMapped(RegExp(r"'''(.*?)'''"), (m) => '**${m.group(1)}**');
  text = text.replaceAllMapped(RegExp(r"''(.*?)''"), (m) => '*${m.group(1)}*');

  // 6. Strip image embeds: [[File:...]], [[Berkas:...]], [[Gambar:...]]
  text = text.replaceAll(RegExp(r'\[\[(File|Berkas|Gambar|Image):[^\]]+\]\]', caseSensitive: false), '');

  // 7. Convert Wiki internal links [[Target|Label]] -> Label, [[Target]] -> Target
  text = text.replaceAllMapped(RegExp(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]'), (m) => m.group(1)!);

  // 8. Convert Wikitables ({| ... |}) to GitHub Flavored Markdown tables
  text = convertWikitablesToMarkdown(text);

  // 9. Enrich any existing standalone bracketed footnote numbers [1], [7] into links
  text = enrichFootnoteLinks(text, footnotes);

  // 10. Strip MediaWiki magic words like __TOC__, __NOTOC__
  text = text.replaceAll(RegExp(r'__[A-Z]+__'), '');

  // 11. Clean multiple blank lines
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return ParsedWikitextResult(
    title: defaultTitle,
    markdown: text.trim(),
    footnotes: footnotes,
  );
}

/// Converts any standalone bracketed footnote numbers (e.g. "[7]") into clickable markdown links
/// ("[**[7]**](#footnote-7)") if they match a known footnote index and are not already links.
String enrichFootnoteLinks(String markdown, List<ArticleFootnote> footnotes) {
  if (footnotes.isEmpty || !markdown.contains('[')) return markdown;
  final indices = footnotes.map((f) => f.index).toSet();
  // Matches [1], [7] not preceded by [ and not followed by (
  final regex = RegExp(r'(?<!\[)\[(\d+)\](?!\()');
  return markdown.replaceAllMapped(regex, (match) {
    final idxStr = match.group(1)!;
    final idx = int.tryParse(idxStr);
    if (idx != null && indices.contains(idx)) {
      return '[**[$idx]**](#footnote-$idx)';
    }
    return match.group(0)!;
  });
}

/// Converts MediaWiki tables ({| ... |}) into GitHub Flavored Markdown tables.
String convertWikitablesToMarkdown(String text) {
  if (!text.contains('{|')) {
    return text;
  }

  final tableRegex = RegExp(r'\{\|(.*?)\|\}', dotAll: true);
  return text.replaceAllMapped(tableRegex, (match) {
    final rawTable = match.group(1) ?? '';
    return _parseSingleWikitable(rawTable);
  });
}

String _parseSingleWikitable(String rawTable) {
  final lines = rawTable.split('\n');
  String caption = '';
  final List<List<String>> rows = [];
  List<String>? currentRow;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;

    // 1. Caption |+
    if (line.startsWith('|+')) {
      var cap = line.substring(2).trim();
      if (cap.contains('|') && !cap.startsWith('[')) {
        final pipeIdx = cap.indexOf('|');
        if (cap.substring(0, pipeIdx).contains('=')) {
          cap = cap.substring(pipeIdx + 1).trim();
        }
      }
      caption = cap;
      continue;
    }

    // 2. Row delimiter |-
    if (line.startsWith('|-')) {
      if (currentRow != null && currentRow.isNotEmpty) {
        rows.add(currentRow);
      }
      currentRow = [];
      continue;
    }

    // 3. Header cells !
    if (line.startsWith('!')) {
      currentRow ??= [];
      final content = line.substring(1).trim();
      final cells = content.split('!!');
      for (var c in cells) {
        currentRow.add(_cleanTableCell(c));
      }
      continue;
    }

    // 4. Data cells | (make sure it's not |} or |+ or |-)
    if (line.startsWith('|') && !line.startsWith('|}') && !line.startsWith('|+') && !line.startsWith('|-')) {
      currentRow ??= [];
      final content = line.substring(1).trim();
      final cells = content.split('||');
      for (var c in cells) {
        currentRow.add(_cleanTableCell(c));
      }
      continue;
    }

    // 5. Continuation of previous cell content
    if (currentRow != null && currentRow.isNotEmpty) {
      final lastIdx = currentRow.length - 1;
      currentRow[lastIdx] = '${currentRow[lastIdx]} ${line.trim()}';
    }
  }

  if (currentRow != null && currentRow.isNotEmpty) {
    rows.add(currentRow);
  }

  if (rows.isEmpty) return '';

  // Determine max columns
  int maxCols = 0;
  for (final r in rows) {
    if (r.length > maxCols) maxCols = r.length;
  }
  if (maxCols == 0) return '';

  // Normalize row lengths
  for (final r in rows) {
    while (r.length < maxCols) {
      r.add('');
    }
  }

  final buffer = StringBuffer();
  buffer.writeln();

  if (caption.isNotEmpty) {
    buffer.writeln('**$caption**\n');
  }

  // Header row (row 0)
  final headerRow = rows.first;
  buffer.write('| ');
  for (int c = 0; c < maxCols; c++) {
    buffer.write(_formatCellMarkdown(headerRow[c]));
    buffer.write(' | ');
  }
  buffer.writeln();

  // Separator row
  buffer.write('| ');
  for (int c = 0; c < maxCols; c++) {
    buffer.write('--- | ');
  }
  buffer.writeln();

  // Data rows (row 1..n)
  for (int r = 1; r < rows.length; r++) {
    final row = rows[r];
    buffer.write('| ');
    for (int c = 0; c < maxCols; c++) {
      buffer.write(_formatCellMarkdown(row[c]));
      buffer.write(' | ');
    }
    buffer.writeln();
  }

  buffer.writeln();
  return buffer.toString();
}

String _cleanTableCell(String raw) {
  var c = raw.trim();
  if (c.contains('|')) {
    final pipeIdx = c.indexOf('|');
    final prefix = c.substring(0, pipeIdx).trim();
    // Only treat as attribute if it does not contain [[ and matches an attribute pattern
    if (!prefix.contains('[[') &&
        RegExp(r'^(?:style|class|align|valign|width|height|colspan|rowspan|bgcolor|scope)\s*=',
                caseSensitive: false)
            .hasMatch(prefix)) {
      c = c.substring(pipeIdx + 1).trim();
    }
  }
  return c;
}

String _formatCellMarkdown(String cell) {
  var s = cell.replaceAll(RegExp(r'\r?\n'), '<br>').trim();
  // Escape raw pipes that are not part of links
  s = s.replaceAll('|', r'\|');
  return s.isEmpty ? ' ' : s;
}

/// Normalizes Wikimedia image URLs:
/// 1. Prepends https: to protocol-relative URLs (//upload...)
/// 2. Strips query parameters (e.g. ?utm_source=...)
/// 3. Normalizes thumbnail widths to 500px, which is a standard supported thumbnail step on Wikimedia servers
String cleanWikimediaImageUrl(String rawSrc) {
  return HtmlProcessor.cleanWikimediaImageUrl(rawSrc);
}

/// Parses the MediaWiki HTML returned by action=parse for a Wikipedia page on nia.wikipedia.org.
/// Extracts citations and footnotes, removes the Umbu section, and prepares clean offline content.
ParsedHeritageArticle parseHeritageArticleHtml({
  required String htmlText,
  required String defaultTitle,
}) {
  final processed = const HtmlProcessor().process(
    rawContent: htmlText,
    defaultTitle: defaultTitle,
    hideHeroImageInBody: false,
  );

  return ParsedHeritageArticle(
    title: processed.title,
    textContent: processed.textContent,
    htmlContent: processed.html,
    imageUrl: processed.heroImageUrl,
    footnotes: processed.footnotes,
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
