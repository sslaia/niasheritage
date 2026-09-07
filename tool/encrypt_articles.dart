import 'dart:io';
import 'package:niasheritage/core/services/article_encryption_service.dart';

void main() async {
  final dir = Directory('assets/articles');
  if (!dir.existsSync()) {
    stderr.writeln('Error: Directory assets/articles not found!');
    exit(1);
  }

  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stdout.writeln('No .md files found in assets/articles/ to encrypt.');
    return;
  }

  stdout.writeln('🔒 Encrypting ${files.length} article files into crawler-safe .bin format...\n');

  int count = 0;
  for (final file in files) {
    final plainText = await file.readAsString();
    final encryptedBytes = ArticleEncryptionService.encryptMarkdown(plainText);
    final binPath = file.path.replaceAll(RegExp(r'\.md$'), '.bin');
    await File(binPath).writeAsBytes(encryptedBytes);
    count++;
    final fileName = file.uri.pathSegments.last;
    final binName = File(binPath).uri.pathSegments.last;
    stdout.writeln('  ✓ $fileName (${file.lengthSync()} B) -> $binName (${encryptedBytes.length} B)');
  }

  stdout.writeln('\n🎉 Successfully encrypted $count articles.');
  stdout.writeln('Raw Markdown (.md) drafts stay local (git-ignored).');
  stdout.writeln('Only encrypted (.bin) files will be bundled and pushed.');
}
