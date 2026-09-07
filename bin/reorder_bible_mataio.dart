// ignore_for_file: avoid_print
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:niasheritage/core/database/database.dart';

Future<void> main() async {
  print('==================================================');
  print('Reordering Bible Database: Moving Mataio before Mareko');
  print('==================================================');

  final dbFile = File('niasheritage.sqlite');
  if (!await dbFile.exists()) {
    print('Error: niasheritage.sqlite does not exist.');
    return;
  }

  final db = AppDatabase.forFile(dbFile);

  // 1. Fetch all verses
  final allVerses = await db.select(db.bibles).get();
  print('Total verses in database before reorder: ${allVerses.length}');

  // 2. Identify all distinct books in current insertion order
  final List<String> distinctBooks = [];
  final Map<String, List<Bible>> versesByBook = {};

  for (final v in allVerses) {
    if (!versesByBook.containsKey(v.book)) {
      distinctBooks.add(v.book);
      versesByBook[v.book] = [];
    }
    versesByBook[v.book]!.add(v);
  }

  print('Current book order: ${distinctBooks.join(', ')}');

  // 3. Move 'Mataio' to the position right before 'Mareko' (or index 0 if Mareko is first)
  if (!distinctBooks.contains('Mataio')) {
    print('Error: Mataio book not found in database.');
    await db.close();
    return;
  }

  distinctBooks.remove('Mataio');
  final marekoIndex = distinctBooks.indexOf('Mareko');
  if (marekoIndex != -1) {
    distinctBooks.insert(marekoIndex, 'Mataio');
  } else {
    distinctBooks.insert(0, 'Mataio');
  }

  print('\nNew book order:');
  for (int i = 0; i < distinctBooks.length; i++) {
    print('${i + 1}. ${distinctBooks[i]} (${versesByBook[distinctBooks[i]]?.length ?? 0} verses)');
  }

  // 4. Re-build the bibles table in the new order
  print('\nRebuilding bibles table in SQLite...');
  await db.transaction(() async {
    await db.delete(db.bibles).go();

    for (final bookName in distinctBooks) {
      final bookVerses = versesByBook[bookName]!;
      // Sort by chapter then verse to ensure clean internal order
      bookVerses.sort((a, b) {
        final cComp = a.chapter.compareTo(b.chapter);
        if (cComp != 0) return cComp;
        return a.verse.compareTo(b.verse);
      });

      await db.batch((b) {
        b.insertAll(
          db.bibles,
          bookVerses.map((v) => BiblesCompanion.insert(
                pageId: v.pageId,
                category: v.category,
                book: v.book,
                chapter: v.chapter,
                verse: v.verse,
                textContent: v.textContent,
                reference: v.reference != null ? Value(v.reference) : const Value.absent(),
                note: v.note != null ? Value(v.note) : const Value.absent(),
              )),
        );
      });
    }
  });

  final newCount = (await db.select(db.bibles).get()).length;
  print('Successfully rebuilt database! Total verses: $newCount');

  await db.close();

  // 5. Sync to assets/niasheritage.sqlite
  final assetFile = File('assets/niasheritage.sqlite');
  await dbFile.copy(assetFile.path);
  print('Updated assets/niasheritage.sqlite database file.');

  // 6. Reorder bible.csv if it exists
  final csvFile = File('bible.csv');
  if (await csvFile.exists()) {
    print('\nReordering bible.csv file...');
    final lines = await csvFile.readAsLines();
    if (lines.isNotEmpty) {
      final header = lines.first;
      final dataLines = lines.sublist(1);

      // Group lines by book
      final Map<String, List<String>> csvLinesByBook = {};
      final List<String> csvBookOrder = [];

      for (final line in dataLines) {
        // Line format: id,page_id,category,book,chapter,verse,...
        final parts = line.split(',');
        if (parts.length >= 4) {
          final book = parts[3].trim();
          if (!csvLinesByBook.containsKey(book)) {
            csvBookOrder.add(book);
            csvLinesByBook[book] = [];
          }
          csvLinesByBook[book]!.add(line);
        }
      }

      if (csvBookOrder.contains('Mataio')) {
        csvBookOrder.remove('Mataio');
        final mIdx = csvBookOrder.indexOf('Mareko');
        if (mIdx != -1) {
          csvBookOrder.insert(mIdx, 'Mataio');
        } else {
          csvBookOrder.insert(0, 'Mataio');
        }

        final newCsvLines = <String>[header];
        int newId = 4071; // preserve base counter if needed or re-index
        for (final bName in csvBookOrder) {
          final bookLines = csvLinesByBook[bName]!;
          for (final line in bookLines) {
            // Update the first column (ID) if numeric
            final parts = line.split(',');
            if (parts.isNotEmpty && int.tryParse(parts[0]) != null) {
              parts[0] = (newId++).toString();
              newCsvLines.add(parts.join(','));
            } else {
              newCsvLines.add(line);
            }
          }
        }

        await csvFile.writeAsString('${newCsvLines.join('\n')}\n');
        print('Updated bible.csv with Mataio placed before Mareko.');
      }
    }
  }

  print('\n==================================================');
  print('Done! Mataio is now the first book before Mareko.');
  print('==================================================');
}
