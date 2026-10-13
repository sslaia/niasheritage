import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:drift/drift.dart';
import '../../../../core/wikimedia/wiki_config.dart';
import '../../../../core/wikimedia/html_processor.dart';
import '../../../../core/utils/heritage_article_parser.dart';
import '../../../../core/utils/bible_parser.dart';
import '../../../../core/database/database.dart';

class BibleBookEntry {
  final String name;
  final String pageTitle; // e.g. "Wikipedia:SN/Mataio"
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
  /// at "Wikipedia:SN" on Nias Wikipedia.
  /// Ignores everything before subheading "Angolifa nösi",
  /// and ignores everything from subheading "Fehede famasao" until the end.
  Future<List<BibleBookEntry>> fetchBooksList() async {
    final uri = WikiConfig.actionApiUri(WikiConfig.wikipediaHost, {
      'action': 'parse',
      'page': "Wikipedia:SN",
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
    // <p><b>Amabu'ulali Sibohou</b>: <a href="/wiki/Wikipedia:SN/Mataio" ...>Mataio</a> ...</p>
    // <p><b>Amabu'ulali Siföföna</b>: <a href="/wiki/Wikipedia:SN/Moze_I" ...>Moze I</a> ...</p>
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

        // href format: /wiki/Wikipedia:SN/Mataio or Wikipedia:SN/Mataio
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
  /// (e.g. "Wikipedia:SN/Mareko"). If single chapter (like Obadia/Filemo), defaults to [1].
  Future<List<int>> fetchBookChapters(String bookName) async {
    final cleanBook = bookName.trim().replaceAll(' ', '_').replaceFirst('Wikipedia:SN/', '');
    final pageTitle = 'Wikipedia:SN/$cleanBook';

    final uri = WikiConfig.actionApiUri(WikiConfig.wikipediaHost, {
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

  /// Fetches a specific chapter's content (e.g. "Wikipedia:SN/Mareko/3").
  /// Checks local database first for instant offline access.
  /// Extracts footnotes for interactive bottom sheet display.
  Future<BibleChapterContent> fetchChapterContent({
    required String bookName,
    required int chapter,
    AppDatabase? database,
    bool forceRefresh = false,
  }) async {
    final cleanBook = bookName.trim().replaceAll(' ', '_').replaceFirst('Wikipedia:SN/', '');
    final displayName = cleanBook.replaceAll('_', ' ');

    // 1. If not forcing online refresh and database is available, check local offline database first
    if (!forceRefresh && database != null) {
      final cachedVerses = await database.getBibleChapterVerses(displayName, chapter);
      if (cachedVerses.isNotEmpty) {
        return buildChapterFromCachedVerses(
          book: displayName,
          chapter: chapter,
          verses: cachedVerses,
        );
      }
    }

    final pageTitle = 'Wikipedia:SN/$cleanBook/$chapter';

    final uri = WikiConfig.actionApiUri(WikiConfig.wikipediaHost, {
      'action': 'parse',
      'page': pageTitle,
      'prop': 'text',
      'redirects': '1',
    });

    final response = await _client.get(uri, headers: WikiConfig.headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to load $displayName $chapter (HTTP ${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json.containsKey('error')) {
      final errorInfo = json['error']?['info'] ?? json['error'].toString();
      throw Exception('Wikimedia API error: $errorInfo');
    }

    final parseData = json['parse'] as Map<String, dynamic>?;
    final int? pageId = parseData?['pageid'] as int?;
    final rawHtml = parseData?['text']?['*'] as String? ?? '';

    // If database is provided, cache scraped verses in background
    if (database != null && rawHtml.isNotEmpty) {
      try {
        final parsedCompanions = parseBibleChapterPage(
          htmlText: rawHtml,
          book: displayName,
          chapter: chapter,
          category: displayName.contains('Mataio') || displayName.contains('Mareko') || displayName.contains('Luka') || displayName.contains('Yohane') ? 'NT' : 'OT',
          pageId: pageId,
        );
        if (parsedCompanions.isNotEmpty) {
          await (database.delete(database.bibles)
                ..where((t) => t.book.equals(displayName) & t.chapter.equals(chapter)))
              .go();
          await database.batch((b) {
            b.insertAll(database.bibles, parsedCompanions);
          });
        }
      } catch (_) {}
    }

    return processChapterHtml(
      book: displayName,
      chapter: chapter,
      rawHtml: rawHtml,
    );
  }

  /// Builds a [BibleChapterContent] directly from locally cached [Bible] rows for zero-latency offline viewing.
  static BibleChapterContent buildChapterFromCachedVerses({
    required String book,
    required int chapter,
    required List<Bible> verses,
  }) {
    final htmlBuffer = StringBuffer();
    final List<ArticleFootnote> footnotes = [];
    int fnCounter = 1;

    for (final v in verses) {
      final vNum = v.verse;
      var text = v.textContent;

      // Collect footnote references
      final refHtml = StringBuffer();
      if (v.reference != null && v.reference!.isNotEmpty) {
        for (final refText in v.reference!) {
          final fnId = 'cite_note-${vNum}_$fnCounter';
          footnotes.add(ArticleFootnote(
            index: fnCounter,
            id: fnId,
            text: refText,
          ));
          refHtml.write(' <sup id="cite_ref-${vNum}_$fnCounter" class="reference"><a href="#$fnId">[$fnCounter]</a></sup>');
          fnCounter++;
        }
      }

      // If text contains paragraph breaks
      if (text.contains('\n\n')) {
        final paragraphs = text.split('\n\n');
        for (int pIdx = 0; pIdx < paragraphs.length; pIdx++) {
          final pText = paragraphs[pIdx].trim();
          if (pIdx == 0) {
            htmlBuffer.writeln(
              '<p><span class="anchor" id="$vNum"><span class="verse-num"><b>$vNum</b></span></span> $pText${refHtml.toString()}</p>',
            );
          } else {
            htmlBuffer.writeln('<p>$pText</p>');
          }
        }
      } else {
        htmlBuffer.writeln(
          '<p><span class="anchor" id="$vNum"><span class="verse-num"><b>$vNum</b></span></span> $text${refHtml.toString()}</p>',
        );
      }
    }

    return BibleChapterContent(
      book: book,
      chapter: chapter,
      html: htmlBuffer.toString(),
      footnotes: footnotes,
    );
  }

  /// Processes raw MediaWiki chapter HTML:
  /// 1. Cuts off "Fabaliŵa lala" / "Fabaliwa lala" / "Bale zato" section and all subsequent siblings until end of page.
  /// 2. Hides/removes "Famotokhi ba gahe" (Footnotes) subheading since footnotes are handled via bottom sheets.
  /// 3. Extracts structured footnotes and cleans clutter using HtmlProcessor.
  /// Processes raw MediaWiki chapter HTML:
  /// 1. Extracts structured footnotes.
  /// 2. Ignores everything from subheading "Famotokhi ba gahe" until the end of the page.
  static BibleChapterContent processChapterHtml({
    required String book,
    required int chapter,
    required String rawHtml,
  }) {
    // 1. Process with HtmlProcessor first to extract structured footnotes from references/reflist
    final processed = const HtmlProcessor().process(
      rawContent: rawHtml,
      defaultTitle: '$book $chapter',
      hideHeroImageInBody: false,
    );

    // 2. Parse the processed HTML and ignore everything from "Famotokhi ba gahe" until the end of the page
    final doc = html_parser.parse(processed.html);
    final container = doc.body ?? doc.documentElement!;

    final headings = container.querySelectorAll('h1, h2, h3, h4, h5, h6');
    for (final h in headings) {
      final text = h.text.trim().toLowerCase();
      final id = (h.attributes['id'] ?? '').toLowerCase();
      if (text.contains('famotokhi ba gahe') ||
          text.contains('famotokhi') ||
          id.contains('famotokhi') ||
          text.contains('fabaliŵa lala') ||
          text.contains('fabaliwa lala') ||
          id.startsWith('fabaliwa') ||
          id.startsWith('fabali.c5.b5a') ||
          id.startsWith('fabali_') ||
          text.contains('bale zato') ||
          id.startsWith('bale_zato')) {
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

    // Also remove any remaining trailing paragraphs containing navigation text
    for (final p in container.querySelectorAll('p')) {
      final t = p.text.trim().toLowerCase();
      if (t.contains("amabu'ulali sibohou") ||
          t.startsWith('bale zato:') ||
          t.contains('bale zato:') ||
          (t.contains('sura ') && t.contains('•'))) {
        p.remove();
      }
    }

    return BibleChapterContent(
      book: book,
      chapter: chapter,
      html: container.innerHtml.trim(),
      footnotes: processed.footnotes,
    );
  }
}
