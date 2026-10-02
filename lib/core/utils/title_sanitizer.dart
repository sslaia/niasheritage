/// Utility functions for decoding HTML entities and sanitizing article titles
/// from Wikimedia platforms (Wikipedia, Wikibooks, Wikimedia Incubator, etc.).
library;

/// Unescapes HTML numeric (decimal and hex) and named entities.
/// For example:
/// - `&#039;` or `&#39;` or `&apos;` -> `'`
/// - `&quot;` -> `"`
/// - `&amp;` -> `&`
/// - `&lt;` -> `<`
/// - `&gt;` -> `>`
/// - `&nbsp;` -> ` `
String unescapeHtmlEntities(String text) {
  if (!text.contains('&')) return text;

  String decodePass(String input) {
    var s = input;

    // 1. Decimal character entities: &#123; or &#0123;
    s = s.replaceAllMapped(RegExp(r'&#(\d{1,7});'), (match) {
      final code = int.tryParse(match.group(1)!);
      if (code != null && code > 0 && code <= 0x10FFFF) {
        try {
          return String.fromCharCode(code);
        } catch (_) {
          return match.group(0)!;
        }
      }
      return match.group(0)!;
    });

    // 2. Hexadecimal character entities: &#x1f600; or &#X27;
    s = s.replaceAllMapped(RegExp(r'&#[xX]([0-9a-fA-F]{1,6});'), (match) {
      final code = int.tryParse(match.group(1)!, radix: 16);
      if (code != null && code > 0 && code <= 0x10FFFF) {
        try {
          return String.fromCharCode(code);
        } catch (_) {
          return match.group(0)!;
        }
      }
      return match.group(0)!;
    });

    // 3. Named entities
    const namedMap = {
      '&quot;': '"',
      '&apos;': "'",
      '&amp;': '&',
      '&lt;': '<',
      '&gt;': '>',
      '&nbsp;': ' ',
      '&ndash;': '–',
      '&mdash;': '—',
      '&lsquo;': '‘',
      '&rsquo;': '’',
      '&sbquo;': '‚',
      '&ldquo;': '“',
      '&rdquo;': '”',
      '&bdquo;': '„',
      '&hellip;': '…',
      '&copy;': '©',
      '&reg;': '®',
      '&trade;': '™',
      '&bull;': '•',
      '&prime;': '′',
      '&Prime;': '″',
    };

    namedMap.forEach((k, v) {
      s = s.replaceAll(k, v);
    });

    return s;
  }

  var decoded = decodePass(text);
  // Support nested/double escaping like &amp;#039;
  if (decoded != text && decoded.contains('&')) {
    decoded = decodePass(decoded);
  }
  // Normalize non-breaking spaces
  decoded = decoded.replaceAll('\u00A0', ' ');
  return decoded;
}

/// Sanitizes raw article titles from Wikipedia and Wikimedia Incubator.
///
/// Features:
/// 1. Strips HTML wrapper tags (e.g. `<span lang="...">...</span>`)
/// 2. Unescapes HTML numeric and named entities (e.g. `&#039;` -> `'`, `&quot;` -> `"`)
/// 3. Removes Wikimedia Incubator language prefixes (e.g. `Wb/nia/`, `Wp/nia/`, `Wt/nia/`, `Wb/`, etc.)
/// 4. Removes User subpage prefixes (e.g. `Sangoguna:Slaia/`, `User:AnyUser/`)
/// 5. Removes standard Wikimedia namespace prefixes (e.g. `Wikipedia:`, `Wikibooks:`, `Category:`, etc.)
/// 6. Converts underscores to spaces and cleans redundant whitespace
/// 7. Falls back to [fallbackLabel] if clean title is empty or invalid
String sanitizeArticleTitle(String rawTitle, {String? fallbackLabel}) {
  // 1. Remove HTML tags
  var clean = rawTitle.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  // 2. Unescape HTML entities
  clean = unescapeHtmlEntities(clean);

  // 3. Strip Wikimedia Incubator project/language prefixes (if any legacy titles remain)
  clean = clean.replaceFirst(
    RegExp(r'^(?:W[bptqysvn]\/[a-z0-9_-]+\/|W[bptqysvn]\/)', caseSensitive: false),
    '',
  );

  // 4. Strip User / Sangoguna subpage namespace prefixes
  clean = clean.replaceFirst(
    RegExp(r'^(?:Sangoguna|User):[^\/]+\/', caseSensitive: false),
    '',
  );

  // 5. Strip standard namespace prefixes (excluding Wikipedia:SN which is handled below)
  if (!clean.toLowerCase().startsWith('wikipedia:sn/')) {
    clean = clean.replaceFirst(
      RegExp(
        r'^(?:Wikipedia|Wikibooks|Wiktionary|Wikiquote|Wikisource|Category|Kategori|Help|Fanolo|Template|Templat):',
        caseSensitive: false,
      ),
      '',
    );
  }

  // 6. Convert underscores to spaces
  clean = clean.replaceAll('_', ' ').trim();

  // 7. Decode entities once more in case of residual encoded characters
  clean = unescapeHtmlEntities(clean).trim();

  // 8. Format Bible subpages: Wikipedia:SN/<Book>/<Chapter> -> <Book> <Chapter>
  final bibleMatch = RegExp(r'^(?:Wikipedia:)?SN\/([^\/]+)(?:\/(\d+))?$', caseSensitive: false).firstMatch(clean);
  if (bibleMatch != null) {
    final book = bibleMatch.group(1)!.trim();
    final chapter = bibleMatch.group(2);
    clean = chapter != null ? '$book $chapter' : book;
  } else {
    // 9. Format known section subpages: Hoho/, Manö-Manö/, Sinunö/, Amaedola/
    clean = clean.replaceFirst(
      RegExp(r'^(?:Hoho|Manö-[Mm]anö|Mano-[Mm]ano|Sinunö|Sinuno|Amaedola)\/', caseSensitive: false),
      '',
    );

    // 10. Fallback for any cross-listed subpages (e.g. in Sinura amilita): Parent/Child -> Child
    if (clean.contains('/')) {
      final slashIdx = clean.lastIndexOf('/');
      final leaf = clean.substring(slashIdx + 1).trim();
      if (leaf.isNotEmpty) {
        clean = leaf;
      }
    }
  }

  if (clean.isEmpty && fallbackLabel != null && fallbackLabel.trim().isNotEmpty) {
    return sanitizeArticleTitle(fallbackLabel);
  }

  return clean.isNotEmpty
      ? clean
      : (fallbackLabel != null
          ? sanitizeArticleTitle(fallbackLabel)
          : unescapeHtmlEntities(rawTitle.trim()));
}
