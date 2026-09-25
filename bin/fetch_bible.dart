// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:niasheritage/core/database/database.dart';
import 'package:niasheritage/core/utils/bible_parser.dart';

class BookMeta {
  final String name;
  final String category; // 'OT' or 'NT'
  final int chapters;

  const BookMeta(this.name, this.category, this.chapters);
}

const List<BookMeta> canonicalManifest = [
  // Old Testament (39 books, 929 chapters)
  BookMeta('Moze I', 'OT', 50),
  BookMeta('Moze II', 'OT', 40),
  BookMeta('Moze III', 'OT', 27),
  BookMeta('Moze IV', 'OT', 36),
  BookMeta('Moze V', 'OT', 34),
  BookMeta('Yosua', 'OT', 24),
  BookMeta('Sanguhuku', 'OT', 21),
  BookMeta('Ruti', 'OT', 4),
  BookMeta('Samueli I', 'OT', 31),
  BookMeta('Samueli II', 'OT', 24),
  BookMeta('Razo I', 'OT', 22),
  BookMeta('Razo II', 'OT', 25),
  BookMeta("Nga'ötö I", 'OT', 29),
  BookMeta("Nga'ötö II", 'OT', 36),
  BookMeta('Esera', 'OT', 10),
  BookMeta('Nehemia', 'OT', 13),
  BookMeta('Esitera', 'OT', 10),
  BookMeta('Yobi', 'OT', 42),
  BookMeta('Sinunö', 'OT', 150),
  BookMeta('Amaedola Zelomo', 'OT', 31),
  BookMeta('Sangombakha', 'OT', 12),
  BookMeta('Sinunö Sebua', 'OT', 8),
  BookMeta('Yesaya', 'OT', 66),
  BookMeta('Yeremia', 'OT', 52),
  BookMeta('Ngenu-Ngenu Yeremia', 'OT', 5),
  BookMeta('Hezekieli', 'OT', 48),
  BookMeta('Danieli', 'OT', 12),
  BookMeta('Hosea', 'OT', 14),
  BookMeta('Yoeli', 'OT', 3),
  BookMeta('Amosi', 'OT', 9),
  BookMeta('Obadia', 'OT', 1),
  BookMeta('Yona', 'OT', 4),
  BookMeta('Mikha', 'OT', 7),
  BookMeta('Nakhumi', 'OT', 3),
  BookMeta('Habakuki', 'OT', 3),
  BookMeta('Sefania', 'OT', 3),
  BookMeta('Hagai', 'OT', 2),
  BookMeta('Sakharia', 'OT', 14),
  BookMeta('Maleakhi', 'OT', 4),

  // New Testament (27 books, 260 chapters)
  BookMeta('Mataio', 'NT', 28),
  BookMeta('Mareko', 'NT', 16),
  BookMeta('Luka', 'NT', 24),
  BookMeta('Yohane', 'NT', 21),
  BookMeta('Halöŵö Zinenge', 'NT', 28),
  BookMeta('Roma', 'NT', 16),
  BookMeta('Korindro I', 'NT', 16),
  BookMeta('Korindro II', 'NT', 13),
  BookMeta('Galatia', 'NT', 6),
  BookMeta('Efeso', 'NT', 6),
  BookMeta('Filifi', 'NT', 4),
  BookMeta('Kolose', 'NT', 4),
  BookMeta('Tesalonika I', 'NT', 5),
  BookMeta('Tesalonika II', 'NT', 3),
  BookMeta('Timoteo I', 'NT', 6),
  BookMeta('Timoteo II', 'NT', 4),
  BookMeta('Tito', 'NT', 3),
  BookMeta('Filemo', 'NT', 1),
  BookMeta('Heberaio', 'NT', 13),
  BookMeta('Yakobo', 'NT', 5),
  BookMeta('Fetero I', 'NT', 5),
  BookMeta('Fetero II', 'NT', 3),
  BookMeta('Yohane I', 'NT', 5),
  BookMeta('Yohane II', 'NT', 1),
  BookMeta('Yohane III', 'NT', 1),
  BookMeta('Yuda', 'NT', 1),
  BookMeta("Fama'ele'ö", 'NT', 22),
];

