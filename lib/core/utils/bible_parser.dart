import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:drift/drift.dart';
import '../database/database.dart';

/// Parses a MediaWiki Bible chapter page into structured verse records using a DOM-stream
/// traversal. Preserves inline typography (bold, italic, poetic breaks) and accurate verse spans.
List<BiblesCompanion> parseBibleChapterPage({
  required String htmlText,
  required String book,
  required int chapter,
  required String category,
  int? pageId,
}) {
  final document = html_parser.parse(htmlText);
  final container = document.querySelector('.mw-parser-output, .mw-content-ltr') ??
      document.body ??
      document.documentElement!;

  // 1. Build map of footnote cite notes: id -> clean reference text
  final Map<String, String> citeNotes = {};
  for (final li in container.querySelectorAll('li[id^="cite_note-"]')) {
    final noteId = li.id;
    // Strip backlinks like "↑"
    for (final backlink in li.querySelectorAll('.mw-cite-backlink')) {
      backlink.remove();
    }
    for (final refA in li.querySelectorAll('a[href^="#cite_ref-"]')) {
      refA.remove();
    }
    var noteText = li.text.trim();
    if (noteText.startsWith('↑')) {
      noteText = noteText.substring(1).trim();
    }
    noteText = noteText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (noteText.isNotEmpty) {
      citeNotes[noteId] = noteText;
    }
  }

  // 2. Cut off from subheading "Famotokhi ba gahe" (or "Famotokhi") until the end of page
  for (final h in container.querySelectorAll('h1, h2, h3, h4, h5, h6')) {
    final hText = h.text.trim().toLowerCase();
    final hId = (h.attributes['id'] ?? '').toLowerCase();
    if (hText.contains('famotokhi') ||
        hId.contains('famotokhi') ||
        hText.contains('fabaliŵa lala') ||
        hText.contains('fabaliwa lala') ||
        hId.startsWith('fabaliwa') ||
        hId.startsWith('fabali.c5.b5a') ||
        hId.startsWith('fabali_') ||
        hText.contains('bale zato') ||
        hId.startsWith('bale_zato')) {
      dom.Element target = h;
      if (h.parent != null &&
          h.parent != container &&
          h.parent!.classes.contains('mw-heading')) {
        target = h.parent!;
      }
      final parent = target.parent;
      if (parent != null) {
        final siblings = parent.children.toList();
        final idx = siblings.indexOf(target);
        if (idx != -1) {
          for (int i = siblings.length - 1; i >= idx; i--) {
            siblings[i].remove();
          }
        }
      } else {
        target.remove();
      }
      break;
    }
  }

  // Strip remaining non-scripture clutter: figures, images, galleries, navboxes, sidebars, styles, scripts, edit buttons
  for (final el in container.querySelectorAll(
    'figure, figcaption, img, .thumb, .thumbcaption, .thumbinner, .gallery, .infobox, .navbox, .sidebar, style, script, .mw-editsection, noscript, audio, video, .reflist, #references, .references',
  )) {
    el.remove();
  }

  // 3. Sequential DOM-stream traversal between verse anchors
  final Map<int, ({String textContent, List<String> references})> verseMap = {};
  int? currentVerseNum;
  final StringBuffer currentBuffer = StringBuffer();
  final List<String> currentVerseRefs = [];

  void flushCurrentVerse() {
    if (currentVerseNum == null) return;
    final rawText = currentBuffer.toString();
    final cleanText = cleanBibleVerseHtml(rawText, currentVerseNum!);
    if (cleanText.isNotEmpty) {
      if (verseMap.containsKey(currentVerseNum!)) {
        final existing = verseMap[currentVerseNum!]!;
        final mergedText = '${existing.textContent} $cleanText'.trim();
        final mergedRefs = List<String>.from(existing.references);
        for (final r in currentVerseRefs) {
          if (!mergedRefs.contains(r)) mergedRefs.add(r);
        }
        verseMap[currentVerseNum!] = (textContent: mergedText, references: mergedRefs);
      } else {
        verseMap[currentVerseNum!] = (
          textContent: cleanText,
          references: List<String>.from(currentVerseRefs),
        );
      }
    }
    currentBuffer.clear();
    currentVerseRefs.clear();
  }

  void walkStream(dom.Node node) {
    if (node is dom.Comment) return;

    if (node is dom.Element) {
      final tag = node.localName?.toLowerCase() ?? '';
      final classes = node.classes;

      // Verse anchor check
      if (tag == 'span' && classes.contains('anchor')) {
        final idStr = node.id.trim();
        final vNum = int.tryParse(idStr);
        if (vNum != null && vNum > 0) {
          flushCurrentVerse();
          currentVerseNum = vNum;
          return; // Skip anchor tag content itself
        }
      }

      // Footnote reference check: <sup class="reference">
      if (tag == 'sup' && (classes.contains('reference') || node.querySelector('a[href*="#cite_note-"]') != null)) {
        final refLinks = node.querySelectorAll('a[href*="#cite_note-"]');
        for (final refA in refLinks) {
          final href = refA.attributes['href'] ?? '';
          final noteKey = href.contains('#') ? href.split('#').last : href;
          if (citeNotes.containsKey(noteKey)) {
            final refText = citeNotes[noteKey]!;
            if (!currentVerseRefs.contains(refText)) {
              currentVerseRefs.add(refText);
            }
          }
        }
        return; // Do not output footnote marker in verse text
      }

      // Skip internal chapter subheadings (pericopes) from verse text
      if (tag == 'h1' || tag == 'h2' || tag == 'h3' || tag == 'h4' || tag == 'h5' || tag == 'h6' || classes.contains('mw-heading')) {
        return;
      }

      // Inline typography: bold, italic, underline
      if (tag == 'b' || tag == 'strong' || tag == 'i' || tag == 'em' || tag == 'u') {
        if (currentVerseNum != null) {
          final innerHtml = _serializeInlineChildren(node, citeNotes, currentVerseRefs);
          final trimmedInner = innerHtml.trim();
          if (trimmedInner.isNotEmpty) {
            currentBuffer.write('<$tag>$trimmedInner</$tag>');
          }
        }
        return;
      }

      // Line break (for Psalms, Proverbs, poetry)
      if (tag == 'br') {
        if (currentVerseNum != null) {
          currentBuffer.write('<br>');
        }
        return;
      }

      // Paragraph / blockquote boundary
      if (tag == 'p' || tag == 'blockquote') {
        if (currentVerseNum != null && currentBuffer.isNotEmpty) {
          final bufStr = currentBuffer.toString();
          if (!bufStr.endsWith('\n\n') && !bufStr.endsWith('<br>')) {
            currentBuffer.write('\n\n');
          }
        }
        for (final child in node.nodes) {
          walkStream(child);
        }
        return;
      }

      // Link tags: preserve clean anchor text and any inner formatting
      if (tag == 'a') {
        if (currentVerseNum != null) {
          final innerHtml = _serializeInlineChildren(node, citeNotes, currentVerseRefs);
          currentBuffer.write(innerHtml);
        }
        return;
      }

      // Default element: recurse children
      for (final child in node.nodes) {
        walkStream(child);
      }
    } else if (node is dom.Text) {
      if (currentVerseNum != null) {
        final t = node.text;
        // Skip standalone Roman numeral section headers (e.g. "I.", "II.", "III.", "IV.")
        if (RegExp(r'^[IVXLCDM]+\.?$').hasMatch(t.trim())) {
          return;
        }
        currentBuffer.write(t);
      }
    }
  }

  // Execute DOM-stream walk
  for (final child in container.nodes) {
    walkStream(child);
  }
  flushCurrentVerse();

  // 4. Assemble sorted list of verses
  final sortedVerseNums = verseMap.keys.toList()..sort();
  final List<BiblesCompanion> verses = sortedVerseNums.map((vNum) {
    final data = verseMap[vNum]!;
    return BiblesCompanion(
      category: Value(category),
      book: Value(book),
      chapter: Value(chapter),
      verse: Value(vNum),
      textContent: Value(data.textContent),
      reference: Value(data.references),
      note: const Value(null),
      pageId: pageId != null ? Value(pageId) : const Value.absent(),
    );
  }).toList();

  return verses;
}

