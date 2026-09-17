import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import '../../../../core/wikimedia/wiki_config.dart';
import '../../../../core/wikimedia/html_processor.dart';
import '../../../../core/utils/heritage_article_parser.dart';

class BibleBookEntry {
  final String name;
  final String pageTitle; // e.g. "Wb/nia/Mataio"
  final String category; // 'NT' or 'OT'

  const BibleBookEntry({
    required this.name,
    required this.pageTitle,
    required this.category,
  });
}

class BibleChapterContent {
  final String book;
  final int chapter;
  final String html;
  final List<ArticleFootnote> footnotes;

  const BibleChapterContent({
    required this.book,
    required this.chapter,
    required this.html,
    required this.footnotes,
  });
}

class BibleService {
  final http.Client _client;

  BibleService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the list of books directly from the Bible's main page
  /// at "Wb/nia/Sura Ni'amoni'ö" on Wikimedia Incubator.
  /// Ignores everything before subheading "Angolifa nösi",
  /// and ignores everything from subheading "Fehede famasao" until the end.
  Future<List<BibleBookEntry>> fetchBooksList() async {
    final uri = WikiConfig.actionApiUri(WikiConfig.incubatorHost, {
      'action': 'parse',
      'page': "Wb/nia/Sura_Ni'amoni'ö",
      'prop': 'text',
      'redirects': '1',
    });

    final response = await _client.get(uri, headers: WikiConfig.headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to load Bible books list (HTTP ${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json.containsKey('error')) {
      final errorInfo = json['error']?['info'] ?? json['error'].toString();
      throw Exception('Wikimedia API error: $errorInfo');
    }

    final parseData = json['parse'] as Map<String, dynamic>?;
    final rawHtml = parseData?['text']?['*'] as String? ?? '';

    return parseBooksFromHtml(rawHtml);
  }

  /// Parses books from HTML between "Angolifa nösi" and "Fehede".
  static List<BibleBookEntry> parseBooksFromHtml(String rawHtml) {
    final lowerHtml = rawHtml.toLowerCase();
    final idxAngolifa = lowerHtml.indexOf('angolifa n');
    if (idxAngolifa == -1) return [];

    // Search for Fehede / Fehede famasao
    int idxFehede = lowerHtml.indexOf('fehede', idxAngolifa);
    final sectionHtml = idxFehede != -1
        ? rawHtml.substring(idxAngolifa, idxFehede)
        : rawHtml.substring(idxAngolifa);

    final doc = html_parser.parseFragment(sectionHtml);
    final List<BibleBookEntry> books = [];

    // MediaWiki structure here consists of paragraphs starting with bold section labels:
    // <p><b>Amabu'ulali Sibohou</b>: <a href="/wiki/Wb/nia/Mataio" ...>Mataio</a> ...</p>
    // <p><b>Amabu'ulali Siföföna</b>: <a href="/wiki/Wb/nia/Moze_I" ...>Moze I</a> ...</p>
    final paragraphs = doc.querySelectorAll('p');
    for (final p in paragraphs) {
      final text = p.text;
      String category = 'NT';
      if (text.contains("Amabu'ulali Siföföna") || text.contains('Siföföna')) {
        category = 'OT';
      } else if (text.contains("Amabu'ulali Sibohou") || text.contains('Sibohou')) {
        category = 'NT';
      }

      final links = p.querySelectorAll('a');
      for (final a in links) {
        final href = a.attributes['href'] ?? '';
        final bookName = a.text.trim();
        if (bookName.isEmpty || href.contains('action=edit')) continue;

        // href format: /wiki/Wb/nia/Mataio or Wb/nia/Mataio
        var pageTitle = href;
        if (pageTitle.contains('/wiki/')) {
          pageTitle = pageTitle.substring(pageTitle.indexOf('/wiki/') + 6);
        }
        pageTitle = Uri.decodeComponent(pageTitle).trim();

        if (pageTitle.isNotEmpty) {
          books.add(BibleBookEntry(
            name: bookName,
            pageTitle: pageTitle,
            category: category,
          ));
        }
      }
    }

    return books;
  }

  /// Fetches available chapter numbers for a given book from its book index page
  /// (e.g. "Wb/nia/Mareko"). If single chapter (like Obadia/Filemo), defaults to [1].
  Future<List<int>> fetchBookChapters(String bookName) async {
    final cleanBook = bookName.trim().replaceAll(' ', '_');
    final pageTitle = cleanBook.startsWith('Wb/nia/') ? cleanBook : 'Wb/nia/$cleanBook';

    final uri = WikiConfig.actionApiUri(WikiConfig.incubatorHost, {
      'action': 'parse',
      'page': pageTitle,
      'prop': 'text',
      'redirects': '1',
    });

    try {
      final response = await _client.get(uri, headers: WikiConfig.headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final parseData = json['parse'] as Map<String, dynamic>?;
        final rawHtml = parseData?['text']?['*'] as String? ?? '';

        final doc = html_parser.parseFragment(rawHtml);
        final links = doc.querySelectorAll('a');
        final Set<int> chapters = {};

        final chapterRegex = RegExp(
          r'/(\d+)(?:[?#]|$)',
        );

        for (final a in links) {
          final href = a.attributes['href'] ?? '';
          final match = chapterRegex.firstMatch(href);
          if (match != null) {
            final ch = int.tryParse(match.group(1)!);
            if (ch != null && ch > 0) {
              chapters.add(ch);
            }
          }
        }

        if (chapters.isNotEmpty) {
          final sorted = chapters.toList()..sort();
          return sorted;
        }
      }
    } catch (_) {}

    // Fallback: at least Chapter 1 exists
    return [1];
  }

  /// Fetches a specific chapter's content (e.g. "Wb/nia/Mareko/3").
  /// Cuts off everything from the subheading "Fabaliŵa lala" until the end.
  /// Extracts footnotes for interactive bottom sheet display.
  Future<BibleChapterContent> fetchChapterContent({
    required String bookName,
    required int chapter,
  }) async {
    final cleanBook = bookName.trim().replaceAll(' ', '_');
    final bookTitle = cleanBook.startsWith('Wb/nia/') ? cleanBook : 'Wb/nia/$cleanBook';
    final pageTitle = '$bookTitle/$chapter';

    final uri = WikiConfig.actionApiUri(WikiConfig.incubatorHost, {
      'action': 'parse',
      'page': pageTitle,
      'prop': 'text',
      'redirects': '1',
    });

    final response = await _client.get(uri, headers: WikiConfig.headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to load $bookName $chapter (HTTP ${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json.containsKey('error')) {
      final errorInfo = json['error']?['info'] ?? json['error'].toString();
      throw Exception('Wikimedia API error: $errorInfo');
    }

    final parseData = json['parse'] as Map<String, dynamic>?;
    final rawHtml = parseData?['text']?['*'] as String? ?? '';

    return processChapterHtml(
      book: bookName,
      chapter: chapter,
      rawHtml: rawHtml,
    );
  }

  /// Processes raw MediaWiki chapter HTML:
  /// 1. Cuts off "Fabaliŵa lala" / "Fabaliwa lala" / "Bale zato" section and all subsequent siblings until end of page.
  /// 2. Hides/removes "Famotokhi ba gahe" (Footnotes) subheading since footnotes are handled via bottom sheets.
  /// 3. Extracts structured footnotes and cleans clutter using HtmlProcessor.
  static BibleChapterContent processChapterHtml({
    required String book,
    required int chapter,
    required String rawHtml,
  }) {
    final doc = html_parser.parse(rawHtml);
    final container = doc.querySelector('.mw-parser-output, .mw-content-ltr') ?? doc.body ?? doc.documentElement!;

    // 1. Cut off everything from subheading "Fabaliŵa lala" / "Fabaliwa lala" / "Bale zato" until the end
    final headings = container.querySelectorAll('h1, h2, h3, h4, h5, h6');
    for (final h in headings) {
      final text = h.text.trim().toLowerCase();
      final id = (h.attributes['id'] ?? '').toLowerCase();
      if (text.contains('fabaliŵa lala') ||
          text.contains('fabaliwa lala') ||
          id.contains('fabali') ||
          text.contains('bale zato') ||
          id.contains('bale_zato')) {
        dom.Element target = h;
        if (h.parent != null &&
            h.parent != container &&
            h.parent!.classes.contains('mw-heading')) {
          target = h.parent!;
        }
        final parent = target.parent;
        if (parent != null) {
          final siblings = parent.children.toList();
          final targetIdx = siblings.indexOf(target);
          if (targetIdx != -1) {
            for (int i = siblings.length - 1; i >= targetIdx; i--) {
              siblings[i].remove();
            }
          }
        } else {
          target.remove();
        }
        break;
      }
    }

    // Also remove any remaining trailing paragraphs containing navigation text like "Amabu'ulali Sibohou:" or "Bale zato:"
    for (final p in container.querySelectorAll('p')) {
      final t = p.text.trim().toLowerCase();
      if (t.contains("amabu'ulali sibohou") ||
          t.startsWith('bale zato:') ||
          t.contains('bale zato:') ||
          (t.contains('sura ') && t.contains('•'))) {
        p.remove();
      }
    }

    // 2. Hide/remove "Famotokhi ba gahe" (Footnotes) subheading
    final allHeadings = container.querySelectorAll('h1, h2, h3, h4, h5, h6');
    for (final h in allHeadings) {
      final text = h.text.trim().toLowerCase();
      final id = (h.attributes['id'] ?? '').toLowerCase();
      if (text.contains('famotokhi ba gahe') || id.contains('famotokhi') || text == 'famotokhi') {
        if (h.parent != null &&
            h.parent != container &&
            h.parent!.classes.contains('mw-heading')) {
          h.parent!.remove();
        } else {
          h.remove();
        }
      }
    }

    final cleanedRaw = container.innerHtml.trim();

    // 3. Process using HtmlProcessor (extracts footnotes from reflist before reflist is hidden)
    final processed = const HtmlProcessor().process(
      rawContent: cleanedRaw,
      defaultTitle: '$book $chapter',
      hideHeroImageInBody: false,
    );

    return BibleChapterContent(
      book: book,
      chapter: chapter,
      html: processed.html,
      footnotes: processed.footnotes,
    );
  }
}