Future<void> main(List<String> args) async {
  bool fetchAll = false;
  bool fetchNT = false;
  bool fetchOT = false;
  bool force = false;
  String? singleBook;
  int? customChapters;

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--all') {
      fetchAll = true;
    } else if (arg == '--nt') {
      fetchNT = true;
    } else if (arg == '--ot') {
      fetchOT = true;
    } else if (arg == '--force') {
      force = true;
    } else if ((arg == '--book' || arg == '-b') && i + 1 < args.length) {
      singleBook = args[i + 1];
    } else if ((arg == '--chapters' || arg == '-c') && i + 1 < args.length) {
      customChapters = int.tryParse(args[i + 1]);
    }
  }

  final List<BookMeta> targetBooks = [];

  if (singleBook != null) {
    // Find matching book in manifest (case-insensitive)
    final match = canonicalManifest.firstWhere(
      (b) => b.name.toLowerCase() == singleBook!.toLowerCase() ||
             b.name.toLowerCase().replaceAll(' ', '_') == singleBook.toLowerCase().replaceAll(' ', '_'),
      orElse: () => BookMeta(
        singleBook!,
        'NT',
        customChapters ?? 1,
      ),
    );
    targetBooks.add(
      customChapters != null ? BookMeta(match.name, match.category, customChapters) : match,
    );
  } else if (fetchAll) {
    targetBooks.addAll(canonicalManifest);
  } else if (fetchNT) {
    targetBooks.addAll(canonicalManifest.where((b) => b.category == 'NT'));
  } else if (fetchOT) {
    targetBooks.addAll(canonicalManifest.where((b) => b.category == 'OT'));
  } else {
    // Default interactive prompt
    stdout.writeln('===============================================================');
    stdout.writeln('  Nias Holy Bible (Sura Ni\'amoni\'ö) DOM-Stream Verse Scraper');
    stdout.writeln('===============================================================');
    stdout.writeln('Usage options:');
    stdout.writeln('  dart run bin/fetch_bible.dart --all       # Scrape all 66 books (1,189 ch)');
    stdout.writeln('  dart run bin/fetch_bible.dart --nt        # Scrape 27 NT books (260 ch)');
    stdout.writeln('  dart run bin/fetch_bible.dart --ot        # Scrape 39 OT books (929 ch)');
    stdout.writeln('  dart run bin/fetch_bible.dart --book <name> [--force]');
    stdout.writeln('---------------------------------------------------------------');
    stdout.write('Enter book name to scrape (or "nt", "ot", "all"): ');
    final line = stdin.readLineSync()?.trim() ?? '';
    if (line.toLowerCase() == 'all') {
      targetBooks.addAll(canonicalManifest);
    } else if (line.toLowerCase() == 'nt') {
      targetBooks.addAll(canonicalManifest.where((b) => b.category == 'NT'));
    } else if (line.toLowerCase() == 'ot') {
      targetBooks.addAll(canonicalManifest.where((b) => b.category == 'OT'));
    } else if (line.isNotEmpty) {
      final match = canonicalManifest.firstWhere(
        (b) => b.name.toLowerCase() == line.toLowerCase() ||
               b.name.toLowerCase().replaceAll(' ', '_') == line.toLowerCase().replaceAll(' ', '_'),
        orElse: () => BookMeta(line, 'NT', 1),
      );
      targetBooks.add(match);
    } else {
      print('No selection provided. Exiting.');
      return;
    }
  }

  await runBatchScraper(books: targetBooks, force: force);
}

