// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../utils/proverbs_parser.dart' as proverbs_scraper;
import '../utils/bible_parser.dart' as bible_scraper;
import '../utils/songs_parser.dart' as song_scraper;
import '../utils/stories_parser.dart' as stories_scraper;
import '../utils/writings_parser.dart' as article_scraper;
import '../utils/recitation_parser.dart' as recitation_scraper;
import '../utils/heritage_article_parser.dart' as heritage_scraper;

class ChangedPageInfo {
  final int pageId;
  final String pageTitle;
  final String pageType; // 'proverbs', 'bible', 'song', 'stories', 'article', 'recitation', 'heritage'
  final String? wikiHost; // e.g. 'nia.wikipedia.org' or 'incubator.wikimedia.org'
  final int onlineRevid;
  final int? localRevid;
  final String? book;
  final int? chapter;
  final String? category;
  final String? letter;

  ChangedPageInfo({
    required this.pageId,
    required this.pageTitle,
    required this.pageType,
    this.wikiHost,
    required this.onlineRevid,
    this.localRevid,
    this.book,
    this.chapter,
    this.category,
    this.letter,
  });

  Map<String, dynamic> toJson() => {
        'page_id': pageId,
        'page_title': pageTitle,
        'page_type': pageType,
        'wiki_host': wikiHost,
        'online_revid': onlineRevid,
        'local_revid': localRevid,
        'book': book,
        'chapter': chapter,
        'category': category,
        'letter': letter,
      };

  factory ChangedPageInfo.fromJson(Map<String, dynamic> json) => ChangedPageInfo(
        pageId: json['page_id'] as int,
        pageTitle: json['page_title'] as String,
        pageType: json['page_type'] as String,
        wikiHost: json['wiki_host'] as String?,
        onlineRevid: json['online_revid'] as int,
        localRevid: json['local_revid'] as int?,
        book: json['book'] as String?,
        chapter: json['chapter'] as int?,
        category: json['category'] as String?,
        letter: json['letter'] as String?,
      );
}

class WikiSyncService {
  static const String userAgent =
      'NiasHeritage/1.0.0 (https://sslaia.github.io/niasheritage/; contact: https://github.com/sslaia/niasheritage)';
  static const Duration requestTimeout = Duration(seconds: 15);

  final AppDatabase db;
  final http.Client _client;

  WikiSyncService(this.db, {http.Client? client}) : _client = client ?? http.Client();

