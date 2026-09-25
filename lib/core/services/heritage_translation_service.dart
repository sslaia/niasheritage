import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../database/providers.dart';
import '../utils/heritage_article_parser.dart';
import '../wikimedia/wiki_config.dart';

export '../utils/title_sanitizer.dart' show sanitizeArticleTitle, unescapeHtmlEntities;

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
/// as defined in HERITAGE-ARTICLES.md under the user page namespace 'Sangoguna:Slaia/'.
const List<HeritageArticleDefinition> heritageArticleDefinitions = [
  // Introduction Section
  HeritageArticleDefinition(
    pageId: 5037,
    category: 'intro',
    lang: 'nia',
    defaultPageTitle: 'Sangoguna:Slaia/Mangai Mangawuli Manö-Manö Nono Niha',
    label: 'Mangai Mangawuli Manö-Manö Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 5034,
    category: 'intro',
    lang: 'nia_ceramah',
    defaultPageTitle: 'Sangoguna:Slaia/Merebut Kembali Narasi Nias (Ceramah)',
    label: 'Merebut Kembali Narasi Nias (Ceramah)',
  ),
  HeritageArticleDefinition(
    pageId: 5032,
    category: 'intro',
    lang: 'id',
    defaultPageTitle: 'Sangoguna:Slaia/Merebut Kembali Narasi Nias',
    label: 'Merebut Kembali Narasi Nias',
  ),
  HeritageArticleDefinition(
    pageId: 5034,
    category: 'intro',
    lang: 'id_ceramah',
    defaultPageTitle: 'Sangoguna:Slaia/Merebut Kembali Narasi Nias (Ceramah)',
    label: 'Merebut Kembali Narasi Nias (Ceramah)',
  ),
  HeritageArticleDefinition(
    pageId: 5033,
    category: 'intro',
    lang: 'en',
    defaultPageTitle: 'Sangoguna:Slaia/Reclaiming the Nias Narrative',
    label: 'Reclaiming the Nias Narrative',
  ),
  HeritageArticleDefinition(
    pageId: 5029,
    category: 'intro',
    lang: 'en_paper',
    defaultPageTitle: 'Sangoguna:Slaia/Reclaiming the Nias Narrative (Paper)',
    label: 'Reclaiming the Nias Narrative (Paper)',
  ),

  // 1. Architecture Section
  HeritageArticleDefinition(
    pageId: 5038,
    category: 'architecture',
    lang: 'nia',
    defaultPageTitle: 'Sangoguna:Slaia/Fangotomosi Omo Niha',
    label: 'Fangotomosi Omo Niha',
  ),
  HeritageArticleDefinition(
    pageId: 5030,
    category: 'architecture',
    lang: 'id',
    defaultPageTitle: 'Sangoguna:Slaia/Arsitektur Rumah Tradisional Nias',
    label: 'Arsitektur Rumah Tradisional Nias',
  ),
  HeritageArticleDefinition(
    pageId: 5031,
    category: 'architecture',
    lang: 'en',
    defaultPageTitle: 'Sangoguna:Slaia/Nias Traditional House Architecture',
    label: 'Nias Traditional House Architecture',
  ),

  // 2. Megaliths Section
  HeritageArticleDefinition(
    pageId: 5039,
    category: 'megalith',
    lang: 'nia',
    defaultPageTitle: 'Sangoguna:Slaia/Gowe Megalit',
    label: 'Gowe Megalit',
  ),
  HeritageArticleDefinition(
    pageId: 5035,
    category: 'megalith',
    lang: 'id',
    defaultPageTitle: 'Sangoguna:Slaia/Batu Megalit Nias',
    label: 'Batu Megalit Nias',
  ),
  HeritageArticleDefinition(
    pageId: 5036,
    category: 'megalith',
    lang: 'en',
    defaultPageTitle: 'Sangoguna:Slaia/Nias Megalithic Stones',
    label: 'Nias Megalithic Stones',
  ),

  // 3. Arts Section
  HeritageArticleDefinition(
    pageId: 5040,
    category: 'arts',
    lang: 'nia',
    defaultPageTitle: 'Sangoguna:Slaia/Nekhe-Nekhe',
    label: 'Nekhe-Nekhe',
  ),
  HeritageArticleDefinition(
    pageId: 5041,
    category: 'arts',
    lang: 'id',
    defaultPageTitle: 'Sangoguna:Slaia/Seni dan Budaya Nias',
    label: 'Seni dan Budaya Nias',
  ),
  HeritageArticleDefinition(
    pageId: 5042,
    category: 'arts',
    lang: 'en',
    defaultPageTitle: 'Sangoguna:Slaia/Nias Arts and Culture',
    label: 'Nias Arts and Culture',
  ),

  // 4. Attire/Clothing Section
  HeritageArticleDefinition(
    pageId: 5044,
    category: 'clothing',
    lang: 'nia',
    defaultPageTitle: 'Sangoguna:Slaia/Baru ba Gama-Gama',
    label: 'Baru ba Gama-Gama',
  ),
  HeritageArticleDefinition(
    pageId: 5043,
    category: 'clothing',
    lang: 'id',
    defaultPageTitle: 'Sangoguna:Slaia/Busana Nias dan Perkakas',
    label: 'Busana Nias dan Perkakas',
  ),
  HeritageArticleDefinition(
    pageId: 5045,
    category: 'clothing',
    lang: 'en',
    defaultPageTitle: 'Sangoguna:Slaia/Nias Attire and Tools',
    label: 'Nias Attire and Tools',
  ),

  // 5. Village Section
  HeritageArticleDefinition(
    pageId: 5046,
    category: 'village',
    lang: 'nia',
    defaultPageTitle: 'Sangoguna:Slaia/Banua ba Amakhoita',
    label: 'Banua ba Amakhoita',
  ),
  HeritageArticleDefinition(
    pageId: 5047,
    category: 'village',
    lang: 'id',
    defaultPageTitle: 'Sangoguna:Slaia/Sistem Sosial Nias',
    label: 'Sistem Sosial Nias',
  ),
  HeritageArticleDefinition(
    pageId: 5048,
    category: 'village',
    lang: 'en',
    defaultPageTitle: 'Sangoguna:Slaia/Nias Social System',
    label: 'Nias Social System',
  ),

  // 6. Origin Section
  HeritageArticleDefinition(
    pageId: 5050,
    category: 'origin',
    lang: 'nia',
    defaultPageTitle: 'Sangoguna:Slaia/Böröta Nono Niha',
    label: 'Böröta Nono Niha',
  ),
  HeritageArticleDefinition(
    pageId: 5049,
    category: 'origin',
    lang: 'id',
    defaultPageTitle: 'Sangoguna:Slaia/Asal-usul Orang Nias',
    label: 'Asal-usul Orang Nias',
  ),
  HeritageArticleDefinition(
    pageId: 5051,
    category: 'origin',
    lang: 'en',
    defaultPageTitle: 'Sangoguna:Slaia/Origin of Ono Niha',
    label: 'Origin of Ono Niha',
  ),

  // 7. Timeline Section
  HeritageArticleDefinition(
    pageId: 5053,
    category: 'timeline',
    lang: 'nia',
    defaultPageTitle: 'Sangoguna:Slaia/Ofanöŵa Ginötö',
    label: 'Ofanöŵa Ginötö',
  ),
  HeritageArticleDefinition(
    pageId: 5052,
    category: 'timeline',
    lang: 'id',
    defaultPageTitle: 'Sangoguna:Slaia/Linimasa Sejarah Nias',
    label: 'Linimasa Sejarah Nias',
  ),
  HeritageArticleDefinition(
    pageId: 5054,
    category: 'timeline',
    lang: 'en',
    defaultPageTitle: 'Sangoguna:Slaia/Nias History Timeline',
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
    // Default 'nia': includes both the narrative and the lecture transcript
    return heritageArticleDefinitions
        .where((d) => d.category == 'intro' && (d.lang == 'nia' || d.lang == 'nia_ceramah'))
        .toList();
  }
}



