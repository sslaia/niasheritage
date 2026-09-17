import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final targetFolder = Directory(p.join(dbFolder.path, 'Niasheritage'));
    if (!await targetFolder.exists()) {
      await targetFolder.create(recursive: true);
    }

    final file = File(p.join(targetFolder.path, 'niasheritage.sqlite'));

    Future<void> copyPrepopulatedDb() async {
      // 1. Try local files in project root (for desktop / development)
      final rootFile = File('niasheritage.sqlite');
      final assetFile = File('assets/niasheritage.sqlite');

      if (await rootFile.exists() && (await rootFile.length()) >= 400000) {
        await rootFile.copy(file.path);
        return;
      }
      if (await assetFile.exists() && (await assetFile.length()) >= 400000) {
        await assetFile.copy(file.path);
        return;
      }

      // 2. Load from Flutter rootBundle (for mobile devices / emulators / release app builds)
      try {
        final blob = await rootBundle.load('assets/niasheritage.sqlite');
        final bytes = blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes);
        await file.writeAsBytes(bytes, flush: true);
      } catch (_) {}
    }

    bool shouldCopy = !await file.exists();
    if (!shouldCopy) {
      final currentLength = await file.length();
      final rootFile = File('niasheritage.sqlite');
      final assetFile = File('assets/niasheritage.sqlite');

      if (await rootFile.exists()) {
        final rootLen = await rootFile.length();
        if (currentLength != rootLen) shouldCopy = true;
      } else if (await assetFile.exists()) {
        final assetLen = await assetFile.length();
        if (currentLength != assetLen) shouldCopy = true;
      } else {
        try {
          final blob = await rootBundle.load('assets/niasheritage.sqlite');
          if (currentLength != blob.lengthInBytes) shouldCopy = true;
        } catch (_) {
          if (currentLength < 413000) shouldCopy = true;
        }
      }
    }

    if (shouldCopy) {
      await copyPrepopulatedDb();
    }

    return NativeDatabase.createInBackground(file);
  });
}

/// Force-copies the bundled assets/niasheritage.sqlite database over the local app file.
Future<bool> restoreBundledDatabase() async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final targetFolder = Directory(p.join(dbFolder.path, 'Niasheritage'));
    if (!await targetFolder.exists()) {
      await targetFolder.create(recursive: true);
    }
    final file = File(p.join(targetFolder.path, 'niasheritage.sqlite'));

    final rootFile = File('niasheritage.sqlite');
    final assetFile = File('assets/niasheritage.sqlite');

    if (await rootFile.exists() && (await rootFile.length()) >= 400000) {
      await rootFile.copy(file.path);
      return true;
    }
    if (await assetFile.exists() && (await assetFile.length()) >= 400000) {
      await assetFile.copy(file.path);
      return true;
    }

    final blob = await rootBundle.load('assets/niasheritage.sqlite');
    final bytes = blob.buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes);
    await file.writeAsBytes(bytes, flush: true);
    return true;
  } catch (_) {
    return false;
  }
}