  /// Step 1: Query online revision IDs for all pages in local database and compare with stored local revision IDs.
  /// Returns a list of pages that have changed online.
  Future<List<ChangedPageInfo>> checkChangedPages({
    void Function(String status)? onStatus,
    bool Function()? isCancelled,
  }) async {
    onStatus?.call('Collecting page IDs from local database...');

    // Load local revisions map: page_id -> last_revid
    final storedRevisions = await db.select(db.wikiPageRevisions).get();
    final Map<int, int> localRevIdMap = {
      for (final r in storedRevisions) r.pageId: r.lastRevid,
    };

    // Collect distinct Proverbs pages: pageId -> pageTitle
    final proverbsRows = await db.select(db.proverbs).get();
    final Map<int, ({String title, String letter})> proverbsPages = {};
    for (final a in proverbsRows) {
      if (!proverbsPages.containsKey(a.pageId)) {
        final letter = a.url?.split('/').last ?? a.label;
        proverbsPages[a.pageId] = (
          title: 'Amaedola/$letter',
          letter: letter,
        );
      }
    }

    // Note: Bible and Heritage sections are offline by design (bundled assets and pre-populated SQLite).
    // They are intentionally excluded from online checks.

    // Collect distinct Bible pages: pageId -> pageTitle
    final bibleRows = await db.select(db.bibles).get();
    final Map<int, ({String title, String book, int chapter, String category})> biblePages = {};
    for (final b in bibleRows) {
      if (!biblePages.containsKey(b.pageId)) {
        biblePages[b.pageId] = (
          title: 'Wb/nia/${b.book}/${b.chapter}',
          book: b.book,
          chapter: b.chapter,
          category: b.category,
        );
      }
    }

    // Collect distinct Song pages
    final songRows = await db.select(db.songs).get();
    final Map<int, ({String title, String category})> songPages = {};
    for (final s in songRows) {
      if (!songPages.containsKey(s.pageId)) {
        songPages[s.pageId] = (
          title: 'Wb/nia/${s.title}',
          category: s.category,
        );
      }
    }

    // Collect distinct Stories pages
    final storiesRows = await db.select(db.stories).get();
    final Map<int, ({String title})> storiesPages = {};
    for (final m in storiesRows) {
      if (!storiesPages.containsKey(m.pageId)) {
        storiesPages[m.pageId] = (
          title: 'Wb/nia/${m.title}',
        );
      }
    }

    // Collect distinct Article pages
    final articleRows = await db.select(db.articles).get();
    final Map<int, ({String title, String category})> articlePages = {};
    for (final a in articleRows) {
      if (!articlePages.containsKey(a.pageId)) {
        articlePages[a.pageId] = (
          title: 'Wb/nia/${a.title}',
          category: a.category,
        );
      }
    }

    // Collect distinct Recitation pages
    final recitationRows = await db.select(db.recitations).get();
    final Map<int, ({String title})> recitationPages = {};
    for (final h in recitationRows) {
      if (!recitationPages.containsKey(h.pageId)) {
        recitationPages[h.pageId] = (
          title: 'Wb/nia/${h.title}',
        );
      }
    }

    // Collect distinct Heritage Article pages
    final heritageRows = await db.select(db.heritageArticles).get();
    final Map<int, ({String title, String category, String wikiHost})> heritagePages = {};
    for (final h in heritageRows) {
      if (!heritagePages.containsKey(h.pageId)) {
        heritagePages[h.pageId] = (
          title: h.pageTitle,
          category: h.category,
          wikiHost: h.wikiHost,
        );
        // Fall back to heritage_articles.lastRevid if not in wiki_page_revisions
        if (!localRevIdMap.containsKey(h.pageId)) {
          localRevIdMap[h.pageId] = h.lastRevid;
        }
      }
    }

    // Map all tracked wiki page revision types from storedRevisions table (excluding bible and heritage)
    final Map<int, WikiPageRevision> storedRevisionMap = {
      for (final r in storedRevisions)
        if (r.pageType != 'heritage' && r.pageType != 'bible') r.pageId: r,
    };

    final List<ChangedPageInfo> changedPages = [];

    final featuredArticlePageIds = <int>{
      ...articlePages.entries.where((e) => e.value.category == 'featured').map((e) => e.key),
      ...storedRevisionMap.entries
          .where((e) => e.value.pageType == 'featured_article')
          .map((e) => e.key),
    }.toList();

    // Separate Incubator pages for songs, stories, writings, and recitation (Wb/nia/ prefix)
    final incubatorPageIds = <int>{
      ...songPages.keys,
      ...storiesPages.keys,
      ...articlePages.entries.where((e) => e.value.category != 'featured').map((e) => e.key),
      ...recitationPages.keys,
      ...storedRevisionMap.entries
          .where((e) =>
              e.value.pageType != 'heritage' &&
              e.value.pageType != 'proverbs' &&
              e.value.pageType != 'amaedola' &&
              e.value.pageType != 'bible' &&
              e.value.pageType != 'featured_article')
          .map((e) => e.key),
    }.toList();

    // Proverbs titles on Nias Wikipedia
    final proverbsTitles = proverbsPages.values.map((e) => e.title).toSet().toList();
    if (proverbsTitles.isEmpty) {
      const standardLetters = ['A', 'B', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'O', 'Ö', 'R', 'S', 'T', 'U', 'W', 'Y', 'Z'];
      for (final letter in standardLetters) {
        proverbsTitles.add('Amaedola/$letter');
      }
    }

    final totalPagesCount = incubatorPageIds.length + proverbsTitles.length + heritagePages.length + featuredArticlePageIds.length;
    onStatus?.call('$totalPagesCount');

    // Helper to query revisions from a specific wiki host by pageids
    Future<void> queryHostRevisions(List<int> pageIds, String host) async {
      const chunkSize = 50;
      for (int i = 0; i < pageIds.length; i += chunkSize) {
        if (isCancelled?.call() == true) return;
        final chunk = pageIds.sublist(
          i,
          (i + chunkSize > pageIds.length) ? pageIds.length : i + chunkSize,
        );
        final pageIdsParam = chunk.join('|');
        final apiUrl = Uri.parse(
          'https://$host/w/api.php?action=query&pageids=$pageIdsParam&prop=revisions&rvprop=ids|timestamp&format=json',
        );

        try {
          final response = await _client.get(apiUrl, headers: {
            'User-Agent': userAgent,
          }).timeout(requestTimeout);

          if (response.statusCode == 200) {
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            final pagesObj = json['query']?['pages'] as Map<String, dynamic>?;

            if (pagesObj != null) {
              for (final page in pagesObj.values) {
                if (page is Map<String, dynamic>) {
                  if (page.containsKey('missing')) continue;
                  final int? pageId = page['pageid'] as int?;
                  final String title = page['title'] as String? ?? '';
                  final revisions = page['revisions'] as List<dynamic>?;
                  if (pageId == null || revisions == null || revisions.isEmpty) continue;

                  final int onlineRevid = revisions[0]['revid'] as int? ?? 0;
                  final int? localRevid = localRevIdMap[pageId];

                  // If page revision is newer online (or not yet stored locally), add to changed list
                  if (localRevid == null || onlineRevid > localRevid) {
                    if (songPages.containsKey(pageId)) {
                      final info = songPages[pageId]!;
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title,
                        pageType: 'song',
                        wikiHost: 'incubator.wikimedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                        category: info.category,
                      ));
                    } else if (storiesPages.containsKey(pageId)) {
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title,
                        pageType: 'stories',
                        wikiHost: 'incubator.wikimedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                      ));
                    } else if (articlePages.containsKey(pageId)) {
                      final info = articlePages[pageId]!;
                      final isFeatured = info.category == 'featured';
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title,
                        pageType: isFeatured ? 'featured_article' : 'article',
                        wikiHost: isFeatured ? 'nia.wikipedia.org' : 'incubator.wikimedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                        category: info.category,
                      ));
                    } else if (recitationPages.containsKey(pageId)) {
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title,
                        pageType: 'recitation',
                        wikiHost: 'incubator.wikimedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                      ));
                    } else if (heritagePages.containsKey(pageId)) {
                      final info = heritagePages[pageId]!;
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title.isNotEmpty ? title : info.title,
                        pageType: 'heritage',
                        wikiHost: 'nia.wikipedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                        category: info.category,
                      ));
                    } else if (storedRevisionMap.containsKey(pageId)) {
                      final rev = storedRevisionMap[pageId]!;
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title.isNotEmpty ? title : rev.pageTitle,
                        pageType: rev.pageType,
                        wikiHost: host,
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                      ));
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error querying page revisions from $host chunk starting at $i: $e');
        }
      }
    }

    if (incubatorPageIds.isNotEmpty) {
      await queryHostRevisions(incubatorPageIds, 'incubator.wikimedia.org');
    }

    if (featuredArticlePageIds.isNotEmpty) {
      await queryHostRevisions(featuredArticlePageIds, 'nia.wikipedia.org');
    }

    final heritagePageIds = heritagePages.keys.toList();
    if (heritagePageIds.isNotEmpty) {
      await queryHostRevisions(heritagePageIds, 'nia.wikipedia.org');
    }

    // Query Proverbs revisions by titles on nia.wikipedia.org (no Wb/nia/ prefix)
    if (proverbsTitles.isNotEmpty) {
      const chunkSize = 50;
      for (int i = 0; i < proverbsTitles.length; i += chunkSize) {
        if (isCancelled?.call() == true) break;
        final chunk = proverbsTitles.sublist(
          i,
          (i + chunkSize > proverbsTitles.length) ? proverbsTitles.length : i + chunkSize,
        );
        final titlesParam = chunk.map(Uri.encodeComponent).join('|');
        final apiUrl = Uri.parse(
          'https://nia.wikipedia.org/w/api.php?action=query&titles=$titlesParam&prop=revisions&rvprop=ids|timestamp&format=json',
        );

        try {
          final response = await _client.get(apiUrl, headers: {
            'User-Agent': userAgent,
          }).timeout(requestTimeout);

          if (response.statusCode == 200) {
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            final pagesObj = json['query']?['pages'] as Map<String, dynamic>?;

            if (pagesObj != null) {
              for (final page in pagesObj.values) {
                if (page is Map<String, dynamic>) {
                  if (page.containsKey('missing')) continue;
                  final int? pageId = page['pageid'] as int?;
                  final String title = page['title'] as String? ?? '';
                  final revisions = page['revisions'] as List<dynamic>?;
                  if (pageId == null || revisions == null || revisions.isEmpty) continue;

                  final int onlineRevid = revisions[0]['revid'] as int? ?? 0;
                  final int? localRevid = localRevIdMap[pageId];
                  final letter = title.split('/').last;

                  if (localRevid == null || onlineRevid > localRevid) {
                    changedPages.add(ChangedPageInfo(
                      pageId: pageId,
                      pageTitle: title,
                      pageType: 'proverbs',
                      wikiHost: 'nia.wikipedia.org',
                      onlineRevid: onlineRevid,
                      localRevid: localRevid,
                      letter: letter,
                    ));
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error querying Proverbs revisions from nia.wikipedia.org chunk starting at $i: $e');
        }
      }
    }

    return changedPages;
  }

  /// Step 2: Scrape updated contents for the list of changed pages and update database tables.
  Future<int> updateChangedPages(
    List<ChangedPageInfo> changedList, {
    void Function(int current, int total, String status)? onProgress,
    bool Function()? isCancelled,
  }) async {
    if (changedList.isEmpty) return 0;

    int updatedCount = 0;
    int requestCount = 0;

    for (int i = 0; i < changedList.length; i++) {
      if (isCancelled?.call() == true) {
        break;
      }
      final info = changedList[i];
      onProgress?.call(i + 1, changedList.length, info.pageTitle);

      final host = info.wikiHost ?? ((info.pageType == 'heritage' || info.pageType == 'proverbs' || info.pageType == 'amaedola') ? 'nia.wikipedia.org' : 'incubator.wikimedia.org');
      final Uri apiUrl;
      if ((info.pageType == 'proverbs' || info.pageType == 'amaedola') && info.pageTitle.isNotEmpty) {
        apiUrl = Uri.parse(
          'https://$host/w/api.php?action=parse&page=${Uri.encodeComponent(info.pageTitle)}&format=json&prop=text|wikitext',
        );
      } else {
        apiUrl = Uri.parse(
          'https://$host/w/api.php?action=parse&pageid=${info.pageId}&format=json&prop=text|wikitext',
        );
      }

      try {
        requestCount++;
        final response = await _client.get(apiUrl, headers: {
          'User-Agent': userAgent,
        }).timeout(requestTimeout);

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final parseObj = json['parse'] as Map<String, dynamic>?;

          if (parseObj != null) {
            final int resolvedPageId = parseObj['pageid'] as int? ?? info.pageId;
            final textObj = parseObj['text'] as Map<String, dynamic>?;
            final wikitextObj = parseObj['wikitext'] as Map<String, dynamic>?;

            final htmlText = textObj?['*'] as String? ?? '';
            final wikitext = wikitextObj?['*'] as String? ?? '';

            if (htmlText.isNotEmpty || wikitext.isNotEmpty) {
              await db.transaction(() async {
                if (info.pageType == 'heritage') {
                  final parsed = heritage_scraper.parseHeritageArticleHtml(
                    htmlText: htmlText,
                    defaultTitle: info.pageTitle,
                  );

                  final companion = HeritageArticlesCompanion(
                    pageId: Value(resolvedPageId),
                    category: Value(info.category ?? 'architecture'),
                    wikiHost: Value(host),
                    pageTitle: Value(info.pageTitle),
                    title: Value(parsed.title.isNotEmpty ? parsed.title : info.pageTitle),
                    textContent: Value(parsed.textContent),
                    htmlContent: Value(parsed.htmlContent ?? htmlText),
                    footnotes: Value(jsonEncode(parsed.footnotes.map((f) => f.toJson()).toList())),
                    imageUrl: Value(parsed.imageUrl),
                    lastRevid: Value(info.onlineRevid),
                    lastUpdated: Value(DateTime.now()),
                  );

                  await (db.delete(db.heritageArticles)..where((t) => t.pageId.equals(resolvedPageId))).go();
                  await db.into(db.heritageArticles).insertOnConflictUpdate(companion);
                } else if ((info.pageType == 'proverbs' || info.pageType == 'amaedola') && info.letter != null) {
                  final entries = proverbs_scraper.parseProverbsItems(
                    wikitext: wikitext,
                    htmlText: htmlText,
                    letter: info.letter!,
                  );

                  final pageUrl = 'https://$host/wiki/${info.pageTitle}';
                  final oldIncubatorUrl = 'https://incubator.wikimedia.org/wiki/Wb/nia/${info.pageTitle}';
                  await (db.delete(db.proverbs)
                        ..where((t) => t.url.equals(pageUrl) | t.url.equals(oldIncubatorUrl)))
                      .go();
                  if (entries.isNotEmpty) {
                    final companions = entries.map((e) {
                      return ProverbsCompanion.insert(
                        label: info.letter ?? 'Lö hadöi',
                        textContent: e['text']!,
                        meaning: e['meaning'] ?? '',
                        url: Value(pageUrl),
                        meaningId: Value(e['meaning_id']),
                        meaningEn: Value(e['meaning_en']),
                        pageId: resolvedPageId,
                      );
                    }).toList();

                    await db.batch((b) => b.insertAll(db.proverbs, companions, mode: InsertMode.insertOrReplace));
                  }
                } else if (info.pageType == 'bible' && info.book != null && info.chapter != null && info.category != null) {
                  final verses = bible_scraper.parseBibleChapterPage(
                    htmlText: htmlText,
                    book: info.book!,
                    chapter: info.chapter!,
                    category: info.category!,
                    pageId: info.pageId,
                  );

                  await (db.delete(db.bibles)
                        ..where((t) => t.pageId.equals(info.pageId) | (t.book.equals(info.book!) & t.chapter.equals(info.chapter!))))
                      .go();

                  if (verses.isNotEmpty) {
                    await db.batch((b) => b.insertAll(db.bibles, verses, mode: InsertMode.insertOrReplace));
                  }
                } else if (info.pageType == 'song' || info.pageType == 'sinuno') {
                  final songEntries = song_scraper.parseSongsPage(
                    wikitext: wikitext,
                    htmlText: htmlText,
                    pageId: info.pageId,
                    category: info.category ?? 'sinunö',
                    pageTitle: info.pageTitle,
                    url: 'https://$host/wiki/${info.pageTitle}',
                  );

                  await (db.delete(db.songs)..where((t) => t.pageId.equals(info.pageId))).go();
                  if (songEntries.isNotEmpty) {
                    await db.batch((b) => b.insertAll(db.songs, songEntries, mode: InsertMode.insertOrReplace));
                  }
                } else if (info.pageType == 'stories' || info.pageType == 'mano_mano') {
                  final storyEntries = stories_scraper.parseStoriesPage(
                    wikitext: wikitext,
                    htmlText: htmlText,
                    pageId: info.pageId,
                    pageTitle: info.pageTitle,
                    url: 'https://$host/wiki/${info.pageTitle}',
                  );

                  await (db.delete(db.stories)..where((t) => t.pageId.equals(info.pageId))).go();
                  if (storyEntries.isNotEmpty) {
                    await db.batch((b) => b.insertAll(db.stories, storyEntries, mode: InsertMode.insertOrReplace));
                  }
                } else if (info.pageType == 'article' ||
                    info.pageType == 'writings' ||
                    info.pageType == 'sinura' ||
                    info.pageType == 'featured_article') {
                  final articleEntries = article_scraper.parseArticlePage(
                    wikitext: wikitext,
                    htmlText: htmlText,
                    pageId: info.pageId,
                    category: info.category ?? (info.pageType == 'featured_article' ? 'featured' : 'general'),
                    pageTitle: info.pageTitle,
                    url: 'https://$host/wiki/${info.pageTitle}',
                  );

                  await (db.delete(db.articles)..where((t) => t.pageId.equals(info.pageId))).go();
                  if (articleEntries.isNotEmpty) {
                    await db.batch((b) => b.insertAll(db.articles, articleEntries, mode: InsertMode.insertOrReplace));
                  }
                } else if (info.pageType == 'recitation' || info.pageType == 'hoho') {
                  final recitationEntries = recitation_scraper.parseRecitationPage(
                    wikitext: wikitext,
                    htmlText: htmlText,
                    pageId: info.pageId,
                    pageTitle: info.pageTitle,
                    url: 'https://$host/wiki/${info.pageTitle}',
                  );

                  await (db.delete(db.recitations)..where((t) => t.pageId.equals(info.pageId))).go();
                  if (recitationEntries.isNotEmpty) {
                    await db.batch((b) => b.insertAll(db.recitations, recitationEntries, mode: InsertMode.insertOrReplace));
                  }
                }

                // Update or insert WikiPageRevision record
                await db.into(db.wikiPageRevisions).insertOnConflictUpdate(
                      WikiPageRevision(
                        pageId: resolvedPageId,
                        lastRevid: info.onlineRevid,
                        pageTitle: info.pageTitle,
                        pageType: info.pageType,
                        lastUpdated: DateTime.now(),
                      ),
                    );
              });

            updatedCount++;
          }
        }
      }

        // Polite pacing: 300ms pause between single-page parse requests
        await Future.delayed(const Duration(milliseconds: 300));

        // Server Care: Pause 2 seconds after every 10 requests
        if (requestCount % 10 == 0 && i + 1 < changedList.length) {
          onProgress?.call(i + 1, changedList.length, 'Pausing 2s to care for Wikimedia server...');
          await Future.delayed(const Duration(seconds: 2));
        }
      } catch (e) {
        print('Error updating page ${info.pageTitle} (Page ID ${info.pageId}): $e');
      }
    }

    // Synchronize sqlite assets if running locally
    try {
      final dbFile = File('niasheritage.sqlite');
      final assetFile = File('assets/niasheritage.sqlite');
      if (await dbFile.exists()) {
        await dbFile.copy(assetFile.path);
      }
    } catch (_) {}

    return updatedCount;
  }

  /// Step 5: Fast background check for a single opened page.
  /// Re-scrapes and updates DB if online revision is newer. Returns true if updated.
  Future<bool> checkAndUpdateSinglePage({
    required int pageId,
    required String pageTitle,
    required String pageType,
    String? wikiHost,
    String? letter,
    String? book,
    int? chapter,
    String? category,
  }) async {
    // Offline by design: Bible is permanently bundled and never checked online.
    if (pageType == 'bible') {
      return false;
    }

    try {
      final host = wikiHost ?? ((pageType == 'heritage' || pageType == 'proverbs' || pageType == 'amaedola' || pageType == 'featured_article') ? 'nia.wikipedia.org' : 'incubator.wikimedia.org');

      // 1. Get stored revision for this page (by pageId or pageTitle)
      WikiPageRevision? localRecord;
      final recordByPageId = await (db.select(db.wikiPageRevisions)..where((t) => t.pageId.equals(pageId))).getSingleOrNull();
      if (recordByPageId != null) {
        localRecord = recordByPageId;
      } else {
        localRecord = await (db.select(db.wikiPageRevisions)..where((t) => t.pageTitle.equals(pageTitle))).getSingleOrNull();
      }

      // 2. Query online revision ID
      final Uri apiUrl;
      if ((pageType == 'proverbs' || pageType == 'amaedola') && pageTitle.isNotEmpty) {
        apiUrl = Uri.parse(
          'https://$host/w/api.php?action=query&titles=${Uri.encodeComponent(pageTitle)}&prop=revisions&rvprop=ids|timestamp&format=json',
        );
      } else {
        apiUrl = Uri.parse(
          'https://$host/w/api.php?action=query&pageids=$pageId&prop=revisions&rvprop=ids|timestamp&format=json',
        );
      }

      final response = await _client.get(apiUrl, headers: {
        'User-Agent': userAgent,
      }).timeout(requestTimeout);

      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final pagesObj = json['query']?['pages'] as Map<String, dynamic>?;
      final pageData = pagesObj?.values.firstOrNull as Map<String, dynamic>?;
      if (pageData == null || pageData.containsKey('missing')) return false;

      final int onlinePageId = pageData['pageid'] as int? ?? pageId;
      final revisions = pageData['revisions'] as List<dynamic>?;
      if (revisions == null || revisions.isEmpty) return false;

      final int onlineRevid = revisions[0]['revid'] as int? ?? 0;

      // 3. Compare online revid vs local revid
      if (localRecord == null || onlineRevid > localRecord.lastRevid) {
        final sanitizedTitle = pageTitle.trim().replaceAll(' ', '_');
        print('[AutoSync] Page $onlinePageId ($sanitizedTitle) has newer online revision ($onlineRevid vs local ${localRecord?.lastRevid}). Updating...');

        final updateInfo = ChangedPageInfo(
          pageId: onlinePageId,
          pageTitle: sanitizedTitle,
          pageType: pageType,
          wikiHost: host,
          onlineRevid: onlineRevid,
          localRevid: localRecord?.lastRevid,
          letter: letter,
          book: book,
          chapter: chapter,
          category: category,
        );

        await updateChangedPages([updateInfo]);
        return true;
      }
    } catch (e) {
      print('[AutoSync] Error checking single page $pageId: $e');
    }
    return false;
  }

  /// Discovers and returns page info for members of a category (and its subcategories)
  /// on Wikimedia Incubator or Wikipedia so new library items (songs, stories, articles, hoho)
  /// can be fetched and stored offline.
  Future<List<ChangedPageInfo>> discoverCategoryPages({
    required String categoryTitle,
    required String pageType,
    String wikiHost = 'incubator.wikimedia.org',
    int maxDepth = 3,
    bool force = false,
    bool Function()? isCancelled,
  }) async {
    final storedRevisions = await db.select(db.wikiPageRevisions).get();
    final Map<int, int> localRevIdMap = {
      for (final r in storedRevisions) r.pageId: r.lastRevid,
    };

    final List<ChangedPageInfo> result = [];
    final visitedCategories = <String>{};
    final categoryQueue = <({String catTitle, int depth, String? subcatLabel})>[
      (catTitle: categoryTitle, depth: 0, subcatLabel: null),
    ];
    final Map<int, ({String title, String? categoryLabel})> discoveredPages = {};

    while (categoryQueue.isNotEmpty) {
      if (isCancelled?.call() == true) return [];
      final current = categoryQueue.removeAt(0);
      final normalizedCat = current.catTitle.trim();
      if (visitedCategories.contains(normalizedCat)) continue;
      visitedCategories.add(normalizedCat);

      String? cmcontinue;
      do {
        if (isCancelled?.call() == true) return [];

        final queryParams = <String, String>{
          'action': 'query',
          'list': 'categorymembers',
          'cmtitle': normalizedCat,
          'cmlimit': '500',
          'cmprop': 'ids|title',
          'format': 'json',
        };
        if (cmcontinue != null && cmcontinue.isNotEmpty) {
          queryParams['cmcontinue'] = cmcontinue;
        }

        final apiUrl = Uri.https(wikiHost, '/w/api.php', queryParams);

        try {
          final response = await _client.get(apiUrl, headers: {
            'User-Agent': userAgent,
          }).timeout(requestTimeout);

          if (response.statusCode == 200) {
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            cmcontinue = json['continue']?['cmcontinue'] as String?;

            final members = json['query']?['categorymembers'] as List<dynamic>?;
            if (members != null) {
              for (final m in members) {
                if (m is Map<String, dynamic>) {
                  final int? pid = m['pageid'] as int?;
                  final String title = m['title'] as String? ?? '';
                  final int ns = m['ns'] as int? ?? 0;

                  if (pid == null) continue;

                  // Subcategory handling (namespace 14 or title starting with Category:)
                  if (ns == 14 || title.startsWith('Category:')) {
                    if (current.depth < maxDepth && !visitedCategories.contains(title)) {
                      final cleanLabel = title
                          .replaceFirst('Category:', '')
                          .replaceFirst('Wb/nia/', '')
                          .trim();
                      categoryQueue.add((catTitle: title, depth: current.depth + 1, subcatLabel: cleanLabel));
                    }
                  } else {
                    // Regular content page
                    if (!discoveredPages.containsKey(pid)) {
                      discoveredPages[pid] = (
                        title: title,
                        categoryLabel: current.subcatLabel,
                      );
                    }
                  }
                }
              }
            }
          } else {
            cmcontinue = null;
          }
        } catch (e) {
          print('Error discovering category members for $normalizedCat: $e');
          cmcontinue = null;
        }
      } while (cmcontinue != null && cmcontinue.isNotEmpty);
    }

    if (discoveredPages.isEmpty) {
      return result;
    }

    // Query online revisions for all discovered pages in chunks of 50
    final pageIds = discoveredPages.keys.toList();
    const chunkSize = 50;
    for (int i = 0; i < pageIds.length; i += chunkSize) {
      if (isCancelled?.call() == true) return [];
      final chunk = pageIds.sublist(
        i,
        (i + chunkSize > pageIds.length) ? pageIds.length : i + chunkSize,
      );
      final pageIdsParam = chunk.join('|');
      final revUrl = Uri.https(wikiHost, '/w/api.php', {
        'action': 'query',
        'pageids': pageIdsParam,
        'prop': 'revisions',
        'rvprop': 'ids|timestamp',
        'format': 'json',
      });

      try {
        final revRes = await _client.get(revUrl, headers: {
          'User-Agent': userAgent,
        }).timeout(requestTimeout);

        if (revRes.statusCode == 200) {
          final revJson = jsonDecode(revRes.body) as Map<String, dynamic>;
          final pagesObj = revJson['query']?['pages'] as Map<String, dynamic>?;
          if (pagesObj != null) {
            for (final page in pagesObj.values) {
              if (page is Map<String, dynamic>) {
                if (page.containsKey('missing')) continue;
                final int? pageId = page['pageid'] as int?;
                final revisions = page['revisions'] as List<dynamic>?;
                if (pageId == null || revisions == null || revisions.isEmpty) continue;

                final int onlineRevid = revisions[0]['revid'] as int? ?? 0;
                final int? localRevid = localRevIdMap[pageId];

                if (force || localRevid == null || onlineRevid > localRevid) {
                  final pageInfo = discoveredPages[pageId];
                  result.add(ChangedPageInfo(
                    pageId: pageId,
                    pageTitle: pageInfo?.title ?? (page['title'] as String? ?? ''),
                    pageType: pageType,
                    wikiHost: wikiHost,
                    onlineRevid: onlineRevid,
                    localRevid: localRevid,
                    category: pageInfo?.categoryLabel,
                  ));
                }
              }
            }
          }
        }
      } catch (e) {
        print('Error querying revisions for chunk: $e');
      }
    }

    return result;
  }
}
