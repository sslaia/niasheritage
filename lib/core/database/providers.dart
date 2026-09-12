import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'database.dart';
import 'connection.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.forExecutor(openConnection());
  ref.onDispose(() => db.close());
  return db;
});

final heritageItemsStreamProvider = StreamProvider<List<HeritageItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.heritageItems)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
      .watch();
});

final timelineEventsStreamProvider = StreamProvider<List<TimelineEvent>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.timelineEvents)
        ..orderBy([(t) => OrderingTerm(expression: t.year, mode: OrderingMode.asc)]))
      .watch();
});

// For holding the selected item ID in the desktop split-pane layout
final selectedItemIdProvider = StateProvider<String?>((ref) => null);

final proverbsStreamProvider = StreamProvider<List<Proverb>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.proverbs)
        ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]))
      .watch();
});

// Backward-compatibility alias
final amaedolaStreamProvider = proverbsStreamProvider;
