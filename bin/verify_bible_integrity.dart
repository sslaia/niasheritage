// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:io';
import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';

class BookMeta {
  final String name;
  final String category; // 'OT' or 'NT'
  final int chapters;

  const BookMeta(this.name, this.category, this.chapters);
}

const List<BookMeta> canonicalBooksManifest = [
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

void main(List<String> args) {
  String dbPath = 'assets/niasheritage.sqlite';
  String? showBook;
  int? showChapter;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--show' && i + 2 < args.length) {
      showBook = args[i + 1];
      showChapter = int.tryParse(args[i + 2]);
    } else if (!args[i].startsWith('--')) {
      dbPath = args[i];
    }
  }

  if (showBook != null && showChapter != null) {
    if (!File(dbPath).existsSync() && File('niasheritage.sqlite').existsSync()) {
      dbPath = 'niasheritage.sqlite';
    }
    final db = sqlite3.open(dbPath);
    final rows = db.select(
      'SELECT verse, text, reference FROM bible WHERE book = ? AND chapter = ? ORDER BY verse ASC;',
      [showBook, showChapter],
    );
    print('Showing $showBook chapter $showChapter (${rows.length} verses):');
    for (final r in rows) {
      print('[v${r['verse']}] ${r['text']}');
      if (r['reference'] != null) {
        print('    🔗 Footnotes: ${r['reference']}');
      }
    }
    db.close();
    return;
  }

  final file = File(dbPath);
  if (!file.existsSync()) {
    print('Error: Database file does not exist: $dbPath');
    exit(1);
  }

  print('===============================================================');
  print('  Nias Holy Bible (Sura Ni\'amoni\'ö) Integrity Auditor');
  print('  Database: $dbPath (${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB)');
  print('===============================================================\n');

  final db = sqlite3.open(dbPath);

  // Check table presence
  final tableCheck = db.select("SELECT name FROM sqlite_master WHERE type='table' AND name='bible';");
  if (tableCheck.isEmpty) {
    print('CRITICAL: "bible" table does not exist in $dbPath!');
    exit(1);
  }

  int totalExpectedChapters = 0;
  int totalActualChapters = 0;
  int totalVerses = 0;
  int versesWithFormatting = 0;
  int versesWithReferences = 0;

  final List<String> missingBooks = [];
  final List<String> missingChapters = [];
  final List<String> warnings = [];

  for (final bookMeta in canonicalBooksManifest) {
    totalExpectedChapters += bookMeta.chapters;

    // Check if book exists
    final bookRows = db.select(
      'SELECT chapter, verse, text, reference FROM bible WHERE book = ? ORDER BY chapter ASC, verse ASC;',
      [bookMeta.name],
    );

    if (bookRows.isEmpty) {
      missingBooks.add(bookMeta.name);
      for (int c = 1; c <= bookMeta.chapters; c++) {
        missingChapters.add('${bookMeta.name} $c');
      }
      continue;
    }

    final Map<int, List<Row>> chapterMap = {};
    for (final row in bookRows) {
      final ch = row['chapter'] as int;
      chapterMap.putIfAbsent(ch, () => []).add(row);
      totalVerses++;

      final text = row['text'] as String;
      if (text.contains('<b>') || text.contains('<i>') || text.contains('<br>') || text.contains('<strong>')) {
        versesWithFormatting++;
      }

      final ref = row['reference'] as String?;
      if (ref != null && ref.trim().isNotEmpty) {
        versesWithReferences++;
        try {
          final decoded = jsonDecode(ref);
          if (decoded is! List) {
            warnings.add('Non-list reference format in ${bookMeta.name} ch $ch v ${row['verse']}');
          }
        } catch (e) {
          warnings.add('Malformed JSON reference in ${bookMeta.name} ch $ch v ${row['verse']}: $ref');
        }
      }
    }

    totalActualChapters += chapterMap.length;

    // Check for missing chapters within this book
    for (int c = 1; c <= bookMeta.chapters; c++) {
      if (!chapterMap.containsKey(c)) {
        missingChapters.add('${bookMeta.name} $c');
      } else {
        final verses = chapterMap[c]!;
        if (verses.isEmpty) {
          warnings.add('${bookMeta.name} chapter $c has 0 verses.');
        }
      }
    }
  }

  print('=== AUDIT SUMMARY ===');
  print('Books:             ${canonicalBooksManifest.length - missingBooks.length} / ${canonicalBooksManifest.length}');
  print('Chapters:          $totalActualChapters / $totalExpectedChapters');
  print('Total Verses:      $totalVerses');
  print('Verses w/ Markup:  $versesWithFormatting (bold, italic, poetry)');
  print('Verses w/ Refs:    $versesWithReferences (footnote citations)');
  print('=====================\n');

  if (missingBooks.isNotEmpty) {
    print('❌ Missing Books (${missingBooks.length}):');
    for (final b in missingBooks) {
      print('   - $b');
    }
    print('');
  }

  if (missingChapters.isNotEmpty) {
    print('❌ Missing Chapters (${missingChapters.length} / $totalExpectedChapters):');
    final displayCount = missingChapters.length > 20 ? 20 : missingChapters.length;
    for (int i = 0; i < displayCount; i++) {
      print('   - ${missingChapters[i]}');
    }
    if (missingChapters.length > 20) {
      print('   ... and ${missingChapters.length - 20} more chapters.');
    }
    print('');
  }

  if (warnings.isNotEmpty) {
    print('⚠️ Warnings (${warnings.length}):');
    for (final w in warnings.take(10)) {
      print('   - $w');
    }
    print('');
  }

  db.close();

  if (missingChapters.isEmpty && missingBooks.isEmpty) {
    print('✅ SUCCESS: All 66 books and 1,189 chapters are completely intact!');
    exit(0);
  } else {
    print('⚠️ INCOMPLETE: ${missingChapters.length} chapters still missing.');
    exit(1);
  }
}
