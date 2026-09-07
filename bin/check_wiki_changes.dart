// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:niasheritage/core/database/database.dart';
import 'package:niasheritage/core/services/wiki_sync_service.dart';

Future<void> main(List<String> args) async {
  print('==================================================');
  print('Script 1: Checking Wikimedia Page Changes (incubator & nia.wikipedia.org)');
  print('==================================================');

  final dbFile = File('niasheritage.sqlite');
  if (!await dbFile.exists()) {
    print('Error: Database file niasheritage.sqlite not found.');
    exit(1);
  }

  final db = AppDatabase.forFile(dbFile);
  final syncService = WikiSyncService(db);

  try {
    final changedPages = await syncService.checkChangedPages(
      onStatus: (status) => print('  ➜ $status'),
    );

    print('\n==================================================');
    print('Check complete! Total changed pages detected: ${changedPages.length}');
    print('==================================================');

    final jsonList = changedPages.map((c) => c.toJson()).toList();
    final outputFile = File('.changed_pages.json');
    await outputFile.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonList));

    print('Saved changed pages list to: ${outputFile.path}');

    if (changedPages.isNotEmpty) {
      print('\nChanged Pages Summary:');
      for (final p in changedPages) {
        print('  - [${p.pageType.toUpperCase()}] ${p.pageTitle} (Page ID: ${p.pageId}, Online Rev ID: ${p.onlineRevid}, Local Rev ID: ${p.localRevid ?? "None"})');
      }
      print('\nNext Step: Run "dart run bin/update_changed_pages.dart" to scrape and update database.');
    } else {
      print('\nAll pages are up to date with Wikimedia server!');
    }
  } catch (e) {
    print('Error checking wiki changes: $e');
  } finally {
    await db.close();
  }
}
