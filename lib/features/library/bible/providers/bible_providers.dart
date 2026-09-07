import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/providers.dart';

class BibleBookInfo {
  final String book;
  final String category; // 'OT' or 'NT'
  final int totalChapters;
  final int totalVerses;

  const BibleBookInfo({
    required this.book,
    required this.category,
    required this.totalChapters,
    required this.totalVerses,
  });
}

class BibleChapterParam {
  final String book;
  final int chapter;

  const BibleChapterParam({required this.book, required this.chapter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleChapterParam &&
          runtimeType == other.runtimeType &&
          book == other.book &&
          chapter == other.chapter;

  @override
  int get hashCode => book.hashCode ^ chapter.hashCode;
}

final bibleBooksStreamProvider = StreamProvider<List<BibleBookInfo>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.bibles)).watch().map((allVerses) {
    final Map<String, BibleBookInfo> bookMap = {};
    for (final verse in allVerses) {
      if (!bookMap.containsKey(verse.book)) {
        bookMap[verse.book] = BibleBookInfo(
          book: verse.book,
          category: verse.category,
          totalChapters: verse.chapter,
          totalVerses: 1,
        );
      } else {
        final current = bookMap[verse.book]!;
        bookMap[verse.book] = BibleBookInfo(
          book: current.book,
          category: current.category,
          totalChapters: verse.chapter > current.totalChapters ? verse.chapter : current.totalChapters,
          totalVerses: current.totalVerses + 1,
        );
      }
    }
    return bookMap.values.toList();
  });
});

final bibleBookChaptersProvider = StreamProvider.family<List<int>, String>((ref, bookName) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.bibles)..where((t) => t.book.equals(bookName)))
      .watch()
      .map((verses) {
    final chapters = verses.map((v) => v.chapter).toSet().toList()..sort();
    return chapters;
  });
});

final bibleChapterVersesProvider = StreamProvider.family<List<Bible>, BibleChapterParam>((ref, param) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.bibles)
        ..where((t) => t.book.equals(param.book) & t.chapter.equals(param.chapter))
        ..orderBy([(t) => OrderingTerm(expression: t.verse, mode: OrderingMode.asc)]))
      .watch();
});

final bibleSearchQueryProvider = StateProvider<String>((ref) => '');
final bibleViewModeProvider = StateProvider<String>((ref) => 'category'); // 'category' (default) or 'alphabetical'
final bibleSelectedCategoryFilterProvider = StateProvider<String>((ref) => 'all'); // 'all', 'OT', 'NT'

final bibleVerseSearchProvider = FutureProvider.family<List<Bible>, String>((ref, query) async {
  final clean = query.trim();
  if (clean.isEmpty) return [];
  final db = ref.watch(databaseProvider);
  final lower = clean.toLowerCase();
  final upper = clean.toUpperCase();
  final capitalized = clean.length > 1
      ? '${clean[0].toUpperCase()}${clean.substring(1).toLowerCase()}'
      : clean.toUpperCase();

  return (db.select(db.bibles)
        ..where((t) =>
            t.textContent.like('%$clean%') |
            t.textContent.like('%$lower%') |
            t.textContent.like('%$upper%') |
            t.textContent.like('%$capitalized%'))
        ..orderBy([(t) => OrderingTerm(expression: t.id)]))
      .get();
});

class BibleBookSearchParam {
  final String book;
  final String query;

  const BibleBookSearchParam({required this.book, required this.query});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleBookSearchParam &&
          runtimeType == other.runtimeType &&
          book == other.book &&
          query == other.query;

  @override
  int get hashCode => book.hashCode ^ query.hashCode;
}

final bibleBookVerseSearchProvider = FutureProvider.family<List<Bible>, BibleBookSearchParam>((ref, param) async {
  final clean = param.query.trim();
  if (clean.isEmpty) return [];
  final db = ref.watch(databaseProvider);
  final lower = clean.toLowerCase();
  final upper = clean.toUpperCase();
  final capitalized = clean.length > 1
      ? '${clean[0].toUpperCase()}${clean.substring(1).toLowerCase()}'
      : clean.toUpperCase();

  return (db.select(db.bibles)
        ..where((t) =>
            t.book.equals(param.book) &
            (t.textContent.like('%$clean%') |
             t.textContent.like('%$lower%') |
             t.textContent.like('%$upper%') |
             t.textContent.like('%$capitalized%')))
        ..orderBy([
          (t) => OrderingTerm(expression: t.chapter, mode: OrderingMode.asc),
          (t) => OrderingTerm(expression: t.verse, mode: OrderingMode.asc),
        ]))
      .get();
});

