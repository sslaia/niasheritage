import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  const BibleChapterQuery({required this.book, required this.chapter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleChapterQuery &&
          runtimeType == other.runtimeType &&
          book == other.book &&
          chapter == other.chapter;

  @override
  int get hashCode => book.hashCode ^ chapter.hashCode;
}

/// Fetches the processed HTML and footnotes for a specific book chapter
final bibleChapterContentProvider = FutureProvider.family<BibleChapterContent, BibleChapterQuery>((ref, query) async {
  final service = ref.watch(bibleServiceProvider);
  return service.fetchChapterContent(
    bookName: query.book,
    chapter: query.chapter,
  );
});
