import 'package:flutter/material.dart';
import '../models/timeline_milestone_model.dart';
import 'timeline_repository.dart';

/// Configuration for the 7 historical eras of Nias.
class EraMeta {
  final String id;
  final String roman;
  final int index;
  final String accentColor;

  const EraMeta({
    required this.id,
    required this.roman,
    required this.index,
    required this.accentColor,
  });
}

/// Parser to convert MediaWiki wikitext from Wikipedia into structured [TimelineData].
class TimelineWikiParser {
  const TimelineWikiParser._();

  static const List<EraMeta> eraConfig = [
    EraMeta(id: 'era_i', roman: 'I', index: 0, accentColor: '#6366F1'),
    EraMeta(id: 'era_ii', roman: 'II', index: 1, accentColor: '#D97706'),
    EraMeta(id: 'era_iii', roman: 'III', index: 2, accentColor: '#059669'),
    EraMeta(id: 'era_iv', roman: 'IV', index: 3, accentColor: '#DC2626'),
    EraMeta(id: 'era_v', roman: 'V', index: 4, accentColor: '#0D9488'),
    EraMeta(id: 'era_vi', roman: 'VI', index: 5, accentColor: '#9333EA'),
    EraMeta(id: 'era_vii', roman: 'VII', index: 6, accentColor: '#EA580C'),
  ];

  static Color _parseColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Converts wikitext bold/italics into HTML <b> and <i> tags and strips wiki links/comments.
  static String cleanWikiMarkup(String text) {
    var cleaned = text;
    cleaned = cleaned.replaceAllMapped(RegExp(r"'''(.*?)'''"), (m) => '<b>${m[1]}</b>');
    cleaned = cleaned.replaceAllMapped(RegExp(r"''(.*?)''"), (m) => '<i>${m[1]}</i>');
    cleaned = cleaned.replaceAllMapped(RegExp(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]'), (m) => m[1]!);
    cleaned = cleaned.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    return cleaned.trim();
  }

  /// Parses Wikipedia wikitext into [TimelineData] containing [TimelineEra]s and [TimelineMilestone]s.
  static TimelineData parseTimeline(String wikitext, {String language = 'id'}) {
    final normalized = wikitext.startsWith('\n') ? wikitext : '\n$wikitext';
    final sectionRegex = RegExp(r'\n==\s*([^=]+)\s*==\s*\n');
    final matches = sectionRegex.allMatches(normalized).toList();

    final eras = <TimelineEra>[];
    final milestones = <TimelineMilestone>[];
    int globalMsIdx = 0;
    int refCounter = 0;

    final eraSections = <MapEntry<String, String>>[];

    for (int i = 0; i < matches.length; i++) {
      final header = matches[i].group(1)!.trim();
      final startIndex = matches[i].end;
      final endIndex = (i + 1 < matches.length) ? matches[i + 1].start : normalized.length;
      final body = normalized.substring(startIndex, endIndex);

      final lowerHeader = header.toLowerCase();
      if (lowerHeader.contains('bibliografi') ||
          lowerHeader.contains('bibliography') ||
          lowerHeader.contains('referensi') ||
          lowerHeader.contains('references') ||
          lowerHeader.contains('kategori') ||
          lowerHeader.contains('umbu') ||
          lowerHeader.contains('faigi göi')) {
        continue;
      }
      eraSections.add(MapEntry(header, body));
    }

    for (int eraIdx = 0; eraIdx < eraSections.length; eraIdx++) {
      if (eraIdx >= eraConfig.length) break;

      final cfg = eraConfig[eraIdx];
      final header = eraSections[eraIdx].key;
      final body = eraSections[eraIdx].value;

      final eraHeaderMatch = RegExp(r'^(?:[I|V|X]+)\.\s*(.+?)\s*\((.+?)\)\s*$').firstMatch(header);
      String eraTitle = header;
      String eraPeriod = '';

      if (eraHeaderMatch != null) {
        eraTitle = eraHeaderMatch.group(1)!.trim();
        eraPeriod = eraHeaderMatch.group(2)!.trim();
      }

      eras.add(
        TimelineEra(
          id: cfg.id,
          roman: cfg.roman,
          index: cfg.index,
          title: eraTitle,
          period: eraPeriod,
          accentColor: _parseColor(cfg.accentColor),
        ),
      );

      final lines = body.split('\n');
      final msBlocks = <List<String>>[];
      List<String> currentBlock = [];

      for (final line in lines) {
        final lineS = line.trim();
        if (lineS.startsWith("'''") &&
            lineS.endsWith("'''") &&
            lineS.contains(':') &&
            !lineS.startsWith("''''")) {
          if (currentBlock.isNotEmpty) {
            msBlocks.add(currentBlock);
            currentBlock = [];
          }
          currentBlock.add(lineS);
        } else if (currentBlock.isNotEmpty) {
          currentBlock.add(line);
        }
      }

      if (currentBlock.isNotEmpty) {
        msBlocks.add(currentBlock);
      }

      for (final block in msBlocks) {
        globalMsIdx++;
        final headerLine = block[0].trim();
        final contentLines = block.sublist(1);

        final rawHeader = headerLine.substring(3, headerLine.length - 3).trim();
        final colonIdx = rawHeader.indexOf(':');
        final rawDate = colonIdx != -1 ? rawHeader.substring(0, colonIdx).trim() : rawHeader;
        final rawTitle = colonIdx != -1 ? rawHeader.substring(colonIdx + 1).trim() : '';

        final dateDisplay = cleanWikiMarkup(rawDate);
        var msTitle = cleanWikiMarkup(rawTitle);
        msTitle = msTitle.replaceAll(RegExp(r'</?[bi]>'), '').trim();

        final bodyText = contentLines.join('\n').trim();
        final msCitations = <String>[];

        var bodyWithRefs = bodyText.replaceAllMapped(
          RegExp(r'<ref(?:\s+name=["\x27]?([^"\x27 >]+)["\x27]?)?\s*>(.*?)</ref>', dotAll: true),
          (match) {
            refCounter++;
            final refContent = (match.group(2) ?? '').trim();
            final refContentClean = cleanWikiMarkup(refContent);
            msCitations.add(refContentClean);
            return '[$refCounter]';
          },
        );

        bodyWithRefs = bodyWithRefs.replaceAllMapped(
          RegExp(r'<ref\s+name=["\x27]?([^"\x27 >/]+)["\x27]?\s*/>'),
          (match) => '[$refCounter]',
        );

        final rawParas = bodyWithRefs
            .split('\n\n')
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();

        final cleanedParas = <String>[];
        for (final p in rawParas) {
          var pClean = cleanWikiMarkup(p);
          pClean = pClean.replaceAll(RegExp(r'(?<!\n)\n(?!\n)'), ' ');
          cleanedParas.add(pClean);
        }

        final fullDesc = cleanedParas.join('\n\n');
        final summary = cleanedParas.isNotEmpty ? cleanedParas.first : '';
        final msId = 'ms_${cfg.index + 1}_$globalMsIdx';

        milestones.add(
          TimelineMilestone(
            id: msId,
            eraId: cfg.id,
            eraIndex: cfg.index,
            dateDisplay: dateDisplay,
            title: msTitle,
            summary: summary,
            fullDescription: fullDesc,
            citations: msCitations,
            accentColor: _parseColor(cfg.accentColor),
          ),
        );
      }
    }

    return TimelineData(eras: eras, milestones: milestones);
  }
}
