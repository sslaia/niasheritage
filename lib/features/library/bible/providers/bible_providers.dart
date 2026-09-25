import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/providers.dart';
import '../services/bible_service.dart';

final bibleServiceProvider = Provider<BibleService>((ref) {
  return BibleService();
});

/// Fetches the list of all 66 books from Wb/nia/Sura Ni'amoni'ö
final bibleOnlineBooksProvider = FutureProvider<List<BibleBookEntry>>((ref) async {
  final service = ref.watch(bibleServiceProvider);
  return service.fetchBooksList();
});

/// Fetches available chapters for a specific book
final bibleOnlineChaptersProvider = FutureProvider.family<List<int>, String>((ref, bookName) async {
  final service = ref.watch(bibleServiceProvider);
  return service.fetchBookChapters(bookName);
});

class BibleChapterQuery {
  final String book;
  final int chapter;
  final bool forceRefresh;

  const BibleChapterQuery({
    required this.book,
    required this.chapter,
    this.forceRefresh = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleChapterQuery &&
          runtimeType == other.runtimeType &&
          book == other.book &&
          chapter == other.chapter &&
          forceRefresh == other.forceRefresh;

  @override
  int get hashCode => book.hashCode ^ chapter.hashCode ^ forceRefresh.hashCode;
}

/// Fetches the processed HTML and footnotes for a specific book chapter.
/// Uses local SQLite database when available for 100% offline access.
final bibleChapterContentProvider = FutureProvider.family<BibleChapterContent, BibleChapterQuery>((ref, query) async {
  final service = ref.watch(bibleServiceProvider);
  final db = ref.watch(databaseProvider);
  return service.fetchChapterContent(
    bookName: query.book,
    chapter: query.chapter,
    database: db,
    forceRefresh: query.forceRefresh,
  );
});