/// Recursively serializes inline children while preserving formatting tags and extracting citations.
String _serializeInlineChildren(
  dom.Element parent,
  Map<String, String> citeNotes,
  List<String> currentVerseRefs,
) {
  final buffer = StringBuffer();
  for (final node in parent.nodes) {
    if (node is dom.Comment) continue;

    if (node is dom.Element) {
      final tag = node.localName?.toLowerCase() ?? '';
      final classes = node.classes;

      if (tag == 'sup' && (classes.contains('reference') || node.querySelector('a[href*="#cite_note-"]') != null)) {
        final refLinks = node.querySelectorAll('a[href*="#cite_note-"]');
        for (final refA in refLinks) {
          final href = refA.attributes['href'] ?? '';
          final noteKey = href.contains('#') ? href.split('#').last : href;
          if (citeNotes.containsKey(noteKey)) {
            final refText = citeNotes[noteKey]!;
            if (!currentVerseRefs.contains(refText)) {
              currentVerseRefs.add(refText);
            }
          }
        }
        continue;
      }

      if (tag == 'b' || tag == 'strong' || tag == 'i' || tag == 'em' || tag == 'u') {
        final inner = _serializeInlineChildren(node, citeNotes, currentVerseRefs).trim();
        if (inner.isNotEmpty) {
          buffer.write('<$tag>$inner</$tag>');
        }
        continue;
      }

      if (tag == 'br') {
        buffer.write('<br>');
        continue;
      }

      if (tag == 'a') {
        buffer.write(_serializeInlineChildren(node, citeNotes, currentVerseRefs));
        continue;
      }

      buffer.write(_serializeInlineChildren(node, citeNotes, currentVerseRefs));
    } else if (node is dom.Text) {
      buffer.write(node.text);
    }
  }
  return buffer.toString();
}

