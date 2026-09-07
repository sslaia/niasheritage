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
      .where((f) => f.path.endsWith('.bin'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (files.isEmpty) {
    stdout.writeln('No .bin files found in assets/articles/ to decrypt.');
    return;
  }

  stdout.writeln('🔓 Decrypting ${files.length} article files into editable .md format...\n');

  int count = 0;
  for (final file in files) {
    final bytes = await file.readAsBytes();
    final plainText = ArticleEncryptionService.decryptMarkdown(bytes);
    final mdPath = file.path.replaceAll(RegExp(r'\.bin$'), '.md');
    await File(mdPath).writeAsString(plainText);
    count++;
    final fileName = file.uri.pathSegments.last;
    final mdName = File(mdPath).uri.pathSegments.last;
    stdout.writeln('  ✓ $fileName (${file.lengthSync()} B) -> $mdName');
  }

  stdout.writeln('\n🎉 Successfully restored $count editable Markdown (.md) articles.');
}
