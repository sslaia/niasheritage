import 'package:html/parser.dart' as html_parser;

List<Map<String, String?>> parseProverbsItems({
  required String wikitext,
  required String htmlText,
  required String letter,
}) {
  final results = <Map<String, String?>>[];

  // Method 1: Parse via Wikitext (Lines starting with #)
  if (wikitext.isNotEmpty) {
    final lines = wikitext.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (!line.startsWith('#')) continue;

      // Remove leading # and numbers/spaces
      line = line.replaceFirst(RegExp(r'^#+\s*'), '').trim();
      if (line.isEmpty) continue;

      // Remove footnotes: <ref>...</ref> or <ref ... />
      line = line.replaceAll(RegExp(r'<ref[^>]*>[\s\S]*?<\/ref>', caseSensitive: false), '');
      line = line.replaceAll(RegExp(r'<ref[^>]*\/>', caseSensitive: false), '');
      line = line.trim();

      // Extract text in italics: ''text''
      final italicMatch = RegExp(r"''([\s\S]+?)''").firstMatch(line);
      if (italicMatch == null) continue;

      String sayingText = italicMatch.group(1)!.trim();
      sayingText = cleanWikiText(sayingText);
      if (sayingText.isEmpty) continue;

      final translations = <String, String>{};

      // Extract Eluaha templates: {{Wb/nia/Eluaha|nia|...}} or {{Eluaha|id|...}} or {{Eluaha|...}}
      final matches = RegExp(r'\{\{\s*(?:Wb\/nia\/)?Eluaha\s*\|([^\}]+)\}\}', caseSensitive: false).allMatches(line);
      for (final match in matches) {
        final body = match.group(1)?.trim() ?? '';
        if (body.isEmpty) continue;

        final parts = body.split('|').map((e) => e.trim()).toList();
        String lang = 'nia';
        String text = '';

        if (parts.length == 1) {
          text = parts[0];
        } else {
          final firstLower = parts[0].toLowerCase();
          if (['nia', 'id', 'en', 'ind', 'eng', 'indonesia', 'english'].contains(firstLower)) {
            lang = firstLower;
            text = parts.sublist(1).join('|');
          } else {
            text = parts.join('|');
          }
        }

        text = cleanWikiText(text);
        if (text.isNotEmpty) {
          final normLang = _normalizeLangCode(lang);
          translations[normLang] = text;
        }
      }

      // If no Eluaha template found, check for fallback meaning after "Eluaha:" or "Eluahania:"
      if (translations.isEmpty) {
        final remaining = line.substring(italicMatch.end).trim();
        final eluahaMatch = RegExp(r'eluaha(?:nia)?\s*:?\s*', caseSensitive: false).firstMatch(remaining);
        if (eluahaMatch != null) {
          var meaning = remaining.substring(eluahaMatch.end).trim();
          meaning = cleanWikiText(meaning);
          if (meaning.isNotEmpty) {
            translations['nia'] = meaning;
          }
        }
      }

      results.add({
        'text': sayingText,
        'meaning': translations['nia'] ?? '',
        'meaning_id': translations['id'],
        'meaning_en': translations['en'],
      });
    }
  }

  // Method 2: Fallback to HTML parsing if wikitext produced no items
  if (results.isEmpty && htmlText.isNotEmpty) {
    final doc = html_parser.parse(htmlText);
    doc.querySelectorAll('sup.reference, ol.references, .mw-cite-backlink').forEach((e) => e.remove());

    final listItems = doc.querySelectorAll('ol > li, ul > li');
    for (final li in listItems) {
      final italicElement = li.querySelector('i, em');
      if (italicElement == null) continue;

      final sayingText = italicElement.text.trim();
      if (sayingText.isEmpty) continue;

      final translations = <String, String>{};

      // Search for class="translation" elements (or elements with translation in class)
      final transElements = li.querySelectorAll('.translation, [class*="translation"]');
      for (final transEl in transElements) {
        String lang = transEl.attributes['lang']?.trim().toLowerCase() ?? '';
        String text = '';

        final contentEl = transEl.querySelector('.mw-collapsible-content');
        if (contentEl != null) {
          text = contentEl.text.trim();
        } else {
          final clone = transEl.clone(true);
          clone.querySelectorAll('.mw-collapsible-toggle, sup.reference').forEach((e) => e.remove());
          text = clone.text.trim();
        }

        // Clean any leading [nia], [id], [en] or Eluaha prefix
        text = text.replaceFirst(RegExp(r'^\s*\[(nia|id|en)\]\s*', caseSensitive: false), '');
        text = text.replaceFirst(RegExp(r'^\s*eluaha(?:nia)?\s*:?\s*', caseSensitive: false), '').trim();

        if (lang.isEmpty) {
          final classAttr = transEl.attributes['class'] ?? '';
          if (classAttr.contains('id')) {
            lang = 'id';
          } else if (classAttr.contains('en')) {
            lang = 'en';
          } else {
            lang = 'nia';
          }
        }

        if (text.isNotEmpty) {
          final normLang = _normalizeLangCode(lang);
          translations[normLang] = text;
        }
      }

      // Fallback if no translation span elements found
      if (translations.isEmpty) {
        italicElement.remove();
        final remainingText = li.text.trim();

        final eluahaMatch = RegExp(r'eluaha(?:nia)?\s*:?\s*', caseSensitive: false).firstMatch(remainingText);
        if (eluahaMatch != null) {
          var meaning = remainingText.substring(eluahaMatch.end).trim();
          meaning = meaning.replaceFirst(RegExp(r'^\s*\[(nia|id|en)\]\s*', caseSensitive: false), '').trim();
          if (meaning.isNotEmpty) {
            translations['nia'] = meaning;
          }
        }
      }

      results.add({
        'text': sayingText,
        'meaning': translations['nia'] ?? '',
        'meaning_id': translations['id'],
        'meaning_en': translations['en'],
      });
    }
  }

  // Enrichment step: If wikitext was parsed, supplement missing translations from HTML class="translation" elements
  if (results.isNotEmpty && htmlText.isNotEmpty) {
    try {
      final doc = html_parser.parse(htmlText);
      doc.querySelectorAll('sup.reference, ol.references, .mw-cite-backlink').forEach((e) => e.remove());
      final listItems = doc.querySelectorAll('ol > li, ul > li');

      for (int i = 0; i < results.length && i < listItems.length; i++) {
        final li = listItems[i];
        final transElements = li.querySelectorAll('.translation, [class*="translation"]');

        for (final transEl in transElements) {
          String lang = transEl.attributes['lang']?.trim().toLowerCase() ?? '';
          String text = '';

          final contentEl = transEl.querySelector('.mw-collapsible-content');
          if (contentEl != null) {
            text = contentEl.text.trim();
          } else {
            final clone = transEl.clone(true);
            clone.querySelectorAll('.mw-collapsible-toggle, sup.reference').forEach((e) => e.remove());
            text = clone.text.trim();
          }

          text = text.replaceFirst(RegExp(r'^\s*\[(nia|id|en)\]\s*', caseSensitive: false), '');
          text = text.replaceFirst(RegExp(r'^\s*eluaha(?:nia)?\s*:?\s*', caseSensitive: false), '').trim();

          if (lang.isEmpty) {
            final classAttr = transEl.attributes['class'] ?? '';
            if (classAttr.contains('id')) {
              lang = 'id';
            } else if (classAttr.contains('en')) {
              lang = 'en';
            } else {
              lang = 'nia';
            }
          }

          if (text.isNotEmpty) {
            final normLang = _normalizeLangCode(lang);
            if (normLang == 'nia' && (results[i]['meaning'] == null || results[i]['meaning']!.isEmpty)) {
              results[i]['meaning'] = text;
            } else if (normLang == 'id' && (results[i]['meaning_id'] == null || results[i]['meaning_id']!.isEmpty)) {
              results[i]['meaning_id'] = text;
            } else if (normLang == 'en' && (results[i]['meaning_en'] == null || results[i]['meaning_en']!.isEmpty)) {
              results[i]['meaning_en'] = text;
            }
          }
        }
      }
    } catch (_) {}
  }

  return results;
}

// Backwards compatibility alias
const parseAmaedolaItems = parseProverbsItems;

String _normalizeLangCode(String lang) {
  final lower = lang.trim().toLowerCase();
  if (['id', 'ind', 'indonesia', 'indonesian'].contains(lower)) return 'id';
  if (['en', 'eng', 'english'].contains(lower)) return 'en';
  return 'nia';
}

String cleanWikiText(String input) {
  var s = input;
  // Remove [[link|text]] -> text, [[link]] -> link
  s = s.replaceAllMapped(RegExp(r'\[\[([^\]|]+\|)?([^\]]+)\]\]'), (m) => m.group(2) ?? '');
  // Remove external links [http... label] -> label
  s = s.replaceAllMapped(RegExp(r'\[https?:\/\/\S+\s*([^\]]*)\]'), (m) => m.group(1) ?? '');
  // Remove bold markup '''
  s = s.replaceAll("'''", "");
  // Remove leftover single quotes
  s = s.replaceAll("''", "");
  // Normalize whitespace
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}
