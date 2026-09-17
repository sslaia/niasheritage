import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'database.dart';
import 'connection.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.forExecutor(openConnection());
  ref.onDispose(() => db.close());
  return db;
});


final proverbsStreamProvider = StreamProvider<List<Proverb>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.proverbs)
        ..orderBy([(t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc)]))
      .watch();
});
