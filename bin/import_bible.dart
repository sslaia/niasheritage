// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'dart:io';
import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';

void main(List<String> args) {
  final inputPath = args.isNotEmpty ? args[0] : 'bible.json';
  final dbPath = args.length > 1 ? args[1] : 'assets/niasheritage.sqlite';

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    print('Error: Input file "$inputPath" does not exist.');
    exit(1);
  }

  print('Opening destination SQLite database at: $dbPath');
  final db = sqlite3.open(dbPath);

  db.execute('''
    CREATE TABLE IF NOT EXISTS "bible" (
      "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "page_id" INTEGER NOT NULL,
      "category" TEXT NOT NULL,
      "book" TEXT NOT NULL,
      "chapter" INTEGER NOT NULL,
      "verse" INTEGER NOT NULL,
      "text" TEXT NOT NULL,
      "reference" TEXT NULL,
      "note" TEXT NULL
    );
  ''');

  if (inputPath.endsWith('.sql')) {
    print('Importing SQL dump from $inputPath...');
    final sqlContent = inputFile.readAsStringSync();
    db.execute(sqlContent);
    print('SQL import finished.');
  } else {
    print('Reading and parsing JSON file: $inputPath...');
    final jsonData = jsonDecode(inputFile.readAsStringSync()) as Map<String, dynamic>;
    final books = jsonData['books'] as List<dynamic>? ?? [];

    db.execute('BEGIN TRANSACTION;');
    int totalImported = 0;

    final stmt = db.prepare('''
      INSERT INTO "bible" ("page_id", "category", "book", "chapter", "verse", "text", "reference", "note")
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''');

    for (final b in books) {
      final bookMap = b as Map<String, dynamic>;
      final bookName = bookMap['book'] as String;
      final category = bookMap['category'] as String;
      final chapters = bookMap['chapters'] as List<dynamic>? ?? [];

      for (final c in chapters) {
        final chapterMap = c as Map<String, dynamic>;
        final chapterNum = chapterMap['chapter'] as int;
        final verses = chapterMap['verses'] as List<dynamic>? ?? [];

        for (final v in verses) {
          final verseMap = v as Map<String, dynamic>;
          final verseNum = verseMap['verse'] as int;
          final text = verseMap['text'] as String;
          final pageId = verseMap['page_id'] as int? ?? 0;
          final refList = verseMap['reference'];
          final note = verseMap['note'] as String?;

          final refJson = (refList is List && refList.isNotEmpty) ? jsonEncode(refList) : null;

          stmt.execute([
            pageId,
            category,
            bookName,
            chapterNum,
            verseNum,
            text,
            refJson,
            note,
          ]);
          totalImported++;
        }
      }
    }

    stmt.close();
    db.execute('COMMIT;');
    print('Successfully imported $totalImported verses into $dbPath.');
  }

  db.close();
  print('Import process completed!');
}
