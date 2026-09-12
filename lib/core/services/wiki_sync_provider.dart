import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/providers.dart';
import 'wiki_sync_service.dart';
import 'wiki_content_cache_service.dart';

final wikiSyncServiceProvider = Provider<WikiSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return WikiSyncService(db);
});

final wikiContentCacheServiceProvider = FutureProvider<WikiContentCacheService>((ref) async {
  return WikiContentCacheService.create();
});

