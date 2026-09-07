import 'package:flutter/widgets.dart';

/// Manages application memory footprint, specifically bitmap memory and image caches,
/// ensuring compliance with Google Play Store memory usage thresholds.
class MemoryManager with WidgetsBindingObserver {
  MemoryManager._();

  static final MemoryManager instance = MemoryManager._();

  bool _initialized = false;

  /// Default memory cache limit for images (50 MB)
  static const int maxImageCacheBytes = 50 * 1024 * 1024;

  /// Default maximum number of cached images in memory
  static const int maxImageCacheCount = 100;

  /// Initializes the memory manager, sets conservative image cache bounds,
  /// and attaches the lifecycle observer.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // 1. Constrain image cache limits to prevent memory bloat on low-to-mid RAM devices
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSizeBytes = maxImageCacheBytes;
    imageCache.maximumSize = maxImageCacheCount;

    // 2. Register lifecycle and memory pressure observer
    WidgetsBinding.instance.addObserver(this);
  }

  /// Cleans up observers
  void dispose() {
    if (!_initialized) return;
    WidgetsBinding.instance.removeObserver(this);
    _initialized = false;
  }

  /// Evicts all cached decoded bitmaps from memory.
  void clearImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release bitmap allocations when the app is placed in the background or hidden.
    // This directly complies with Google Play Store's requirement that bitmaps
    // must not be retained in non-visible (background/cached) app states.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      clearImageCache();
    }
  }

  @override
  void didHaveMemoryPressure() {
    // Aggressively reclaim memory on OS low memory warnings
    clearImageCache();
  }
}
