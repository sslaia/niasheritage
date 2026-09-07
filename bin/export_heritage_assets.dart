// ignore_for_file: avoid_print
import 'dart:io';
import 'package:niasheritage/core/database/database.dart';

void main() async {
  final dbFile = File('assets/niasheritage.sqlite');
  final db = AppDatabase.forFile(dbFile);

  final outputDir = Directory('assets/articles');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final articles = await db.select(db.heritageArticles).get();
  print('Exporting ${articles.length} Nias articles to assets/articles/...');

  for (final a in articles) {
    final file = File('assets/articles/${a.category}_nia.html');
    final content = '''
<h1>${a.title}</h1>
${a.htmlContent ?? '<p>${a.textContent}</p>'}
'''.trim();
    await file.writeAsString(content);
    print('  Wrote ${file.path} (${content.length} chars)');
  }

  await db.close();
  print('Done exporting Nias articles.');
}
