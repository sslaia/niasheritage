// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:niasheritage/core/database/database.dart';

Future<void> main(List<String> args) async {
  print('==================================================');
  print('Updating Bible Page IDs (incubator.wikimedia.org)');
  print('Rate limit: 2-second pause every 5 batch requests');
  print('==================================================');

  final dbFile = File('niasheritage.sqlite');
  final db = AppDatabase.forFile(dbFile);

  // 1. Get all distinct (book, chapter) combinations from DB
  final allVerses = await db.select(db.bibles).get();
  final Map<String, Set<int>> bookChapters = {};

  for (final v in allVerses) {
    bookChapters.putIfAbsent(v.book, () => {}).add(v.chapter);
  }

  print('Found ${bookChapters.length} books and ${allVerses.length} verses in local database.');

  // Build list of all page titles: "Wb/nia/$book/$chapter" -> (book, chapter)
  final Map<String, ({String book, int chapter})> titleToBookChap = {};
  for (final entry in bookChapters.entries) {
    final book = entry.key;
    final chapters = entry.value.toList()..sort();
    for (final chap in chapters) {
      final title = 'Wb/nia/$book/$chap';
      titleToBookChap[title] = (book: book, chapter: chap);
    }
  }

  final allTitles = titleToBookChap.keys.toList();
  print('Total chapter pages to check: ${allTitles.length}');

  // Batch query titles in chunks of 50
  const chunkSize = 50;
  int updatedChapters = 0;
  int batchCount = 0;

  for (int i = 0; i < allTitles.length; i += chunkSize) {
    final chunk = allTitles.sublist(i, (i + chunkSize > allTitles.length) ? allTitles.length : i + chunkSize);
    final titlesParam = chunk.map((t) => Uri.encodeComponent(t)).join('|');
    final apiUrl = Uri.parse('https://incubator.wikimedia.org/w/api.php?action=query&titles=$titlesParam&format=json');

    batchCount++;
    final progressPercent = ((i + chunk.length) / allTitles.length * 100).toStringAsFixed(1);

    try {
      final response = await http.get(apiUrl, headers: {
        'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
      });

      if (response.statusCode != 200) {
        print('Batch $batchCount: HTTP ${response.statusCode} - Skipping chunk');
        continue;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final queryObj = json['query'] as Map<String, dynamic>?;
      final pagesObj = queryObj?['pages'] as Map<String, dynamic>?;

      if (pagesObj == null) continue;

      int chunkUpdated = 0;
      for (final page in pagesObj.values) {
        if (page is Map<String, dynamic>) {
          final String? title = page['title'] as String?;
          final int? pageId = page['pageid'] as int?;

          if (title != null && pageId != null && titleToBookChap.containsKey(title)) {
            final info = titleToBookChap[title]!;
            final count = await (db.update(db.bibles)
                  ..where((t) => t.book.equals(info.book) & t.chapter.equals(info.chapter)))
                .write(BiblesCompanion(pageId: Value(pageId)));
            if (count > 0) chunkUpdated++;
          }
        }
      }

      updatedChapters += chunkUpdated;
      print('Batch $batchCount (${i + chunk.length}/${allTitles.length} - $progressPercent%): Processed ${chunk.length} titles, updated $chunkUpdated chapters.');

      // Server care rate limit
      if (batchCount % 5 == 0 && i + chunkSize < allTitles.length) {
        print('   ⏳ [Server Care] Pausing 2 seconds to avoid overloading Wikimedia API...');
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      print('Batch $batchCount Error: $e');
    }
  }

  print('\n==================================================');
  print('Completed Bible Page ID update!');
  print('Total chapters updated: $updatedChapters / ${allTitles.length}');
  print('==================================================');

  // Also copy to assets database so both databases are updated
  final assetFile = File('assets/niasheritage.sqlite');
  if (await dbFile.exists()) {
    await dbFile.copy(assetFile.path);
    print('Updated assets/niasheritage.sqlite database.');
  }

  await db.close();
}
