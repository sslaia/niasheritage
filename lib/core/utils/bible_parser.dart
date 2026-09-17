import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:drift/drift.dart';
import '../database/database.dart';

List<BiblesCompanion> parseBibleChapterPage({
  required String htmlText,
  required String book,
  required int chapter,
  required String category,
  int? pageId,
}) {
  final document = html_parser.parse(htmlText);

  // Strip non-scripture elements before parsing: figures, captions, images, galleries, infoboxes, navboxes, sidebars, scripts, styles
  for (final el in document.querySelectorAll(
    'figure, figcaption, img, .thumb, .thumbcaption, .thumbinner, .gallery, .infobox, .navbox, .sidebar, style, script, .mw-editsection, noscript, audio, video',
  )) {
    el.remove();
  }

  // 1. Build map of footnote cite notes: id -> clean reference text
  final Map<String, String> citeNotes = {};
  for (final li in document.querySelectorAll('li[id^="cite_note-"]')) {
    final noteId = li.id;
    var noteText = li.text.trim();
    if (noteText.startsWith('↑')) {
      noteText = noteText.substring(1).trim();
    }
    noteText = noteText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (noteText.isNotEmpty) {
      citeNotes[noteId] = noteText;
    }
  }

  // 2. Find all verse anchor spans: <span class="anchor" id="N">N</span>
  final anchorSpans = document.querySelectorAll('span.anchor');
  final Map<int, ({String textContent, List<String> references})> verseMap = {};
  int expectedVerse = 1;
  dom.Element? lastParent;

  for (int i = 0; i < anchorSpans.length; i++) {
    final span = anchorSpans[i];
    final verseIdStr = span.id.trim();
    var verseNum = int.tryParse(verseIdStr);
    if (verseNum == null) continue;

    final parent = span.parent;
    if (parent == null) continue;

    final bool isParagraphStart = (lastParent != null && parent != lastParent);
    lastParent = parent;

    final nextSpan = (i + 1 < anchorSpans.length) ? anchorSpans[i + 1] : null;
    final List<String> verseRefs = [];

    final StringBuffer verseTextBuffer = StringBuffer();
    final parentNodes = parent.nodes;
    final spanIdx = parentNodes.indexOf(span);

    if (spanIdx != -1) {
      for (int k = spanIdx + 1; k < parentNodes.length; k++) {
        final node = parentNodes[k];
        if (node == nextSpan) break;
        if (node is dom.Element && (node == nextSpan || node.querySelectorAll('span.anchor').contains(nextSpan))) {
          break;
        }
        _collectNodeTextAndRefs(node, verseTextBuffer, verseRefs, citeNotes);
      }
    }

    // If nextSpan is not in parent, continue across sibling paragraph blocks (e.g. multi-paragraph verses)
    if (nextSpan == null || !parent.contains(nextSpan)) {
      dom.Element? nextBlock = parent.nextElementSibling;
      while (nextBlock != null) {
        final tag = nextBlock.localName?.toLowerCase() ?? '';
        // Only scripture text blocks (<p> or <blockquote>) can be part of a verse.
        // Stop at any non-paragraph elements (headings, reflists, figures, tables, lists, etc.)
        if (tag != 'p' && tag != 'blockquote') {
          break;
        }

        if (nextSpan != null && (nextBlock == nextSpan || nextBlock.contains(nextSpan))) {
          for (final node in nextBlock.nodes) {
            if (node == nextSpan || (node is dom.Element && (node == nextSpan || node.contains(nextSpan)))) {
              break;
            }
            _collectNodeTextAndRefs(node, verseTextBuffer, verseRefs, citeNotes);
          }
          break;
        } else {
          // If the next paragraph contains any other anchor span, stop
          if (nextBlock.querySelectorAll('span.anchor').isNotEmpty) {
            break;
          }

          verseTextBuffer.write(' ');
          for (final node in nextBlock.nodes) {
            _collectNodeTextAndRefs(node, verseTextBuffer, verseRefs, citeNotes);
          }
          nextBlock = nextBlock.nextElementSibling;
        }
      }
    }

    var rawText = verseTextBuffer.toString().trim();
    if (rawText.isEmpty) {
      final parentClone = parent.clone(true);
      for (final sup in parentClone.querySelectorAll('sup.reference')) {
        sup.remove();
      }
      rawText = parentClone.text.trim();
      final versePrefixRegExp = RegExp(r'^' + RegExp.escape(verseIdStr) + r'\s+');
      if (versePrefixRegExp.hasMatch(rawText)) {
        rawText = rawText.replaceFirst(versePrefixRegExp, '');
      }
    }

    var cleanText = cleanBibleText(rawText);
    if (cleanText.isEmpty || cleanText == verseIdStr || cleanText == verseNum.toString()) {
      continue;
    }

    if (isParagraphStart) {
      cleanText = '\n\n$cleanText';
    }

    // Auto-correct duplicate/out-of-order verse number if it is out of sequence and fills expectedSequence
    if (verseMap.containsKey(verseNum) && verseNum != (expectedVerse - 1) && !verseMap.containsKey(expectedVerse) && expectedVerse > 0) {
      verseNum = expectedVerse;
    }

    if (verseMap.containsKey(verseNum)) {
      final existing = verseMap[verseNum]!;
      String combinedText = existing.textContent;
      if (!combinedText.contains(cleanText)) {
        combinedText = combinedText.isEmpty ? cleanText : '$combinedText $cleanText';
      }
      final combinedRefs = List<String>.from(existing.references);
      for (final r in verseRefs) {
        if (!combinedRefs.contains(r)) combinedRefs.add(r);
      }
      verseMap[verseNum] = (textContent: combinedText, references: combinedRefs);
    } else {
      verseMap[verseNum] = (textContent: cleanText, references: verseRefs);
      if (verseNum >= expectedVerse) {
        expectedVerse = verseNum + 1;
      }
    }
  }

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

String cleanBibleText(String input) {
  var s = input;
  // Remove inline bracketed footnote markers [1], [2], etc.
  s = s.replaceAll(RegExp(r'\[\d+\]'), '');
  // Remove wiki link brackets [[link|text]] -> text, [[link]] -> link
  s = s.replaceAllMapped(RegExp(r'\[\[([^\]|]+\|)?([^\]]+)\]\]'), (m) => m.group(2) ?? '');
  // Remove external links [http... label] -> label
  s = s.replaceAllMapped(RegExp(r'\[https?:\/\/\S+\s*([^\]]*)\]'), (m) => m.group(1) ?? '');
  // Remove bold/italic quotes
  s = s.replaceAll("'''", "");
  s = s.replaceAll("''", "");
  // Fix punctuation spacing resulting from removed footnote markers (e.g. "khöra, imane" instead of "khöra , imane")
  s = s.replaceAll(RegExp(r'\s+([,.;!?])'), r'\1');
  // Normalize whitespace
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

void _collectNodeTextAndRefs(
  dom.Node node,
  StringBuffer verseTextBuffer,
  List<String> verseRefs,
  Map<String, String> citeNotes,
) {
  if (node is dom.Element) {
    final refLinks = node.localName == 'a' && (node.attributes['href'] ?? '').contains('#cite_note-')
        ? [node]
        : node.querySelectorAll('a[href*="#cite_note-"]');
    for (final refA in refLinks) {
      final href = refA.attributes['href'] ?? '';
      final noteKey = href.contains('#') ? href.split('#').last : href;
      if (citeNotes.containsKey(noteKey)) {
        final refText = citeNotes[noteKey]!;
        if (!verseRefs.contains(refText)) {
          verseRefs.add(refText);
        }
      }
    }

    final nodeClone = node.clone(true);
    for (final sup in nodeClone.querySelectorAll('sup.reference, figure, figcaption, img, .thumb, .thumbcaption')) {
      sup.remove();
    }
    verseTextBuffer.write(nodeClone.text);
  } else if (node is dom.Text) {
    verseTextBuffer.write(node.text);
  }
}
