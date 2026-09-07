// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../utils/proverbs_parser.dart' as amaedola_scraper;
import '../utils/bible_parser.dart' as bible_scraper;
import '../utils/songs_parser.dart' as song_scraper;
import '../utils/stories_parser.dart' as mano_mano_scraper;
import '../utils/writings_parser.dart' as article_scraper;
import '../utils/epic_parser.dart' as hoho_scraper;
import '../utils/heritage_article_parser.dart' as heritage_scraper;

class ChangedPageInfo {
  final int pageId;
  final String pageTitle;
  final String pageType; // 'amaedola', 'bible', 'song', 'mano_mano', 'article', 'hoho', 'heritage'
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
  final AppDatabase db;
  final http.Client _client;

  WikiSyncService(this.db, {http.Client? client}) : _client = client ?? http.Client();

  /// Step 1: Query online revision IDs for all pages in local database and compare with stored local revision IDs.
  /// Returns a list of pages that have changed online.
  Future<List<ChangedPageInfo>> checkChangedPages({
    void Function(String status)? onStatus,
  }) async {
    onStatus?.call('Collecting page IDs from local database...');

    // Load local revisions map: page_id -> last_revid
    final storedRevisions = await db.select(db.wikiPageRevisions).get();
    final Map<int, int> localRevIdMap = {
      for (final r in storedRevisions) r.pageId: r.lastRevid,
    };

    // Collect distinct Amaedola pages: pageId -> pageTitle
    final amaedolaRows = await db.select(db.amaedolas).get();
    final Map<int, ({String title, String letter})> amaedolaPages = {};
    for (final a in amaedolaRows) {
      if (!amaedolaPages.containsKey(a.pageId)) {
        final letter = a.url?.split('/').last ?? a.label;
        amaedolaPages[a.pageId] = (
          title: 'Amaedola/$letter',
          letter: letter,
        );
      }
    }

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

    // Collect distinct Manö-Manö pages
    final manoManoRows = await db.select(db.manoManos).get();
    final Map<int, ({String title})> manoManoPages = {};
    for (final m in manoManoRows) {
      if (!manoManoPages.containsKey(m.pageId)) {
        manoManoPages[m.pageId] = (
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

    // Collect distinct Hoho pages
    final hohoRows = await db.select(db.hohos).get();
    final Map<int, ({String title})> hohoPages = {};
    for (final h in hohoRows) {
      if (!hohoPages.containsKey(h.pageId)) {
        hohoPages[h.pageId] = (
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
      }
    }

    // Map all tracked wiki page revision types from storedRevisions table
    final Map<int, WikiPageRevision> storedRevisionMap = {
      for (final r in storedRevisions) r.pageId: r,
    };

    final List<ChangedPageInfo> changedPages = [];

    // Separate Incubator pages from other Wiki hosts (e.g. nia.wikipedia.org)
    // Amaedola repository moved to nia.wikipedia.org (no Wb/nia/ prefix).
    // Bible, songs, stories, writings, and epic remain on Wikimedia Incubator (Wb/nia/ prefix).
    final incubatorPageIds = <int>{
      ...biblePages.keys,
      ...songPages.keys,
      ...manoManoPages.keys,
      ...articlePages.keys,
      ...hohoPages.keys,
      ...storedRevisionMap.entries
          .where((e) => e.value.pageType != 'heritage' && e.value.pageType != 'amaedola')
          .map((e) => e.key),
    }.toList();

    final heritagePageIds = <int>{
      ...heritagePages.keys,
      ...storedRevisionMap.entries.where((e) => e.value.pageType == 'heritage').map((e) => e.key),
    }.toList();

    // Amaedola titles on Nias Wikipedia
    final amaedolaTitles = amaedolaPages.values.map((e) => e.title).toSet().toList();
    if (amaedolaTitles.isEmpty) {
      const standardLetters = ['A', 'B', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'O', 'Ö', 'R', 'S', 'T', 'U', 'W', 'Y', 'Z'];
      for (final letter in standardLetters) {
        amaedolaTitles.add('Amaedola/$letter');
      }
    }

    final totalPagesCount = incubatorPageIds.length + heritagePageIds.length + amaedolaTitles.length;
    onStatus?.call('Checking $totalPagesCount pages online for revisions...');

    // Helper to query revisions from a specific wiki host by pageids
    Future<void> queryHostRevisions(List<int> pageIds, String host, bool isHeritage) async {
      const chunkSize = 50;
      for (int i = 0; i < pageIds.length; i += chunkSize) {
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
            'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
          });

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
                    if (isHeritage && heritagePages.containsKey(pageId)) {
                      final info = heritagePages[pageId]!;
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title.isNotEmpty ? title : info.title,
                        pageType: 'heritage',
                        wikiHost: info.wikiHost,
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                        category: info.category,
                      ));
                    } else if (biblePages.containsKey(pageId)) {
                      final info = biblePages[pageId]!;
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title,
                        pageType: 'bible',
                        wikiHost: 'incubator.wikimedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                        book: info.book,
                        chapter: info.chapter,
                        category: info.category,
                      ));
                    } else if (songPages.containsKey(pageId)) {
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
                    } else if (manoManoPages.containsKey(pageId)) {
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title,
                        pageType: 'mano_mano',
                        wikiHost: 'incubator.wikimedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                      ));
                    } else if (articlePages.containsKey(pageId)) {
                      final info = articlePages[pageId]!;
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title,
                        pageType: 'article',
                        wikiHost: 'incubator.wikimedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
                        category: info.category,
                      ));
                    } else if (hohoPages.containsKey(pageId)) {
                      changedPages.add(ChangedPageInfo(
                        pageId: pageId,
                        pageTitle: title,
                        pageType: 'hoho',
                        wikiHost: 'incubator.wikimedia.org',
                        onlineRevid: onlineRevid,
                        localRevid: localRevid,
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
      await queryHostRevisions(incubatorPageIds, 'incubator.wikimedia.org', false);
    }

    if (heritagePageIds.isNotEmpty) {
      await queryHostRevisions(heritagePageIds, 'nia.wikipedia.org', true);
    }

    // Query Amaedola revisions by titles on nia.wikipedia.org (no Wb/nia/ prefix)
    if (amaedolaTitles.isNotEmpty) {
      const chunkSize = 50;
      for (int i = 0; i < amaedolaTitles.length; i += chunkSize) {
        final chunk = amaedolaTitles.sublist(
          i,
          (i + chunkSize > amaedolaTitles.length) ? amaedolaTitles.length : i + chunkSize,
        );
        final titlesParam = chunk.map(Uri.encodeComponent).join('|');
        final apiUrl = Uri.parse(
          'https://nia.wikipedia.org/w/api.php?action=query&titles=$titlesParam&prop=revisions&rvprop=ids|timestamp&format=json',
        );

        try {
          final response = await _client.get(apiUrl, headers: {
            'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
          });

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
                      pageType: 'amaedola',
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
          print('Error querying Amaedola revisions from nia.wikipedia.org chunk starting at $i: $e');
        }
      }
    }

    return changedPages;
  }

  /// Step 2: Scrape updated contents for the list of changed pages and update database tables.
  Future<int> updateChangedPages(
    List<ChangedPageInfo> changedList, {
    void Function(int current, int total, String status)? onProgress,
  }) async {
    if (changedList.isEmpty) return 0;

    int updatedCount = 0;
    int requestCount = 0;

    for (int i = 0; i < changedList.length; i++) {
      final info = changedList[i];
      onProgress?.call(i + 1, changedList.length, 'Scraping ${info.pageTitle}...');

      final host = info.wikiHost ?? ((info.pageType == 'heritage' || info.pageType == 'amaedola') ? 'nia.wikipedia.org' : 'incubator.wikimedia.org');
      final Uri apiUrl;
      if (info.pageType == 'amaedola' && info.pageTitle.isNotEmpty) {
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
          'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
        });

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final parseData = json['parse'] as Map<String, dynamic>?;

          if (parseData != null) {
            final wikitext = parseData['wikitext']?['*'] as String? ?? '';
            final htmlText = parseData['text']?['*'] as String? ?? '';
            final int resolvedPageId = parseData['pageid'] as int? ?? info.pageId;

            await db.transaction(() async {
              if (info.pageType == 'heritage') {
                final parsed = heritage_scraper.parseHeritageArticleHtml(
                  htmlText: htmlText,
                  defaultTitle: info.pageTitle,
                );

                final companion = heritage_scraper.createHeritageArticleCompanion(
                  pageId: info.pageId,
                  category: info.category ?? 'architecture',
                  pageTitle: info.pageTitle,
                  wikiHost: host,
                  parsed: parsed,
                  lastRevid: info.onlineRevid,
                );

                await (db.delete(db.heritageArticles)..where((t) => t.pageId.equals(info.pageId))).go();
                await db.into(db.heritageArticles).insertOnConflictUpdate(companion);
              } else if (info.pageType == 'amaedola' && info.letter != null) {
                final entries = amaedola_scraper.parseAmaedolaItems(
                  wikitext: wikitext,
                  htmlText: htmlText,
                  letter: info.letter!,
                );

                final pageUrl = 'https://$host/wiki/${info.pageTitle}';
                final oldIncubatorUrl = 'https://incubator.wikimedia.org/wiki/Wb/nia/${info.pageTitle}';
                await (db.delete(db.amaedolas)
                      ..where((t) =>
                          t.pageId.equals(info.pageId) |
                          t.pageId.equals(resolvedPageId) |
                          t.url.equals(pageUrl) |
                          t.url.equals(oldIncubatorUrl) |
                          (info.letter != null ? t.label.equals(info.letter!) : const Constant(false))))
                    .go();

                if (entries.isNotEmpty) {
                  final companions = entries.map((e) {
                    return AmaedolasCompanion.insert(
                      label: info.letter ?? 'Lö hadöi',
                      textContent: e['text']!,
                      meaning: e['meaning'] ?? '',
                      url: Value(pageUrl),
                      meaningId: Value(e['meaning_id']),
                      meaningEn: Value(e['meaning_en']),
                      pageId: resolvedPageId,
                    );
                  }).toList();

                  await db.batch((b) => b.insertAll(db.amaedolas, companions, mode: InsertMode.insertOrReplace));
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
              } else if (info.pageType == 'song') {
                final songEntries = song_scraper.parseSongPage(
                  wikitext: wikitext,
                  htmlText: htmlText,
                  pageId: info.pageId,
                  category: info.category ?? 'sinunö',
                );

                await (db.delete(db.songs)..where((t) => t.pageId.equals(info.pageId))).go();
                if (songEntries.isNotEmpty) {
                  await db.batch((b) => b.insertAll(db.songs, songEntries, mode: InsertMode.insertOrReplace));
                }
              } else if (info.pageType == 'mano_mano') {
                final manoEntries = mano_mano_scraper.parseManoManoPage(
                  wikitext: wikitext,
                  htmlText: htmlText,
                  pageId: info.pageId,
                );

                await (db.delete(db.manoManos)..where((t) => t.pageId.equals(info.pageId))).go();
                if (manoEntries.isNotEmpty) {
                  await db.batch((b) => b.insertAll(db.manoManos, manoEntries, mode: InsertMode.insertOrReplace));
                }
              } else if (info.pageType == 'article') {
                final articleEntries = article_scraper.parseArticlePage(
                  wikitext: wikitext,
                  htmlText: htmlText,
                  pageId: info.pageId,
                  category: info.category ?? 'general',
                );

                await (db.delete(db.articles)..where((t) => t.pageId.equals(info.pageId))).go();
                if (articleEntries.isNotEmpty) {
                  await db.batch((b) => b.insertAll(db.articles, articleEntries, mode: InsertMode.insertOrReplace));
                }
              } else if (info.pageType == 'hoho') {
                final hohoEntries = hoho_scraper.parseHohoPage(
                  wikitext: wikitext,
                  htmlText: htmlText,
                  pageId: info.pageId,
                );

                await (db.delete(db.hohos)..where((t) => t.pageId.equals(info.pageId))).go();
                if (hohoEntries.isNotEmpty) {
                  await db.batch((b) => b.insertAll(db.hohos, hohoEntries, mode: InsertMode.insertOrReplace));
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
    try {
      final host = wikiHost ?? ((pageType == 'heritage' || pageType == 'amaedola') ? 'nia.wikipedia.org' : 'incubator.wikimedia.org');

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
      if (pageType == 'amaedola' && pageTitle.isNotEmpty) {
        apiUrl = Uri.parse(
          'https://$host/w/api.php?action=query&titles=${Uri.encodeComponent(pageTitle)}&prop=revisions&rvprop=ids|timestamp&format=json',
        );
      } else {
        apiUrl = Uri.parse(
          'https://$host/w/api.php?action=query&pageids=$pageId&prop=revisions&rvprop=ids|timestamp&format=json',
        );
      }

      final response = await _client.get(apiUrl, headers: {
        'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
      });

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
}
