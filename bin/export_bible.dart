// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:io';
import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';

const List<String> canonicalBooks = [
  // Old Testament (39 books)
  'Moze I', 'Moze II', 'Moze III', 'Moze IV', 'Moze V',
  'Yosua', 'Sanguhuku', 'Ruti', 'Samueli I', 'Samueli II',
  'Razo I', 'Razo II', "Nga'ötö I", "Nga'ötö II",
  'Esera', 'Nehemia', 'Esitera', 'Yobi', 'Sinunö',
  'Amaedola Zelomo', 'Sangombakha', 'Sinunö Sebua',
  'Yesaya', 'Yeremia', 'Ngenu-Ngenu Yeremia', 'Hezekieli',
  'Danieli', 'Hosea', 'Yoeli', 'Amosi', 'Obadia',
  'Yona', 'Mikha', 'Nakhumi', 'Habakuki', 'Sefania',
  'Hagai', 'Sakharia', 'Maleakhi',
  // New Testament (27 books)
  'Mataio', 'Mareko', 'Luka', 'Yohane',
  'Halöŵö Zinenge', 'Roma', 'Korindro I', 'Korindro II',
  'Galatia', 'Efeso', 'Filifi', 'Kolose',
  'Tesalonika I', 'Tesalonika II', 'Timoteo I', 'Timoteo II',
  'Tito', 'Filemo', 'Heberaio', 'Yakobo',
  'Fetero I', 'Fetero II', 'Yohane I', 'Yohane II',
  'Yohane III', 'Yuda', "Fama'ele'ö"
];

