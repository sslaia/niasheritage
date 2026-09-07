import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/providers.dart';
import 'wiki_sync_service.dart';

final wikiSyncServiceProvider = Provider<WikiSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return WikiSyncService(db);
});
