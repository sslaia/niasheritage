import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/timeline_repository.dart';

/// Provides loaded timeline data for a given language code (with fallback to English).
final timelineDataProvider = FutureProvider.family<TimelineData, String>((ref, languageCode) async {
  return TimelineRepository.loadForLanguage(languageCode);
});

/// Current era filter if filtered (null means all eras are displayed along the winding path).
final timelineSelectedEraFilterProvider = StateProvider<String?>((ref) => null);

/// Tracks the milestone index currently closest to the viewport's focal center.
final timelineActiveIndexProvider = StateProvider<int>((ref) => 0);
