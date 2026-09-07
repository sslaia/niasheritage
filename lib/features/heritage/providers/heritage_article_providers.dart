import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/providers.dart';
import '../../../core/utils/heritage_article_parser.dart';

final heritageArticleStreamProvider = StreamProvider.family<HeritageArticle?, int>((ref, pageId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.heritageArticles)..where((t) => t.pageId.equals(pageId))).watchSingleOrNull();
});

final heritageArticleByCategoryStreamProvider = StreamProvider.family<HeritageArticle?, String>((ref, category) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.heritageArticles)..where((t) => t.category.equals(category))).watchSingleOrNull();
});

List<ArticleFootnote> parseFootnotesFromJson(String? jsonString) {
  if (jsonString == null || jsonString.isEmpty) return [];
  try {
    final decoded = jsonDecode(jsonString);
    if (decoded is List) {
      return decoded.map((e) => ArticleFootnote.fromJson(e as Map<String, dynamic>)).toList();
    }
  } catch (_) {}
  return [];
}
