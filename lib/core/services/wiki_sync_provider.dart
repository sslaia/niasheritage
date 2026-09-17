import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/providers.dart';
import 'wiki_sync_service.dart';
final wikiSyncServiceProvider = Provider<WikiSyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return WikiSyncService(db);
});

enum WikiSyncStatus {
  idle,
  checking,
  updating,
  completed,
  error,
}

class WikiSyncState {
  final WikiSyncStatus status;
  final String? statusMessage;
  final List<String> statusArgs;
  final double? progress; // 0.0 to 1.0, or null if indeterminate
  final int currentItem;
  final int totalItems;
  final int updatedCount;
  final DateTime? lastChecked;
  final String? errorMessage;

  const WikiSyncState({
    this.status = WikiSyncStatus.idle,
    this.statusMessage,
    this.statusArgs = const [],
    this.progress,
    this.currentItem = 0,
    this.totalItems = 0,
    this.updatedCount = 0,
    this.lastChecked,
    this.errorMessage,
  });

  bool get isLoading => status == WikiSyncStatus.checking || status == WikiSyncStatus.updating;

  WikiSyncState copyWith({
    WikiSyncStatus? status,
    String? statusMessage,
    List<String>? statusArgs,
    double? progress,
    bool clearProgress = false,
    int? currentItem,
    int? totalItems,
    int? updatedCount,
    DateTime? lastChecked,
    String? errorMessage,
  }) {
    return WikiSyncState(
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      statusArgs: statusArgs ?? this.statusArgs,
      progress: clearProgress ? null : (progress ?? this.progress),
      currentItem: currentItem ?? this.currentItem,
      totalItems: totalItems ?? this.totalItems,
      updatedCount: updatedCount ?? this.updatedCount,
      lastChecked: lastChecked ?? this.lastChecked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class WikiSyncNotifier extends StateNotifier<WikiSyncState> {
  final WikiSyncService _syncService;
  bool _cancelled = false;

  WikiSyncNotifier(this._syncService) : super(const WikiSyncState()) {
    _loadLastChecked();
  }

  Future<void> _loadLastChecked() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt('wiki_sync_last_checked_millis');
      if (millis != null) {
        state = state.copyWith(lastChecked: DateTime.fromMillisecondsSinceEpoch(millis));
      }
    } catch (_) {}
  }

  Future<void> _saveLastChecked(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('wiki_sync_last_checked_millis', time.millisecondsSinceEpoch);
    } catch (_) {}
    state = state.copyWith(lastChecked: time);
  }

  void cancel() {
    if (state.isLoading) {
      _cancelled = true;
      state = state.copyWith(
        status: WikiSyncStatus.idle,
        statusMessage: 'settings.sync_cancelled',
        clearProgress: true,
      );
    }
  }

  Future<void> startSync({bool force = false}) async {
    if (state.isLoading) return;

    // Rate-limiting / Server care: If checked within last 2 minutes and not force, report up-to-date
    if (!force && state.lastChecked != null) {
      final difference = DateTime.now().difference(state.lastChecked!);
      if (difference.inMinutes < 2) {
        state = state.copyWith(
          status: WikiSyncStatus.completed,
          statusMessage: 'settings.already_up_to_date',
          updatedCount: 0,
        );
        return;
      }
    }

    _cancelled = false;
    state = state.copyWith(
      status: WikiSyncStatus.checking,
      statusMessage: 'settings.sync_checking',
      statusArgs: ['...'],
      clearProgress: true,
      errorMessage: null,
      updatedCount: 0,
      currentItem: 0,
      totalItems: 0,
    );

    try {
      final changedPages = await _syncService.checkChangedPages(
        onStatus: (countStr) {
          if (!_cancelled) {
            state = state.copyWith(
              status: WikiSyncStatus.checking,
              statusMessage: 'settings.sync_checking',
              statusArgs: [countStr],
            );
          }
        },
        isCancelled: () => _cancelled,
      );

      if (_cancelled) {
        state = state.copyWith(
          status: WikiSyncStatus.idle,
          statusMessage: 'settings.sync_cancelled',
          clearProgress: true,
        );
        return;
      }

      await _saveLastChecked(DateTime.now());

      if (changedPages.isEmpty) {
        state = state.copyWith(
          status: WikiSyncStatus.completed,
          statusMessage: 'settings.already_up_to_date',
          updatedCount: 0,
          clearProgress: true,
        );
        return;
      }

      // Step 2: Download changed pages
      state = state.copyWith(
        status: WikiSyncStatus.updating,
        totalItems: changedPages.length,
        currentItem: 0,
        progress: 0.0,
      );

      final updatedCount = await _syncService.updateChangedPages(
        changedPages,
        onProgress: (current, total, title) {
          if (!_cancelled) {
            state = state.copyWith(
              status: WikiSyncStatus.updating,
              currentItem: current,
              totalItems: total,
              progress: total > 0 ? (current / total) : 0.0,
              statusMessage: 'settings.sync_downloading',
              statusArgs: [current.toString(), total.toString(), title],
            );
          }
        },
        isCancelled: () => _cancelled,
      );

      if (_cancelled) {
        state = state.copyWith(
          status: WikiSyncStatus.idle,
          statusMessage: 'settings.sync_cancelled',
          clearProgress: true,
        );
        return;
      }

      state = state.copyWith(
        status: WikiSyncStatus.completed,
        updatedCount: updatedCount,
        statusMessage: 'settings.sync_success',
        statusArgs: [updatedCount.toString()],
        clearProgress: true,
      );
    } catch (e) {
      if (!_cancelled) {
        state = state.copyWith(
          status: WikiSyncStatus.error,
          errorMessage: e.toString(),
          clearProgress: true,
        );
      }
    }
  }
}

final wikiSyncStateProvider =
    StateNotifierProvider<WikiSyncNotifier, WikiSyncState>((ref) {
  final syncService = ref.watch(wikiSyncServiceProvider);
  return WikiSyncNotifier(syncService);
});