Future<void> main(List<String> args) async {
  final dbPath = args.isNotEmpty ? args[0] : 'assets/niasheritage.sqlite';
  final dbFile = File(dbPath);
  if (!dbFile.existsSync()) {
    print('Database file not found at: $dbPath');
    exit(1);
  }

  print('Opening SQLite database from: $dbPath');
  final db = sqlite3.open(dbPath);

  // 1. Fetch all verses ordered by canonical book sequence, chapter, verse
  final caseStatements = StringBuffer('CASE book\n');
  for (int i = 0; i < canonicalBooks.length; i++) {
    caseStatements.writeln("  WHEN '${_escapeSql(canonicalBooks[i])}' THEN $i");
  }
  caseStatements.writeln('  ELSE 999\nEND');

  final query = '''
    SELECT id, page_id, category, book, chapter, verse, text, reference, note
    FROM bible
    ORDER BY $caseStatements, chapter ASC, verse ASC
  ''';

  final rows = db.select(query);
  print('Loaded ${rows.length} verses across ${canonicalBooks.length} books.');

  // 2. Build JSON Structure
  final Map<String, dynamic> jsonExport = {
    'metadata': {
      'title': "Sura Ni'amoni'ö (Nias Holy Bible)",
      'language': 'nia',
      'total_books': canonicalBooks.length,
      'total_chapters': 1189,
      'total_verses': rows.length,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
    },
    'books': <Map<String, dynamic>>[],
  };

  final Map<String, Map<int, List<Map<String, dynamic>>>> bookMap = {};
  final Map<String, String> bookCategory = {};

  for (final row in rows) {
    final pageId = row['page_id'] as int;
    final category = row['category'] as String;
    final book = row['book'] as String;
    final chapter = row['chapter'] as int;
    final verse = row['verse'] as int;
    final text = row['text'] as String;
    final rawRef = row['reference'] as String?;
    final note = row['note'] as String?;

    List<dynamic>? parsedRef;
    if (rawRef != null && rawRef.trim().isNotEmpty) {
      try {
        parsedRef = jsonDecode(rawRef) as List<dynamic>?;
      } catch (_) {
        parsedRef = [rawRef];
      }
    }

    bookCategory[book] = category;
    bookMap.putIfAbsent(book, () => {});
    bookMap[book]!.putIfAbsent(chapter, () => []);

    bookMap[book]![chapter]!.add({
      'verse': verse,
      'text': text,
      'reference': parsedRef,
      'note': note,
      'page_id': pageId,
    });
  }

  for (final bookName in canonicalBooks) {
    final chaptersData = bookMap[bookName] ?? {};
    final category = bookCategory[bookName] ?? (canonicalBooks.indexOf(bookName) < 39 ? 'OT' : 'NT');

    int totalBookVerses = 0;
    final List<Map<String, dynamic>> chaptersList = [];

    final sortedChapters = chaptersData.keys.toList()..sort();
    for (final ch in sortedChapters) {
      final verses = chaptersData[ch]!;
      totalBookVerses += verses.length;
      chaptersList.add({
        'chapter': ch,
        'total_verses': verses.length,
        'verses': verses,
      });
    }

    (jsonExport['books'] as List).add({
      'book': bookName,
      'category': category,
      'total_chapters': sortedChapters.length,
      'total_verses': totalBookVerses,
      'chapters': chaptersList,
    });
  }

  // Write bible.json
  final jsonFile = File('bible.json');
  final jsonString = const JsonEncoder.withIndent('  ').convert(jsonExport);
  jsonFile.writeAsStringSync(jsonString);
  print('Saved JSON backup: ${jsonFile.path} (${(jsonFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB)');

  // 3. Build SQL Dump
  final sqlFile = File('bible.sql');
  final sqlSink = sqlFile.openWrite();

  sqlSink.writeln('-- ========================================================');
  sqlSink.writeln("-- Nias Bible (Sura Ni'amoni'ö) SQL Database Dump");
  sqlSink.writeln('-- Total Books: ${canonicalBooks.length}');
  sqlSink.writeln('-- Total Chapters: 1189');
  sqlSink.writeln('-- Total Verses: ${rows.length}');
  sqlSink.writeln('-- Exported at: ${DateTime.now().toUtc().toIso8601String()}');
  sqlSink.writeln('-- ========================================================\n');

  sqlSink.writeln('PRAGMA foreign_keys = OFF;');
  sqlSink.writeln('BEGIN TRANSACTION;\n');

  sqlSink.writeln('CREATE TABLE IF NOT EXISTS "bible" (');
  sqlSink.writeln('  "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,');
  sqlSink.writeln('  "page_id" INTEGER NOT NULL,');
  sqlSink.writeln('  "category" TEXT NOT NULL,');
  sqlSink.writeln('  "book" TEXT NOT NULL,');
  sqlSink.writeln('  "chapter" INTEGER NOT NULL,');
  sqlSink.writeln('  "verse" INTEGER NOT NULL,');
  sqlSink.writeln('  "text" TEXT NOT NULL,');
  sqlSink.writeln('  "reference" TEXT NULL,');
  sqlSink.writeln('  "note" TEXT NULL');
  sqlSink.writeln(');\n');

  // Generate batch INSERT statements (100 rows per INSERT statement for SQL efficiency)
  const batchSize = 100;
  for (int i = 0; i < rows.length; i += batchSize) {
    final end = (i + batchSize < rows.length) ? i + batchSize : rows.length;
    final chunk = rows.sublist(i, end);

    sqlSink.write('INSERT INTO "bible" ("page_id", "category", "book", "chapter", "verse", "text", "reference", "note") VALUES\n');
    for (int j = 0; j < chunk.length; j++) {
      final r = chunk[j];
      final pageId = r['page_id'] as int;
      final category = _escapeSql(r['category'] as String);
      final book = _escapeSql(r['book'] as String);
      final chapter = r['chapter'] as int;
      final verse = r['verse'] as int;
      final text = _escapeSql(r['text'] as String);
      final rawRef = r['reference'] as String?;
      final note = r['note'] as String?;

      final refSql = rawRef != null ? "'${_escapeSql(rawRef)}'" : 'NULL';
      final noteSql = note != null ? "'${_escapeSql(note)}'" : 'NULL';

      sqlSink.write("  ($pageId, '$category', '$book', $chapter, $verse, '$text', $refSql, $noteSql)");
      if (j == chunk.length - 1) {
        sqlSink.writeln(';\n');
      } else {
        sqlSink.writeln(',');
      }
    }
  }

  sqlSink.writeln('CREATE INDEX IF NOT EXISTS "idx_bible_book_chapter" ON "bible" ("book", "chapter");');
  sqlSink.writeln('CREATE INDEX IF NOT EXISTS "idx_bible_category" ON "bible" ("category");');
  sqlSink.writeln('CREATE INDEX IF NOT EXISTS "idx_bible_page_id" ON "bible" ("page_id");\n');

  sqlSink.writeln('COMMIT;');
  await sqlSink.flush();
  await sqlSink.close();

  print('Saved SQL backup: ${sqlFile.path} (${(sqlFile.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB)');
  db.close();
  print('Export completed successfully!');
}

String _escapeSql(String value) {
  return value.replaceAll("'", "''");
}
