// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:niasheritage/core/database/database.dart';
import 'package:niasheritage/core/utils/proverbs_parser.dart';

final List<String> alphabet = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'Ö', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
];

Future<void> main([List<String> args = const []]) async {
  final forceReset = args.contains('--reset') || args.contains('--force');

  print('==================================================');
  print('Starting Proverbs Scraper (nia.wikipedia.org)');
  print('Rate limit: 2-second pause every 5 requests');
  if (forceReset) {
    print('Option: --reset enabled. Progress checkpoint will be cleared.');
  }
  print('==================================================');

  final progressFile = File('.proverbs_progress.json');
  Map<String, dynamic> progressData = {};

  if (!forceReset && await progressFile.exists()) {
    try {
      final content = await progressFile.readAsString();
      progressData = jsonDecode(content) as Map<String, dynamic>;
      print('Found existing progress file. Resuming scrape...');
    } catch (_) {
      progressData = {};
    }
  }

  // Open database connection
  final dbFile = File('niasheritage.sqlite');
  final db = AppDatabase.forFile(dbFile);

  final client = http.Client();
  int totalFetched = 0;
  int fetchedInThisRun = 0;

  for (int i = 0; i < alphabet.length; i++) {
    final letter = alphabet[i];
    final progressPercent = ((i / alphabet.length) * 100).toStringAsFixed(1);

    if (progressData.containsKey(letter) && progressData[letter]['completed'] == true) {
      final savedCount = progressData[letter]['item_count'] ?? 0;
      print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": Skipping (already processed, $savedCount items).');
      totalFetched += (savedCount as int);
      continue;
    }

    final pageTitle = 'Amaedola/$letter';
    final pageUrl = 'https://nia.wikipedia.org/wiki/$pageTitle';
    final apiUrl = Uri.parse(
      'https://nia.wikipedia.org/w/api.php?action=parse&page=${Uri.encodeComponent(pageTitle)}&format=json&prop=text|wikitext|revid',
    );

    print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": Fetching $apiUrl...');

    try {
      final response = await client.get(apiUrl, headers: {
        'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
      });

      if (response.statusCode != 200) {
        print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": HTTP ${response.statusCode}');
        continue;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json.containsKey('error')) {
        final error = json['error'];
        print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": API Error: ${error['info'] ?? error['code']}');
        continue;
      }

      final parseData = json['parse'] as Map<String, dynamic>?;
      if (parseData == null) {
        print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": Parse data is null.');
        continue;
      }

      final int? pageId = parseData['pageid'] as int?;
      final wikitext = parseData['wikitext']?['*'] as String? ?? '';
      final htmlText = parseData['text']?['*'] as String? ?? '';

      if (pageId == null) {
        print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": Missing pageid.');
        continue;
      }

      final entries = parseProverbsItems(
        wikitext: wikitext,
        htmlText: htmlText,
        letter: letter,
      );

      if (entries.isEmpty) {
        print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": 0 items found (Page ID: $pageId).');
        progressData[letter] = {
          'completed': true,
          'page_id': pageId,
          'item_count': 0,
          'timestamp': DateTime.now().toIso8601String(),
        };
        await progressFile.writeAsString(jsonEncode(progressData));
        continue;
      }

      // Delete existing records for this page ID, letter, or URL to support clean overwrite/update
      final oldIncubatorUrl = 'https://incubator.wikimedia.org/wiki/Wb/nia/Amaedola/$letter';
      await (db.delete(db.proverbs)
            ..where((t) => t.pageId.equals(pageId) | t.url.equals(pageUrl) | t.url.equals(oldIncubatorUrl) | t.label.equals(letter)))
          .go();

      final companions = entries.map((entry) {
        return ProverbsCompanion.insert(
          label: letter,
          textContent: entry['text']!,
          meaning: entry['meaning'] ?? '',
          url: Value(pageUrl),
          meaningId: Value(entry['meaning_id']),
          meaningEn: Value(entry['meaning_en']),
          pageId: pageId,
        );
      }).toList();

      await db.batch((b) {
        b.insertAll(db.proverbs, companions);
      });

      // Save page revision
      final revId = parseData['revid'] as int? ?? (parseData['revisions'] as List<dynamic>?)?.firstOrNull?['revid'] as int? ?? 0;
      await db.into(db.wikiPageRevisions).insertOnConflictUpdate(
            WikiPageRevision(
              pageId: pageId,
              lastRevid: revId,
              pageTitle: pageTitle,
              pageType: 'proverbs',
              lastUpdated: DateTime.now(),
            ),
          );

      totalFetched += entries.length;
      fetchedInThisRun++;
      print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": Saved ${entries.length} items (Page ID: $pageId).');

      // Update checkpoint
      progressData[letter] = {
        'completed': true,
        'page_id': pageId,
        'item_count': entries.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await progressFile.writeAsString(jsonEncode(progressData));

      // Rate limiting: pause 2 seconds after every 5 page requests
      if ((fetchedInThisRun % 5 == 0) && i + 1 < alphabet.length) {
        print('   ⏳ [Server Care] Pausing for 2 seconds to avoid overloading Wikimedia API...');
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      print('[${i + 1}/${alphabet.length}] ($progressPercent%) Letter "$letter": Error parsing page: $e');
    }
  }

  print('==================================================');
  print('Completed! Total Proverbs sayings in database: $totalFetched');
  print('==================================================');

  // Copy updated DB to assets/
  final assetFile = File('assets/niasheritage.sqlite');
  if (await dbFile.exists()) {
    await dbFile.copy(assetFile.path);
    print('Updated assets/niasheritage.sqlite database.');
  }

  await db.close();
}