Future<void> runBatchScraper({
  required List<BookMeta> books,
  required bool force,
}) async {
  final progressFile = File('.bible_progress.json');
  Map<String, dynamic> progressData = {};
  if (await progressFile.exists() && !force) {
    try {
      progressData = jsonDecode(await progressFile.readAsString()) as Map<String, dynamic>;
    } catch (_) {}
  }

  final dbFile = File('niasheritage.sqlite');
  final db = AppDatabase.forFile(dbFile);

  final client = http.Client();
  int totalVersesAllBooks = 0;
  int requestsCount = 0;

  print('\n>>> Commencing Bible DOM-Stream scrape for ${books.length} books <<<');
  print('Target database: ${dbFile.path}');
  print('Progress tracker: ${progressFile.path}\n');

  for (int bIdx = 0; bIdx < books.length; bIdx++) {
    final book = books[bIdx];
    final bookKey = book.name;
    final bookProgress = (progressData[bookKey] is Map<String, dynamic>)
        ? (progressData[bookKey] as Map<String, dynamic>)
        : <String, dynamic>{};

    print('📖 [${bIdx + 1}/${books.length}] Book: ${book.name} (${book.chapters} ch, ${book.category})');

    int bookVerses = 0;

    for (int ch = 1; ch <= book.chapters; ch++) {
      final chKey = ch.toString();

      // Checkpoint resume check
      if (!force && bookProgress.containsKey(chKey) && bookProgress[chKey]['completed'] == true) {
        final existingVerses = bookProgress[chKey]['verses'] as int? ?? 0;
        bookVerses += existingVerses;
        print('   [$ch/${book.chapters}] Skipping (already scraped, $existingVerses verses)');
        continue;
      }

      final pageTitle = 'Wb/nia/${book.name.replaceAll(' ', '_')}/$ch';
      
      // Fetch chapter content with retry and backoff
      final fetchResult = await _fetchChapterWithBackoff(
        client: client,
        bookName: book.name,
        chapter: ch,
      );

      requestsCount++;

      if (fetchResult == null) {
        print('   ❌ [$ch/${book.chapters}] Failed to fetch $pageTitle after multiple retries.');
        continue;
      }

      final pageId = fetchResult.pageId;
      final rawHtml = fetchResult.html;

      if (rawHtml.isEmpty) {
        print('   ⚠️ [$ch/${book.chapters}] Empty page content for $pageTitle.');
        continue;
      }

      // Parse with DOM-stream parser
      final verses = parseBibleChapterPage(
        htmlText: rawHtml,
        book: book.name,
        chapter: ch,
        category: book.category,
        pageId: pageId,
      );

      if (verses.isEmpty) {
        print('   ⚠️ [$ch/${book.chapters}] 0 verses parsed from $pageTitle (Page ID: $pageId).');
      } else {
        // Atomic transaction: delete existing records for book & chapter, then insert fresh parsed verses
        await db.transaction(() async {
          await (db.delete(db.bibles)
                ..where((t) => (t.book.equals(book.name) & t.chapter.equals(ch)) | (pageId != null ? t.pageId.equals(pageId) : const Constant(false))))
              .go();
          await db.batch((b) {
            b.insertAll(db.bibles, verses);
          });
        });

        bookVerses += verses.length;
        print('   ✅ [$ch/${book.chapters}] $pageTitle -> ${verses.length} verses saved (Page ID: $pageId)');
      }

      // Record checkpoint
      bookProgress[chKey] = {
        'completed': true,
        'page_id': pageId,
        'verses': verses.length,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };
      progressData[bookKey] = bookProgress;
      await progressFile.writeAsString(jsonEncode(progressData));

      // Polite rate-limiting: 300ms between calls, 2s pause every 10 calls
      await Future.delayed(const Duration(milliseconds: 300));
      if (requestsCount % 10 == 0) {
        print('   ⏳ [Rate Limiting] Brief 2s pause to protect Wikimedia Incubator API...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    totalVersesAllBooks += bookVerses;
    print('✨ Finished ${book.name}: $bookVerses verses total.\n');
  }

  client.close();
  await db.close();

  // Sync to assets/niasheritage.sqlite
  final assetFile = File('assets/niasheritage.sqlite');
  if (await dbFile.exists()) {
    await dbFile.copy(assetFile.path);
    print('📦 Copied updated database to ${assetFile.path}');

    // Vacuum database for compact size
    try {
      final rawDb = sqlite.sqlite3.open(assetFile.path);
      rawDb.execute('VACUUM;');
      rawDb.close();
      print('🧹 Executed SQLite VACUUM on ${assetFile.path} (${(assetFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB)');
    } catch (e) {
      print('Note: VACUUM skipped: $e');
    }
  }

  print('\n===============================================================');
  print('All operations complete! Total verses processed: $totalVersesAllBooks');
  print('===============================================================\n');
}

class _FetchResult {
  final int? pageId;
  final String html;

  _FetchResult(this.pageId, this.html);
}

Future<_FetchResult?> _fetchChapterWithBackoff({
  required http.Client client,
  required String bookName,
  required int chapter,
}) async {
  final cleanName = bookName.replaceAll(' ', '_');
  final standardTitle = 'Wb/nia/$cleanName/$chapter';

  // For single-chapter books, Incubator sometimes has the root title Wb/nia/$cleanName
  final candidates = [standardTitle];
  if (chapter == 1) {
    candidates.add('Wb/nia/$cleanName');
  }

  for (final pageTitle in candidates) {
    final apiUrl = Uri.parse(
      'https://incubator.wikimedia.org/w/api.php?action=parse&page=${Uri.encodeComponent(pageTitle)}&format=json&prop=text',
    );

    int attempts = 0;
    const maxAttempts = 5;

    while (attempts < maxAttempts) {
      attempts++;
      try {
        final response = await client.get(
          apiUrl,
          headers: {
            'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage; contact: info@niasheritage.org)',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 429 || response.statusCode == 503) {
          final waitSeconds = pow(2, attempts).toInt() + Random().nextInt(2);
          print('   ⚠️ HTTP ${response.statusCode} for $pageTitle. Backing off for ${waitSeconds}s (attempt $attempts/$maxAttempts)...');
          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        }

        if (response.statusCode != 200) {
          if (candidates.length > 1 && pageTitle == candidates.first) {
            // Try fallback candidate
            break;
          }
          return null;
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json.containsKey('error')) {
          if (candidates.length > 1 && pageTitle == candidates.first) {
            // Fallback candidate
            break;
          }
          return null;
        }

        final parseData = json['parse'] as Map<String, dynamic>?;
        final int? pageId = parseData?['pageid'] as int?;
        final html = parseData?['text']?['*'] as String? ?? '';

        return _FetchResult(pageId, html);
      } catch (e) {
        if (attempts >= maxAttempts) return null;
        final waitSeconds = pow(2, attempts).toInt();
        print('   ⚠️ Network error: $e. Retrying in ${waitSeconds}s (attempt $attempts/$maxAttempts)...');
        await Future.delayed(Duration(seconds: waitSeconds));
      }
    }
  }

  return null;
}
