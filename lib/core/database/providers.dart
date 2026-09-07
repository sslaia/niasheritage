import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'database.dart';
import 'connection.dart';

import '../services/heritage_article_seeder.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.forExecutor(openConnection());
  seedHeritageArticlesFromAssets(db);
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

final amaedolaStreamProvider = StreamProvider<List<Amaedola>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.amaedolas)
        ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]))
      .watch();
});
