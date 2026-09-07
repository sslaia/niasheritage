// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:niasheritage/core/database/database.dart';
import 'package:niasheritage/core/services/wiki_sync_service.dart';

Future<void> main(List<String> args) async {
  print('==================================================');
  print('Script 2: Scrape & Update Database for Changed Pages');
  print('Rate limit: 2-second pause every 10 requests');
  print('==================================================');

  final listFile = File('.changed_pages.json');
  if (!await listFile.exists()) {
    print('Error: .changed_pages.json not found. Run "dart run bin/check_wiki_changes.dart" first.');
    exit(1);
  }

  final rawJson = await listFile.readAsString();
  final List<dynamic> jsonList = jsonDecode(rawJson) as List<dynamic>;

  if (jsonList.isEmpty) {
    print('No changed pages to update in .changed_pages.json.');
    return;
  }

  final changedPages = jsonList.map((e) => ChangedPageInfo.fromJson(e as Map<String, dynamic>)).toList();
  print('Found ${changedPages.length} changed pages to update.\n');

  final dbFile = File('niasheritage.sqlite');
  final db = AppDatabase.forFile(dbFile);
  final syncService = WikiSyncService(db);

  try {
    final count = await syncService.updateChangedPages(
      changedPages,
      onProgress: (current, total, status) {
        final percent = (current / total * 100).toStringAsFixed(1);
        print('[$current/$total] ($percent%) $status');
      },
    );

    print('\n==================================================');
    print('Successfully updated $count / ${changedPages.length} changed pages in database.');
    print('==================================================');

    // Reset changed pages file
    await listFile.writeAsString('[]');
    print('Cleared .changed_pages.json.');
  } catch (e) {
    print('Error updating changed pages: $e');
  } finally {
    await db.close();
  }
}
