import 'package:flutter/services.dart' show rootBundle;
import 'package:drift/drift.dart';
import '../database/database.dart';

class HeritageTopicSeedConfig {
  final int pageId;
  final String category;
  final String pageTitle;
  final String defaultTitle;

  const HeritageTopicSeedConfig({
    required this.pageId,
    required this.category,
    required this.pageTitle,
    required this.defaultTitle,
  });
}

const List<HeritageTopicSeedConfig> heritageSeedConfigs = [
  HeritageTopicSeedConfig(
    pageId: 4297,
    category: 'architecture',
    pageTitle: 'Omo_Niha',
    defaultTitle: 'Omo Niha',
  ),
  HeritageTopicSeedConfig(
    pageId: 4797,
    category: 'megalith',
    pageTitle: 'Behu_ba_Daro-Daro_Nono_Niha',
    defaultTitle: 'Behu ba Daro-Daro Nono Niha',
  ),
  HeritageTopicSeedConfig(
    pageId: 4798,
    category: 'arts',
    pageTitle: 'Fanari_ba_Fanunö_Nono_Niha',
    defaultTitle: 'Fanari ba Fanunö Nono Niha',
  ),
  HeritageTopicSeedConfig(
    pageId: 4799,
    category: 'clothing',
    pageTitle: 'Gama-Gama_Nono_Niha',
    defaultTitle: 'Gama-Gama Nono Niha',
  ),
  HeritageTopicSeedConfig(
    pageId: 4800,
    category: 'village',
    pageTitle: 'Banua_Nono_Niha',
    defaultTitle: 'Banua Nono Niha',
  ),
  HeritageTopicSeedConfig(
    pageId: 4801,
    category: 'origin',
    pageTitle: 'Böröta_Nono_Niha',
    defaultTitle: 'Böröta Nono Niha',
  ),
  HeritageTopicSeedConfig(
    pageId: 4802,
    category: 'timeline',
    pageTitle: 'Ofanöŵa_Ginötö_Nono_Niha',
    defaultTitle: 'Ofanöŵa Ginötö Nono Niha',
  ),
];

/// Seeds the Nias Heritage articles from bundled HTML assets into SQLite
/// if they are missing or if table is empty.
Future<void> seedHeritageArticlesFromAssets(AppDatabase db) async {
  try {
    final existingCount = await db.select(db.heritageArticles).get().then((rows) => rows.length);
    if (existingCount >= heritageSeedConfigs.length) {
      return; // Already populated
    }

    for (final config in heritageSeedConfigs) {
      final existing = await (db.select(db.heritageArticles)..where((t) => t.pageId.equals(config.pageId))).getSingleOrNull();
      if (existing != null) continue;

      try {
        final assetPath = 'assets/articles/${config.category}_nia.md';
        final mdContent = await rootBundle.loadString(assetPath);
        
        // Extract title from the first header line if available
        String title = config.defaultTitle;
        for (final line in mdContent.split('\n')) {
          final trimmed = line.trim();
          if (trimmed.startsWith('# ')) {
            title = trimmed.substring(2).trim();
            break;
          } else if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
            title = trimmed.replaceAll('**', '').split('\n').first.trim();
            break;
          }
        }

        final companion = HeritageArticlesCompanion(
          pageId: Value(config.pageId),
          category: Value(config.category),
          pageTitle: Value(config.pageTitle),
          wikiHost: const Value('nia.wikipedia.org'),
          title: Value(title),
          textContent: Value(mdContent),
          htmlContent: Value(mdContent),
          footnotes: const Value('[]'),
          imageUrl: const Value(null),
          lastRevid: const Value(0),
          lastUpdated: Value(DateTime.now()),
        );

        await db.into(db.heritageArticles).insertOnConflictUpdate(companion);
      } catch (e) {
        // Ignored if specific asset fails to load
      }
    }
  } catch (_) {}
}
