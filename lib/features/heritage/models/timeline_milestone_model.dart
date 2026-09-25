import 'package:flutter/material.dart';

/// Represents one of the seven historical eras in Nias history.
class TimelineEra {
  final String id;
  final String roman;
  final int index;
  final String title;
  final String period;
  final Color accentColor;

  const TimelineEra({
    required this.id,
    required this.roman,
    required this.index,
    required this.title,
    required this.period,
    required this.accentColor,
  });

  factory TimelineEra.fromJson(Map<String, dynamic> json) {
    Color parseColor(String? hexString) {
      if (hexString == null || hexString.isEmpty) return const Color(0xFFD4AF37);
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    return TimelineEra(
      id: json['id'] as String? ?? '',
      roman: json['roman'] as String? ?? '',
      index: json['index'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      period: json['period'] as String? ?? '',
      accentColor: parseColor(json['accentColor'] as String?),
    );
  }

  TimelineEra copyWith({
    String? title,
    String? period,
  }) {
    return TimelineEra(
      id: id,
      roman: roman,
      index: index,
      title: title ?? this.title,
      period: period ?? this.period,
      accentColor: accentColor,
    );
  }
}

/// Represents a specific milestone event along the Nias history timeline curve.
class TimelineMilestone {
  final String id;
  final String eraId;
  final int eraIndex;
  final String dateDisplay;
  final String title;
  final String summary;
  final String fullDescription;
  final List<String> citations;
  final Color accentColor;

  const TimelineMilestone({
    required this.id,
    required this.eraId,
    required this.eraIndex,
    required this.dateDisplay,
    required this.title,
    required this.summary,
    required this.fullDescription,
    this.citations = const [],
    required this.accentColor,
  });

  factory TimelineMilestone.fromJson(
    Map<String, dynamic> json, {
    Color? fallbackColor,
  }) {
    return TimelineMilestone(
      id: json['id'] as String? ?? '',
      eraId: json['eraId'] as String? ?? '',
      eraIndex: json['eraIndex'] as int? ?? 0,
      dateDisplay: json['dateDisplay'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      fullDescription: json['fullDescription'] as String? ?? '',
      citations: (json['citations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      accentColor: fallbackColor ?? const Color(0xFFD4AF37),
    );
  }

  TimelineMilestone copyWithFallback(TimelineMilestone fallback) {
    return TimelineMilestone(
      id: id,
      eraId: eraId,
      eraIndex: eraIndex,
      dateDisplay: dateDisplay.trim().isNotEmpty ? dateDisplay : fallback.dateDisplay,
      title: title.trim().isNotEmpty ? title : fallback.title,
      summary: summary.trim().isNotEmpty ? summary : fallback.summary,
      fullDescription: fullDescription.trim().isNotEmpty ? fullDescription : fallback.fullDescription,
      citations: citations.isNotEmpty ? citations : fallback.citations,
      accentColor: accentColor,
    );
  }
}
