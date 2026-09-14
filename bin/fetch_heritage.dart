// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:niasheritage/core/database/database.dart';
import 'package:niasheritage/core/services/heritage_translation_service.dart';
import 'package:niasheritage/core/utils/heritage_article_parser.dart';

void main() async {
  final sqliteFile = File('assets/niasheritage.sqlite');
  final localDbFile = File('niasheritage.sqlite');

  final db = AppDatabase.forFile(localDbFile.existsSync() ? localDbFile : sqliteFile);

  // Deduplicate by pageId (e.g. 5034 is used for both nia and id ceramah)
  final Map<int, HeritageArticleDefinition> uniqueDefinitions = {};
  for (final def in heritageArticleDefinitions) {
    if (!uniqueDefinitions.containsKey(def.pageId)) {
      uniqueDefinitions[def.pageId] = def;
    }
  }

  final client = http.Client();
  const wikiHost = 'nia.wikipedia.org';

  print('Starting fetch of ${uniqueDefinitions.length} heritage articles from $wikiHost...');

  for (final entry in uniqueDefinitions.entries) {
    final pageId = entry.key;
    final def = entry.value;
    print('\nFetching ${def.category} [$pageId] "${def.defaultPageTitle}" from $wikiHost...');

    final uri = Uri.https(
      wikiHost,
      '/w/api.php',
      {
        'action': 'parse',
        'pageid': pageId.toString(),
        'format': 'json',
        'prop': 'text|wikitext|revid|displaytitle',
      },
    );

    try {
      final response = await client.get(
        uri,
        headers: {
          'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final parseData = json['parse'] as Map<String, dynamic>?;
        if (parseData == null) {
          print('  Failed to parse data for ${def.defaultPageTitle}: ${json['error']}');
          continue;
        }

        final htmlText = parseData['text']?['*'] as String? ?? '';
        final revid = parseData['revid'] as int? ?? 0;
        final rawTitle = parseData['title'] as String? ?? def.defaultPageTitle;
        final displayTitle = parseData['displaytitle'] as String? ?? def.label;

        final parsed = parseHeritageArticleHtml(
          htmlText: htmlText,
          defaultTitle: displayTitle.isNotEmpty ? displayTitle : rawTitle,
        );

        print('  Title: ${parsed.title}');
        print('  Extracted ${parsed.footnotes.length} footnotes');
        print('  Featured image: ${parsed.imageUrl}');
        print('  Revid: $revid');

        final companion = createHeritageArticleCompanion(
          pageId: pageId,
          category: def.category,
          pageTitle: rawTitle,
          wikiHost: wikiHost,
          parsed: parsed,
          lastRevid: revid,
        );

        await (db.delete(db.heritageArticles)..where((t) => t.pageId.equals(pageId))).go();
        await db.into(db.heritageArticles).insertOnConflictUpdate(companion);

        await db.into(db.wikiPageRevisions).insertOnConflictUpdate(
          WikiPageRevision(
            pageId: pageId,
            lastRevid: revid,
            pageTitle: rawTitle,
            pageType: 'heritage',
            lastUpdated: DateTime.now(),
          ),
        );

        print('  Successfully saved [$pageId] to database!');
      } else {
        print('  Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('  Error fetching article $pageId: $e');
    }
  }

  if (localDbFile.existsSync()) {
    await localDbFile.copy(sqliteFile.path);
    print('\nCopied localDbFile to ${sqliteFile.path}');
  }

  await db.close();
  client.close();
  print('\nAll heritage articles successfully updated in database!');
}