/// Active synchronizations in flight to prevent duplicate simultaneous queries
final Set<int> _activeSyncPageIds = {};

/// Checks whether an article has changed online on Wikipedia.
/// If revid is newer, downloads full parsed content, updates SQLite,
/// and returns true if content was updated.
Future<bool> checkAndSyncHeritageArticleIfChanged(
  AppDatabase db,
  int pageId, {
  int? knownRevid,
  http.Client? client,
}) async {
  if (_activeSyncPageIds.contains(pageId)) return false;
  _activeSyncPageIds.add(pageId);

  try {
    final httpClient = client ?? http.Client();
    final checkUri = Uri.parse(
      'https://nia.wikipedia.org/w/api.php?action=query&pageids=$pageId&prop=revisions&rvprop=ids|timestamp&format=json',
    );

    final response = await httpClient.get(checkUri, headers: WikiConfig.headers).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final pages = json['query']?['pages'] as Map<String, dynamic>?;
      final pageData = pages?[pageId.toString()] as Map<String, dynamic>?;

      if (pageData != null && !pageData.containsKey('missing')) {
        final revisions = pageData['revisions'] as List<dynamic>?;
        if (revisions != null && revisions.isNotEmpty) {
          final int onlineRevid = revisions[0]['revid'] as int? ?? 0;
          final int currentRevid = knownRevid ?? 0;

          if (onlineRevid > 0 && (currentRevid == 0 || onlineRevid > currentRevid)) {
            final updated = await downloadAndSaveHeritageArticle(
              db,
              pageId,
              client: httpClient,
            );
            return updated != null;
          }
        }
      }
    }
  } catch (e) {
    // Network unavailable or timeout; keep cached version silently
  } finally {
    _activeSyncPageIds.remove(pageId);
  }

  return false;
}

