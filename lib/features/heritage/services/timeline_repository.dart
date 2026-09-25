import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/timeline_milestone_model.dart';

class TimelineData {
  final List<TimelineEra> eras;
  final List<TimelineMilestone> milestones;

  const TimelineData({
    required this.eras,
    required this.milestones,
  });
}

class TimelineRepository {
  static final Map<String, TimelineData> _cachedData = {};

  /// Clears in-memory timeline caches so edits in JSON assets are reloaded.
  static void clearCache() {
    _cachedData.clear();
  }

  static Future<TimelineData> loadForLanguage(String languageCode) async {
    // Check if memory-cached
    if (_cachedData.containsKey(languageCode)) {
      return _cachedData[languageCode]!;
    }

    // Always load English as root fallback
    final enData = await _loadRaw('en');

    if (languageCode == 'en') {
      _cachedData['en'] = enData;
      return enData;
    }

    try {
      final localizedData = await _loadRaw(languageCode);

      // Merge eras with English fallback
      final mergedEras = <TimelineEra>[];
      final processedEraIds = <String>{};

      for (final enEra in enData.eras) {
        processedEraIds.add(enEra.id);
        final locEra = localizedData.eras.firstWhere(
          (e) => e.id == enEra.id,
          orElse: () => enEra,
        );
        mergedEras.add(
          TimelineEra(
            id: enEra.id,
            roman: enEra.roman,
            index: enEra.index,
            title: locEra.title.trim().isNotEmpty ? locEra.title : enEra.title,
            period: locEra.period.trim().isNotEmpty ? locEra.period : enEra.period,
            accentColor: enEra.accentColor,
          ),
        );
      }

      for (final locEra in localizedData.eras) {
        if (!processedEraIds.contains(locEra.id)) {
          mergedEras.add(locEra);
        }
      }

      // Merge milestones with English fallback
      final mergedMilestones = <TimelineMilestone>[];
      final processedMilestoneIds = <String>{};

      for (final enMs in enData.milestones) {
        processedMilestoneIds.add(enMs.id);
        final locMs = localizedData.milestones.firstWhere(
          (m) => m.id == enMs.id,
          orElse: () => enMs,
        );
        mergedMilestones.add(locMs.copyWithFallback(enMs));
      }

      // Also append any new milestones defined in localized data that don't exist in English yet
      for (final locMs in localizedData.milestones) {
        if (!processedMilestoneIds.contains(locMs.id)) {
          mergedMilestones.add(locMs);
        }
      }

      final combined = TimelineData(
        eras: mergedEras,
        milestones: mergedMilestones,
      );
      _cachedData[languageCode] = combined;
      return combined;
    } catch (_) {
      // If language file fails or doesn't exist yet, return English cleanly
      _cachedData[languageCode] = enData;
      return enData;
    }
  }

  static Future<TimelineData> _loadRaw(String languageCode) async {
    final assetPath = 'assets/data/timeline_$languageCode.json';
    final jsonString = await rootBundle.loadString(assetPath);
    final map = json.decode(jsonString) as Map<String, dynamic>;

    final rawEras = (map['eras'] as List<dynamic>?) ?? [];
    final eras = rawEras
        .map((e) => TimelineEra.fromJson(e as Map<String, dynamic>))
        .toList();

    final eraColorMap = {for (var e in eras) e.id: e.accentColor};

    final rawMilestones = (map['milestones'] as List<dynamic>?) ?? [];
    final milestones = rawMilestones.map((m) {
      final mMap = m as Map<String, dynamic>;
      final eraId = mMap['eraId'] as String? ?? '';
      return TimelineMilestone.fromJson(
        mMap,
        fallbackColor: eraColorMap[eraId],
      );
    }).toList();

    return TimelineData(eras: eras, milestones: milestones);
  }
}