/// Cleans and normalizes verse HTML while preserving `<b>`, `<i>`, `<em>`, `<strong>`, `<br>`, and paragraphs.
String cleanBibleVerseHtml(String input, int verseNum) {
  var s = input;

  // Remove leading verse number if mistakenly captured at start: e.g. "1 Sura mböröta" -> "Sura mböröta"
  final versePrefixRegex = RegExp(r'^\s*' + RegExp.escape(verseNum.toString()) + r'(?:\s+|\.|\:|\-)\s*');
  s = s.replaceFirst(versePrefixRegex, '');

  // Remove standalone Roman numeral pericope headings at start or end (e.g. "I. ", "\n\nII.")
  s = s.replaceAll(RegExp(r'^\s*[IVXLCDM]+\.\s*'), '');
  s = s.replaceAll(RegExp(r'(?:\r?\n)+\s*[IVXLCDM]+\.?\s*$'), '');

  // Remove bracketed footnote numbers like [1], [2], [14]
  s = s.replaceAll(RegExp(r'\[\d+\]'), '');

  // Remove raw wikitext links if any remain: [[Target|Label]] -> Label, [[Target]] -> Target
  s = s.replaceAllMapped(RegExp(r'\[\[(?:[^\]|]+\|)?([^\]]+)\]\]'), (m) => m.group(1) ?? '');

  // Remove external links [http... label] -> label
  s = s.replaceAllMapped(RegExp(r'\[https?:\/\/\S+\s*([^\]]*)\]'), (m) => m.group(1) ?? '');

  // Convert raw wikitext bold/italic quotes to HTML if present
  s = s.replaceAllMapped(RegExp(r"'''(.*?)'''"), (m) => '<b>${m.group(1)}</b>');
  s = s.replaceAllMapped(RegExp(r"''(.*?)''"), (m) => '<i>${m.group(1)}</i>');

  // Strip empty inline tags
  s = s.replaceAll(RegExp(r'<([a-z0-9]+)[^>]*>\s*<\/\1>', caseSensitive: false), '');

  // Fix punctuation spacing resulting from removed footnote markers (e.g. "khöra , imane" -> "khöra, imane")
  s = s.replaceAll(RegExp(r'\s+([,.;!?])'), r'\1');

  // Normalize duplicate spaces (excluding tags)
  s = s.replaceAll(RegExp(r'[ \t]+'), ' ');

  // Trim leading and trailing whitespace
  s = s.trim();

  // If after cleaning only the verse number or punctuation remains, return empty
  if (s == verseNum.toString() || s == '.' || s == ',' || s.isEmpty) {
    return '';
  }

  return s;
}