/// Directly downloads from Wikipedia parse API, parses content, and saves to SQLite.
Future<HeritageDisplayArticle?> downloadAndSaveHeritageArticle(
  AppDatabase db,
  int pageId, {
  http.Client? client,
}) async {
  final def = findHeritageDefinitionByPageId(pageId);
  final category = def?.category ?? 'architecture';
  final lang = def?.lang.replaceFirst('_ceramah', '').replaceFirst('_paper', '') ?? 'nia';

  final parseUri = Uri.parse(
    'https://nia.wikipedia.org/w/api.php?action=parse&pageid=$pageId&prop=text|revid|displaytitle&format=json',
  );

  final httpClient = client ?? http.Client();
  final response = await httpClient.get(parseUri, headers: WikiConfig.headers).timeout(const Duration(seconds: 15));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json.containsKey('error')) {
      throw Exception(json['error']?['info'] ?? json['error'].toString());
    }
    final parseData = json['parse'] as Map<String, dynamic>?;

    if (parseData != null) {
      final onlineTitle = parseData['title'] as String? ?? def?.defaultPageTitle ?? '';
      final displayTitle = parseData['displaytitle'] as String? ?? onlineTitle;
      final int onlineRevid = parseData['revid'] as int? ?? 0;
      final rawHtml = parseData['text']?['*'] as String? ?? '';

      if (rawHtml.trim().isNotEmpty) {
        final cleanDisplayTitle = sanitizeArticleTitle(
          displayTitle,
          fallbackLabel: def?.label ?? onlineTitle,
        );

        final parsed = parseHeritageArticleHtml(
          htmlText: rawHtml,
          defaultTitle: cleanDisplayTitle,
        );

        final resolvedTitle = sanitizeArticleTitle(
          parsed.title.trim().isNotEmpty ? parsed.title : cleanDisplayTitle,
          fallbackLabel: def?.label ?? onlineTitle,
        );

        final finalHtml = parsed.htmlContent ?? rawHtml;

        final companion = HeritageArticlesCompanion(
          pageId: Value(pageId),
          category: Value(category),
          wikiHost: const Value('nia.wikipedia.org'),
          pageTitle: Value(onlineTitle),
          title: Value(resolvedTitle),
          textContent: Value(parsed.textContent),
          htmlContent: Value(finalHtml),
          footnotes: Value(jsonEncode(parsed.footnotes.map((f) => f.toJson()).toList())),
          imageUrl: Value(parsed.imageUrl ?? _categoryHeroImages[category]),
          lastRevid: Value(onlineRevid),
          lastUpdated: Value(DateTime.now()),
        );

        await db.into(db.heritageArticles).insertOnConflictUpdate(companion);

        await db.into(db.wikiPageRevisions).insertOnConflictUpdate(
          WikiPageRevision(
            pageId: pageId,
            lastRevid: onlineRevid,
            pageTitle: onlineTitle,
            pageType: 'heritage',
            lastUpdated: DateTime.now(),
          ),
        );

        return HeritageDisplayArticle(
          pageId: pageId,
          title: resolvedTitle,
          htmlContent: finalHtml,
          textContent: parsed.textContent,
          imageUrl: parsed.imageUrl ?? _categoryHeroImages[category],
          footnotes: parsed.footnotes,
          lang: lang,
          isTranslated: lang != 'nia',
        );
      }
    }
  }
  return null;
}

/// Provider for fetching and reading an article directly by its Wikipedia page ID.
final heritageArticleByPageIdProvider =
    FutureProvider.family<HeritageDisplayArticle?, int>((ref, pageId) async {
  final db = ref.watch(databaseProvider);
  return fetchHeritageArticleByPageId(
    db,
    pageId,
    onContentUpdated: () {
      ref.invalidateSelf();
    },
  );
});

/// Provider for resolving a heritage category topic according to the active language.
final heritageDisplayArticleProvider =
    FutureProvider.family<HeritageDisplayArticle?, HeritageArticleQueryParam>((ref, param) async {
  final db = ref.watch(databaseProvider);
  final normCategory = param.category == 'dance' ? 'arts' : param.category;

  // 1. Try requested language definition
  final targetDef = findHeritageDefinition(normCategory, param.lang);
  if (targetDef != null) {
    final article = await fetchHeritageArticleByPageId(
      db,
      targetDef.pageId,
      onContentUpdated: () {
        ref.invalidateSelf();
      },
    );
    if (article != null) return article;
  }

  // 2. Fallbacks: 'id' -> 'en' -> 'nia'
  for (final fallbackLang in ['id', 'en', 'nia']) {
    if (fallbackLang == param.lang) continue;
    final fallbackDef = findHeritageDefinition(normCategory, fallbackLang);
    if (fallbackDef != null) {
      final article = await fetchHeritageArticleByPageId(
        db,
        fallbackDef.pageId,
        onContentUpdated: () {
          ref.invalidateSelf();
        },
      );
      if (article != null) return article;
    }
  }

  // 3. Last fallback: try param.pageId if provided
  if (param.pageId > 0) {
    return fetchHeritageArticleByPageId(
      db,
      param.pageId,
      onContentUpdated: () {
        ref.invalidateSelf();
      },
    );
  }

  return null;
});

