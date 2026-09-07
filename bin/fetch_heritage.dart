// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:niasheritage/core/database/database.dart';
import 'package:niasheritage/core/utils/heritage_article_parser.dart';

class HeritagePageConfig {
  final int pageId;
  final String pageTitle;
  final String category;
  final String wikiHost;

  const HeritagePageConfig({
    required this.pageId,
    required this.pageTitle,
    required this.category,
    this.wikiHost = 'nia.wikipedia.org',
  });
}

void main() async {
  final sqliteFile = File('assets/niasheritage.sqlite');
  final localDbFile = File('niasheritage.sqlite');

  final db = AppDatabase.forFile(localDbFile.existsSync() ? localDbFile : sqliteFile);

  final pages = [
    const HeritagePageConfig(
      pageId: 4297,
      pageTitle: 'Omo_Niha',
      category: 'architecture',
    ),
    const HeritagePageConfig(
      pageId: 4797,
      pageTitle: 'Behu_ba_Daro-Daro_Nono_Niha',
      category: 'megalith',
    ),
    const HeritagePageConfig(
      pageId: 4798,
      pageTitle: 'Fanari_ba_Fanunö_Nono_Niha',
      category: 'dance',
    ),
    const HeritagePageConfig(
      pageId: 4799,
      pageTitle: 'Gama-Gama_Nono_Niha',
      category: 'clothing',
    ),
    const HeritagePageConfig(
      pageId: 4800,
      pageTitle: 'Banua_Nono_Niha',
      category: 'village',
    ),
    const HeritagePageConfig(
      pageId: 4801,
      pageTitle: 'Böröta_Nono_Niha',
      category: 'origin',
    ),
    const HeritagePageConfig(
      pageId: 4802,
      pageTitle: 'Ofanöŵa_Ginötö_Nono_Niha',
      category: 'timeline',
    ),
  ];

  final client = http.Client();

  for (final p in pages) {
    // Sanitize title
    final sanitizedTitle = p.pageTitle.trim().replaceAll(' ', '_');
    print('\nFetching ${p.category} [${p.pageId}] "$sanitizedTitle" from ${p.wikiHost}...');

    final uri = Uri.https(
      p.wikiHost,
      '/w/api.php',
      {
        'action': 'parse',
        'pageid': p.pageId.toString(),
        'format': 'json',
        'prop': 'text|wikitext|revid',
      },
    );

    final response = await client.get(
      uri,
      headers: {
        'User-Agent': 'NiasHeritageScraper/1.0 (https://github.com/sslaia/niasheritage)',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final parseData = json['parse'] as Map<String, dynamic>?;
      if (parseData == null) {
        print('  Failed to parse data for ${p.pageTitle}: ${json['error']}');
        continue;
      }

      final htmlText = parseData['text']?['*'] as String? ?? '';
      final revid = parseData['revid'] as int? ?? 0;
      final rawTitle = parseData['title'] as String? ?? sanitizedTitle;

      final parsed = parseHeritageArticleHtml(
        htmlText: htmlText,
        defaultTitle: rawTitle,
      );

      print('  Title: ${parsed.title}');
      print('  Extracted ${parsed.footnotes.length} footnotes');
      print('  Featured image: ${parsed.imageUrl}');
      print('  Revid: $revid');

      final companion = createHeritageArticleCompanion(
        pageId: p.pageId,
        category: p.category,
        pageTitle: sanitizedTitle,
        wikiHost: p.wikiHost,
        parsed: parsed,
        lastRevid: revid,
      );

      await (db.delete(db.heritageArticles)..where((t) => t.pageId.equals(p.pageId))).go();
      await db.into(db.heritageArticles).insertOnConflictUpdate(companion);

      await db.into(db.wikiPageRevisions).insertOnConflictUpdate(
        WikiPageRevision(
          pageId: p.pageId,
          lastRevid: revid,
          pageTitle: sanitizedTitle,
          pageType: 'heritage',
          lastUpdated: DateTime.now(),
        ),
      );

      print('  Successfully saved [${p.pageId}] to database!');
    } else {
      print('  Failed with status: ${response.statusCode}');
    }
  }

  if (localDbFile.existsSync()) {
    await localDbFile.copy(sqliteFile.path);
    print('\nCopied localDbFile to ${sqliteFile.path}');
  }

  await db.close();
  client.close();
  print('\nAll heritage articles successfully updated in database!');
}
