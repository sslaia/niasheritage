// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:niasheritage/core/database/database.dart';
import 'package:niasheritage/core/utils/bible_parser.dart';

Future<void> main(List<String> args) async {
  String? bookName;
  int? totalChapters;
  String? category;

  // 1. Check CLI arguments
  for (int i = 0; i < args.length; i++) {
    if ((args[i] == '--book' || args[i] == '-b') && i + 1 < args.length) {
      bookName = args[i + 1];
    } else if ((args[i] == '--chapters' || args[i] == '-c') && i + 1 < args.length) {
      totalChapters = int.tryParse(args[i + 1]);
    } else if ((args[i] == '--category' || args[i] == '-cat') && i + 1 < args.length) {
      category = args[i + 1];
    }
  }

  // 2. Interactive prompts if missing any parameter
  stdout.writeln('==================================================');
  stdout.writeln('  Nias Wikibooks Bible Scraper (bin/fetch_bible.dart)');
  stdout.writeln('==================================================');

  if (bookName == null || bookName.trim().isEmpty) {
    stdout.write('Enter Bible Book Name (e.g. Mataio): ');
    final input = stdin.readLineSync();
    if (input != null && input.trim().isNotEmpty) {
      bookName = input.trim();
    }
  }
  bookName ??= 'Mataio';

  if (totalChapters == null || totalChapters <= 0) {
    stdout.write('Enter Number of Chapters in $bookName (e.g. 28): ');
    final input = stdin.readLineSync();
    if (input != null) {
      totalChapters = int.tryParse(input.trim());
    }
  }
  totalChapters ??= 28;

  if (category == null || (category.toLowerCase() != 'ot' && category.toLowerCase() != 'nt')) {
    stdout.write('Enter Category [ot/nt] (Old Testament / New Testament): ');
    final input = stdin.readLineSync();
    if (input != null && (input.trim().toLowerCase() == 'ot' || input.trim().toLowerCase() == 'nt')) {
      category = input.trim().toLowerCase();
    }
  }
  category ??= 'nt';

  await runBibleScraper(
    bookName: bookName,
    totalChapters: totalChapters,
    category: category.toUpperCase(),
  );
}

Future<void> runBibleScraper({
  required String bookName,
  required int totalChapters,
  required String category,
  bool forceReset = false,
}) async {
  final progressFile = File('.bible_progress.json');
  Map<String, dynamic> progressData = {};
  if (!forceReset && await progressFile.exists()) {
    try {
      progressData = jsonDecode(await progressFile.readAsString()) as Map<String, dynamic>;
    } catch (_) {}
  } else if (forceReset && await progressFile.exists()) {
    await progressFile.delete();
  }

  final bookKey = bookName.toLowerCase();
  Map<String, dynamic> bookProgress = progressData[bookKey] is Map<String, dynamic>
      ? (progressData[bookKey] as Map<String, dynamic>)
      : {};

  final dbFile = File('niasheritage.sqlite');
  final db = AppDatabase.forFile(dbFile);

  stdout.writeln('\nStarting fetch for book: "$bookName" ($totalChapters chapters, Category: $category)');
  stdout.writeln('Rate limit: 2-second pause every 5 requests');
  stdout.writeln('Wikibooks page path prefix: Wb/nia/$bookName\n');

  int totalVersesInserted = 0;
  int fetchedInThisRun = 0;

  for (int chapter = 1; chapter <= totalChapters; chapter++) {
    final progressPercent = (chapter / totalChapters * 100).toStringAsFixed(1);
    final pageTitle = 'Wb/nia/$bookName/$chapter';
    final chapKey = chapter.toString();

    // Check checkpointing
    if (bookProgress.containsKey(chapKey) && bookProgress[chapKey]['completed'] == true) {
      final savedVerses = bookProgress[chapKey]['verses'] ?? 0;
      final savedPageId = bookProgress[chapKey]['page_id'];
      totalVersesInserted += (savedVerses as int);
      print('[$chapter/$totalChapters] ($progressPercent%) $pageTitle - Already completed (Page ID: $savedPageId, $savedVerses verses). Skipping.');
      continue;
    }

    final apiUrl = Uri.parse(
      'https://incubator.wikimedia.org/w/api.php?action=parse&page=${Uri.encodeComponent(pageTitle)}&format=json&prop=text',
    );

    try {
      final response = await http.get(apiUrl, headers: {
        'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
      });

      if (response.statusCode != 200) {
        print('[$chapter/$totalChapters] ($progressPercent%) HTTP ${response.statusCode} - Skipping $pageTitle');
        continue;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json.containsKey('error')) {
        final errorMsg = json['error']['info'] ?? 'Page not found';
        print('[$chapter/$totalChapters] ($progressPercent%) $pageTitle: $errorMsg - Skipping');
        continue;
      }

      final parseData = json['parse'] as Map<String, dynamic>?;
      final int? pageId = parseData?['pageid'] as int?;
      final htmlText = parseData?['text']?['*'] as String? ?? '';
      if (htmlText.isEmpty) {
        print('[$chapter/$totalChapters] ($progressPercent%) $pageTitle: Empty content - Skipping');
        continue;
      }

      final verseEntries = parseBibleChapterPage(
        htmlText: htmlText,
        book: bookName,
        chapter: chapter,
        category: category,
        pageId: pageId,
      );

      if (verseEntries.isEmpty) {
        print('[$chapter/$totalChapters] ($progressPercent%) $pageTitle: 0 verses found (Page ID: $pageId).');
        bookProgress[chapKey] = {
          'completed': true,
          'page_id': pageId,
          'verses': 0,
          'timestamp': DateTime.now().toIso8601String(),
        };
        progressData[bookKey] = bookProgress;
        await progressFile.writeAsString(jsonEncode(progressData));
        continue;
      }

      // Delete existing records for this page ID or book & chapter to ensure clean update
      await (db.delete(db.bibles)
            ..where((t) => t.pageId.equals(pageId!) | (t.book.equals(bookName) & t.chapter.equals(chapter))))
          .go();

      // Batch insert fresh parsed verses
      await db.batch((b) {
        b.insertAll(db.bibles, verseEntries);
      });

      totalVersesInserted += verseEntries.length;
      fetchedInThisRun++;
      print('[$chapter/$totalChapters] ($progressPercent%) $pageTitle -> Saved ${verseEntries.length} verses (Page ID: $pageId).');

      // Save checkpoint
      bookProgress[chapKey] = {
        'completed': true,
        'page_id': pageId,
        'verses': verseEntries.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
      progressData[bookKey] = bookProgress;
      await progressFile.writeAsString(jsonEncode(progressData));

      // Rate limiting: pause 2 seconds after every 5 requests
      if ((fetchedInThisRun % 5 == 0) && chapter < totalChapters) {
        print('   ⏳ [Server Care] Pausing for 2 seconds to avoid overloading Wikimedia API...');
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      print('[$chapter/$totalChapters] ($progressPercent%) $pageTitle -> Error: $e');
    }
  }

  print('\n==================================================');
  print('Completed! Total verses inserted for $bookName: $totalVersesInserted');
  print('==================================================');

  // Also copy to assets database so both databases are updated
  final assetFile = File('assets/niasheritage.sqlite');
  if (await dbFile.exists()) {
    await dbFile.copy(assetFile.path);
    print('Updated assets/niasheritage.sqlite database.');
  }

  await db.close();
}


