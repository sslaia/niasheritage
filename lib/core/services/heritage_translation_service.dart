import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../database/providers.dart';
import '../utils/heritage_article_parser.dart';

class HeritageDisplayArticle {
  final int pageId;
  final String title;
  final String htmlContent;
  final String textContent;
  final String? imageUrl;
  final List<ArticleFootnote> footnotes;
  final String lang;
  final bool isTranslated;

  const HeritageDisplayArticle({
    required this.pageId,
    required this.title,
    String? htmlContent,
    String? markdownContent,
    required this.textContent,
    this.imageUrl,
    this.footnotes = const [],
    required this.lang,
    required this.isTranslated,
  }) : htmlContent = htmlContent ?? markdownContent ?? '';

  String get markdownContent => htmlContent;
}

class HeritageArticleQueryParam {
  final String category;
  final int pageId;
  final String lang;

  const HeritageArticleQueryParam({
    required this.category,
    required this.pageId,
    required this.lang,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeritageArticleQueryParam &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          pageId == other.pageId &&
          lang == other.lang;

  @override
  int get hashCode => category.hashCode ^ pageId.hashCode ^ lang.hashCode;
}

class HeritageArticleDefinition {
  final int pageId;
  final String category;
  final String lang;
  final String defaultPageTitle;
  final String label;

  const HeritageArticleDefinition({
    required this.pageId,
    required this.category,
    required this.lang,
    required this.defaultPageTitle,
    required this.label,
  });
}

/// Official Page ID registry on Nias Wikipedia (nia.wikipedia.org)
/// as defined in HERITAGE-ARTICLES.txt.
const List<HeritageArticleDefinition> heritageArticleDefinitions = [
  // Introduction Section
  HeritageArticleDefinition(
    pageId: 4846,
    category: 'intro',
    lang: 'nia',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Mangai Mangawuli Manö-Manö Nono Niha',
    label: 'Mangai Mangawuli Manö-Manö Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 4838,
    category: 'intro',
    lang: 'id',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Merebut Kembali Narasi Nias',
    label: 'Merebut Kembali Narasi Nias',
  ),
  HeritageArticleDefinition(
    pageId: 4841,
    category: 'intro',
    lang: 'id_ceramah',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Merebut Kembali Narasi Nias (Ceramah)',
    label: 'Merebut Kembali Narasi Nias (Ceramah)',
  ),
  HeritageArticleDefinition(
    pageId: 4839,
    category: 'intro',
    lang: 'en',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Reclaiming the Nias Narrative',
    label: 'Reclaiming the Nias Narrative',
  ),
  HeritageArticleDefinition(
    pageId: 4840,
    category: 'intro',
    lang: 'en_paper',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Reclaiming the Nias Narrative (Paper)',
    label: 'Reclaiming the Nias Narrative (Paper)',
  ),

  // Architecture Section
  HeritageArticleDefinition(
    pageId: 4297,
    category: 'architecture',
    lang: 'nia',
    defaultPageTitle: 'Fangotomosi Omo Niha',
    label: 'Omo Niha',
  ),
  HeritageArticleDefinition(
    pageId: 4831,
    category: 'architecture',
    lang: 'id',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Arsitektur Rumah Tradisional Nias',
    label: 'Arsitektur Rumah Tradisional Nias',
  ),
  HeritageArticleDefinition(
    pageId: 4830,
    category: 'architecture',
    lang: 'en',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Nias Traditional House Architecture',
    label: 'Nias Traditional House Architecture',
  ),

  // Megaliths Section
  HeritageArticleDefinition(
    pageId: 4797,
    category: 'megalith',
    lang: 'nia',
    defaultPageTitle: 'Gowe Megalit Nono Niha',
    label: 'Gowe Megalit Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 4834,
    category: 'megalith',
    lang: 'id',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Batu Megalit Nias',
    label: 'Batu Megalit Nias',
  ),
  HeritageArticleDefinition(
    pageId: 4835,
    category: 'megalith',
    lang: 'en',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/The Nias Megalith Stones',
    label: 'The Nias Megalith Stones',
  ),

  // Arts Section
  HeritageArticleDefinition(
    pageId: 4798,
    category: 'arts',
    lang: 'nia',
    defaultPageTitle: 'Nekhe-Nekhe Nono Niha',
    label: 'Nekhe-Nekhe Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 4832,
    category: 'arts',
    lang: 'id',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Seni dan Budaya Nias',
    label: 'Seni dan Budaya Nias',
  ),
  HeritageArticleDefinition(
    pageId: 4833,
    category: 'arts',
    lang: 'en',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/The Nias Arts and Culture',
    label: 'The Nias Arts and Culture',
  ),

  // Clothing Section
  HeritageArticleDefinition(
    pageId: 4799,
    category: 'clothing',
    lang: 'nia',
    defaultPageTitle: 'Baru ba Gama-Gama Nono Niha',
    label: 'Baru ba Gama-Gama Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 4836,
    category: 'clothing',
    lang: 'id',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Busana Nias dan Perkakas',
    label: 'Busana Nias dan Perkakas',
  ),
  HeritageArticleDefinition(
    pageId: 4837,
    category: 'clothing',
    lang: 'en',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/The Nias Attire and Tools',
    label: 'The Nias Attire and Tools',
  ),

  // Village Section
  HeritageArticleDefinition(
    pageId: 4800,
    category: 'village',
    lang: 'nia',
    defaultPageTitle: 'Banua ba Amakhoita Nono Niha',
    label: 'Banua ba Amakhoita Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 4848,
    category: 'village',
    lang: 'id',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Sistem Sosial Nias',
    label: 'Sistem Sosial Nias',
  ),
  HeritageArticleDefinition(
    pageId: 4847,
    category: 'village',
    lang: 'en',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/The Nias Social System',
    label: 'The Nias Social System',
  ),

  // Origin Section
  HeritageArticleDefinition(
    pageId: 4801,
    category: 'origin',
    lang: 'nia',
    defaultPageTitle: 'Böröta Nono Niha',
    label: 'Böröta Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 4845,
    category: 'origin',
    lang: 'id',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Asal-usul Orang Nias',
    label: 'Asal-usul Orang Nias',
  ),
  HeritageArticleDefinition(
    pageId: 4844,
    category: 'origin',
    lang: 'en',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/The Origin of Ono Niha',
    label: 'The Origin of Ono Niha',
  ),

  // Timeline Section
  HeritageArticleDefinition(
    pageId: 4802,
    category: 'timeline',
    lang: 'nia',
    defaultPageTitle: 'Ofanöŵa Ginötö Nono Niha',
    label: 'Ofanöŵa Ginötö Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 4843,
    category: 'timeline',
    lang: 'id',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Linimasa Sejarah Nias',
    label: 'Linimasa Sejarah Nias',
  ),
  HeritageArticleDefinition(
    pageId: 4842,
    category: 'timeline',
    lang: 'en',
    defaultPageTitle: 'Wikipedia:Ondröita Nono Niha/Nias History Timeline',
    label: 'Nias History Timeline',
  ),
];

const Map<String, String> _categoryHeroImages = {
  'intro': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/heritage.jpg',
  'architecture': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/omo_hada.jpg',
  'megalith': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/gowe.jpg',
  'arts': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/famaena.jpg',
  'clothing': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/oholu.jpg',
  'village': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/banua.jpg',
  'origin': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/origin.jpg',
  'timeline': 'https://raw.githubusercontent.com/sslaia/sslaia.github.io/master/images/timeline.jpg',
};

/// Resolves article definition by pageId.
HeritageArticleDefinition? findHeritageDefinitionByPageId(int pageId) {
  for (final def in heritageArticleDefinitions) {
    if (def.pageId == pageId) return def;
  }
  return null;
}

/// Resolves article definition by category and language.
HeritageArticleDefinition? findHeritageDefinition(String category, String lang) {
  final normCategory = category == 'dance' ? 'arts' : category;
  for (final def in heritageArticleDefinitions) {
    if (def.category == normCategory && def.lang == lang) {
      return def;
    }
  }
  return null;
}

/// Returns introductory articles for the given language.
List<HeritageArticleDefinition> getIntroductionArticlesForLang(String lang) {
  if (lang == 'id') {
    return heritageArticleDefinitions
        .where((d) => d.category == 'intro' && (d.lang == 'id' || d.lang == 'id_ceramah'))
        .toList();
  } else if (lang == 'en') {
    return heritageArticleDefinitions
        .where((d) => d.category == 'intro' && (d.lang == 'en' || d.lang == 'en_paper'))
        .toList();
  } else {
    // Default 'nia'
    return heritageArticleDefinitions
        .where((d) => d.category == 'intro' && d.lang == 'nia')
        .toList();
  }
}

/// Provider for fetching and reading an article directly by its Wikipedia page ID.
final heritageArticleByPageIdProvider =
    FutureProvider.family<HeritageDisplayArticle?, int>((ref, pageId) async {
  final db = ref.watch(databaseProvider);
  return fetchHeritageArticleByPageId(db, pageId);
});

/// Provider for resolving a heritage category topic according to the active language.
final heritageDisplayArticleProvider =
    FutureProvider.family<HeritageDisplayArticle?, HeritageArticleQueryParam>((ref, param) async {
  final db = ref.watch(databaseProvider);
  final normCategory = param.category == 'dance' ? 'arts' : param.category;

  // 1. Try requested language definition
  final targetDef = findHeritageDefinition(normCategory, param.lang);
  if (targetDef != null) {
    final article = await fetchHeritageArticleByPageId(db, targetDef.pageId);
    if (article != null) return article;
  }

  // 2. Fallbacks: 'id' -> 'en' -> 'nia'
  for (final fallbackLang in ['id', 'en', 'nia']) {
    if (fallbackLang == param.lang) continue;
    final fallbackDef = findHeritageDefinition(normCategory, fallbackLang);
    if (fallbackDef != null) {
      final article = await fetchHeritageArticleByPageId(db, fallbackDef.pageId);
      if (article != null) return article;
    }
  }

  // 3. Last fallback: try param.pageId if provided
  if (param.pageId > 0) {
    return fetchHeritageArticleByPageId(db, param.pageId);
  }

  return null;
});

/// Fetches an article by its permanent Wikipedia page ID, identifying it regardless of
/// page moves or title renames. Caches and syncs with SQLite database.
Future<HeritageDisplayArticle?> fetchHeritageArticleByPageId(
  AppDatabase db,
  int pageId, {
  bool forceRefresh = false,
}) async {
  final def = findHeritageDefinitionByPageId(pageId);
  final category = def?.category ?? 'architecture';
  final lang = def?.lang ?? 'nia';

  // 1. Check local SQLite cache first
  final cached = await (db.select(db.heritageArticles)..where((t) => t.pageId.equals(pageId))).getSingleOrNull();

  // If cached and not forcing refresh, check if we need to return cached immediately
  if (cached != null && !forceRefresh && (cached.htmlContent?.trim().isNotEmpty == true || cached.textContent.trim().isNotEmpty)) {
    final footnotes = _decodeFootnotes(cached.footnotes);
    final html = (cached.htmlContent != null && cached.htmlContent!.trim().isNotEmpty)
        ? cached.htmlContent!
        : cached.textContent;

    return HeritageDisplayArticle(
      pageId: pageId,
      title: cached.title,
      htmlContent: html,
      textContent: cached.textContent,
      imageUrl: cached.imageUrl ?? _categoryHeroImages[category],
      footnotes: footnotes,
      lang: lang,
      isTranslated: lang != 'nia',
    );
  }

  // 2. Query online via Nias Wikipedia API using permanent page ID with prop=text
  try {
    final parseUri = Uri.parse(
      'https://nia.wikipedia.org/w/api.php?action=parse&pageid=$pageId&prop=text|revid|displaytitle&format=json',
    );

    final response = await http.get(parseUri, headers: {
      'User-Agent': 'NiasHeritageApp/1.0 (https://github.com/sslaia/niasheritage)',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json.containsKey('error')) {
        throw Exception(json['error']?['info'] ?? json['error'].toString());
      }
      final parseData = json['parse'] as Map<String, dynamic>?;

      if (parseData != null) {
        final onlineTitle = parseData['title'] as String? ?? def?.defaultPageTitle ?? '';
        final displayTitle = parseData['displaytitle'] as String? ?? def?.label ?? onlineTitle;
        final int onlineRevid = parseData['revid'] as int? ?? 0;
        final rawHtml = parseData['text']?['*'] as String? ?? '';

        if (rawHtml.trim().isNotEmpty) {
          final parsed = parseHeritageArticleHtml(
            htmlText: rawHtml,
            defaultTitle: def?.label ?? displayTitle,
          );

          final finalHtml = parsed.htmlContent ?? rawHtml;

          // Update SQLite cache
          final companion = HeritageArticlesCompanion(
            pageId: Value(pageId),
            category: Value(category),
            wikiHost: const Value('nia.wikipedia.org'),
            pageTitle: Value(onlineTitle),
            title: Value(def?.label ?? displayTitle),
            textContent: Value(parsed.textContent),
            htmlContent: Value(finalHtml),
            footnotes: Value(jsonEncode(parsed.footnotes.map((f) => f.toJson()).toList())),
            imageUrl: Value(parsed.imageUrl ?? _categoryHeroImages[category]),
            lastRevid: Value(onlineRevid),
            lastUpdated: Value(DateTime.now()),
          );

          await db.into(db.heritageArticles).insertOnConflictUpdate(companion);

          return HeritageDisplayArticle(
            pageId: pageId,
            title: def?.label ?? displayTitle,
            htmlContent: finalHtml,
            textContent: parsed.textContent,
            imageUrl: parsed.imageUrl ?? _categoryHeroImages[category],
            footnotes: parsed.footnotes,
            lang: lang,
            isTranslated: lang != 'nia',
          );
        }
      }
    } else {
      throw Exception('HTTP ${response.statusCode} while fetching from Wikipedia');
    }
  } catch (e) {
    if (forceRefresh) {
      rethrow;
    }
  }

  // 3. Fallback to cached version if network failed
  if (cached != null && (cached.htmlContent?.trim().isNotEmpty == true || cached.textContent.trim().isNotEmpty)) {
    final footnotes = _decodeFootnotes(cached.footnotes);
    final html = (cached.htmlContent != null && cached.htmlContent!.trim().isNotEmpty)
        ? cached.htmlContent!
        : cached.textContent;

    return HeritageDisplayArticle(
      pageId: pageId,
      title: cached.title,
      htmlContent: html,
      textContent: cached.textContent,
      imageUrl: cached.imageUrl ?? _categoryHeroImages[category],
      footnotes: footnotes,
      lang: lang,
      isTranslated: lang != 'nia',
    );
  }

  return null;
}

/// Refetches an article directly from Wikipedia and updates the SQLite database cache.
Future<HeritageDisplayArticle?> refreshHeritageArticleByPageId(
  WidgetRef ref,
  int pageId,
) async {
  final db = ref.read(databaseProvider);
  final fresh = await fetchHeritageArticleByPageId(db, pageId, forceRefresh: true);
  ref.invalidate(heritageArticleByPageIdProvider(pageId));
  return fresh;
}

/// Refetches an article by category and language directly from Wikipedia and updates SQLite.
Future<HeritageDisplayArticle?> refreshHeritageArticleByCategory({
  required WidgetRef ref,
  required String category,
  required String lang,
  int pageId = 0,
}) async {
  final db = ref.read(databaseProvider);
  final normCategory = category == 'dance' ? 'arts' : category;
  final def = findHeritageDefinition(normCategory, lang);
  final targetPageId = def?.pageId ?? pageId;
  if (targetPageId > 0) {
    final fresh = await fetchHeritageArticleByPageId(db, targetPageId, forceRefresh: true);
    ref.invalidate(heritageDisplayArticleProvider);
    return fresh;
  }
  return null;
}

List<ArticleFootnote> _decodeFootnotes(String? jsonString) {
  if (jsonString == null || jsonString.isEmpty) return [];
  try {
    final decoded = jsonDecode(jsonString);
    if (decoded is List) {
      return decoded.map((e) => ArticleFootnote.fromJson(e as Map<String, dynamic>)).toList();
    }
  } catch (_) {}
  return [];
}