/// Fetches an article by its permanent Wikipedia page ID, identifying it regardless of
/// page moves or title renames. Caches and syncs with SQLite database.
Future<HeritageDisplayArticle?> fetchHeritageArticleByPageId(
  AppDatabase db,
  int pageId, {
  bool forceRefresh = false,
  VoidCallback? onContentUpdated,
  http.Client? client,
}) async {
  final def = findHeritageDefinitionByPageId(pageId);
  final category = def?.category ?? 'architecture';
  final rawLang = def?.lang ?? 'nia';
  final lang = rawLang.replaceFirst('_ceramah', '').replaceFirst('_paper', '');

  // 1. Check local SQLite cache first
  final cached = await (db.select(db.heritageArticles)..where((t) => t.pageId.equals(pageId))).getSingleOrNull();

  // If cached and not forcing refresh, return cached immediately and trigger live online change check in background
  if (cached != null && !forceRefresh && (cached.htmlContent?.trim().isNotEmpty == true || cached.textContent.trim().isNotEmpty)) {
    // Check if the page has changed online when internet connection exists
    unawaited(() async {
      final changed = await checkAndSyncHeritageArticleIfChanged(
        db,
        pageId,
        knownRevid: cached.lastRevid,
        client: client,
      );
      if (changed && onContentUpdated != null) {
        onContentUpdated();
      }
    }());

    var footnotes = _decodeFootnotes(cached.footnotes);
    final html = (cached.htmlContent != null && cached.htmlContent!.trim().isNotEmpty)
        ? cached.htmlContent!
        : cached.textContent;

    // Self-heal footnotes if cached row had empty footnotes
    if (footnotes.isEmpty && html.isNotEmpty) {
      final parsed = parseHeritageArticleHtml(htmlText: html, defaultTitle: cached.title);
      if (parsed.footnotes.isNotEmpty) {
        footnotes = parsed.footnotes;
        unawaited(() async {
          final fnsJson = jsonEncode(footnotes.map((f) => f.toJson()).toList());
          await (db.update(db.heritageArticles)..where((t) => t.pageId.equals(pageId))).write(
            HeritageArticlesCompanion(footnotes: Value(fnsJson)),
          );
        }());
      }
    }

    final sanitizedTitle = sanitizeArticleTitle(cached.title, fallbackLabel: def?.label);

    return HeritageDisplayArticle(
      pageId: pageId,
      title: sanitizedTitle,
      htmlContent: html,
      textContent: cached.textContent,
      imageUrl: cached.imageUrl ?? _categoryHeroImages[category],
      footnotes: footnotes,
      lang: lang,
      isTranslated: lang != 'nia',
    );
  }

  // 2. Query online via Nias Wikipedia API using permanent page ID
  try {
    final fresh = await downloadAndSaveHeritageArticle(db, pageId, client: client);
    if (fresh != null) return fresh;
  } catch (e) {
    if (forceRefresh && cached == null) {
      rethrow;
    }
  }

  // 3. Fallback to cached version if network failed
  if (cached != null && (cached.htmlContent?.trim().isNotEmpty == true || cached.textContent.trim().isNotEmpty)) {
    var footnotes = _decodeFootnotes(cached.footnotes);
    final html = (cached.htmlContent != null && cached.htmlContent!.trim().isNotEmpty)
        ? cached.htmlContent!
        : cached.textContent;

    // Self-heal footnotes if cached row had empty footnotes
    if (footnotes.isEmpty && html.isNotEmpty) {
      final parsed = parseHeritageArticleHtml(htmlText: html, defaultTitle: cached.title);
      if (parsed.footnotes.isNotEmpty) {
        footnotes = parsed.footnotes;
        unawaited(() async {
          final fnsJson = jsonEncode(footnotes.map((f) => f.toJson()).toList());
          await (db.update(db.heritageArticles)..where((t) => t.pageId.equals(pageId))).write(
            HeritageArticlesCompanion(footnotes: Value(fnsJson)),
          );
        }());
      }
    }

    final sanitizedTitle = sanitizeArticleTitle(cached.title, fallbackLabel: def?.label);

    return HeritageDisplayArticle(
      pageId: pageId,
      title: sanitizedTitle,
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
