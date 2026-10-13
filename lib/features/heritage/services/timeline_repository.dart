import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/wikimedia/wiki_api_service.dart';
import '../models/timeline_milestone_model.dart';
import 'timeline_wiki_parser.dart';

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

  /// Canonical Indonesian Wikipedia timeline page.
  static const String indonesianWikiPage =
      'Wikipedia:Ondröita_Nono_Niha/Linimasa_Sejarah_Nias';

  /// Canonical English Wikipedia timeline page.
  static const String englishWikiPage =
      'Wikipedia:Ondröita_Nono_Niha/Nias_History_Timeline';

  /// Canonical Nias language Wikipedia timeline page.
  static const String niasWikiPage = 'Ofanöŵa_Ginötö_Nono_Niha';

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

  /// Fetches the latest wikitext from Wikipedia, parses it into [TimelineData],
  /// saves it to local app storage, and updates the in-memory cache.
  static Future<TimelineData?> syncFromWiki({
    String languageCode = 'id',
    WikiApiService? wikiService,
  }) async {
    try {
      final service = wikiService ?? WikiApiService();
      final String pageTitle;
      if (languageCode == 'en') {
        pageTitle = englishWikiPage;
      } else if (languageCode == 'nia' || languageCode == 'ni') {
        pageTitle = niasWikiPage;
      } else {
        pageTitle = indonesianWikiPage;
      }

      final wikitext = await service.fetchWikitext(pageTitle: pageTitle);
      if (wikitext == null || wikitext.trim().isEmpty) return null;

      final parsedData = TimelineWikiParser.parseTimeline(
        wikitext,
        language: languageCode,
      );
      if (parsedData.milestones.isEmpty) return null;

      // Persist to local app documents directory
      try {
        final docDir = await getApplicationDocumentsDirectory();
        final cacheFile = File('${docDir.path}/timeline_$languageCode.json');
        final exportMap = {
          'language': languageCode,
          'eras': parsedData.eras
              .map((e) => {
                    'id': e.id,
                    'roman': e.roman,
                    'index': e.index,
                    'title': e.title,
                    'period': e.period,
                    'accentColor': e.accentColor,
                  })
              .toList(),
          'milestones': parsedData.milestones
              .map((m) => {
                    'id': m.id,
                    'eraId': m.eraId,
                    'eraIndex': m.eraIndex,
                    'dateDisplay': m.dateDisplay,
                    'title': m.title,
                    'summary': m.summary,
                    'fullDescription': m.fullDescription,
                    'citations': m.citations,
                  })
              .toList(),
        };
        await cacheFile.writeAsString(jsonEncode(exportMap));
      } catch (_) {}

      _cachedData[languageCode] = parsedData;
      return parsedData;
    } catch (_) {
      return null;
    }
  }

  static Future<TimelineData> _loadRaw(String languageCode) async {
    String? jsonString;

    // 1. Try reading from persistent local cache file first
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final cacheFile = File('${docDir.path}/timeline_$languageCode.json');
      if (await cacheFile.exists()) {
        final content = await cacheFile.readAsString();
        if (content.trim().isNotEmpty) {
          jsonString = content;
        }
      }
    } catch (_) {}

    // 2. Fall back to bundled asset JSON
    if (jsonString == null || jsonString.isEmpty) {
      final assetPath = 'assets/data/timeline_$languageCode.json';
      jsonString = await rootBundle.loadString(assetPath);
    }

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
