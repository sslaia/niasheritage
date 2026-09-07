import 'package:flutter/widgets.dart';

/// Represents a distinct section or subsection of a heritage article.
class HeritageArticleSection {
  final String id;
  final String title;
  final int level; // 2 for ##, 3 for ###
  final String markdown;
  final GlobalKey key;

  HeritageArticleSection({
    required this.id,
    required this.title,
    required this.level,
    required this.markdown,
    GlobalKey? key,
  }) : key = key ?? GlobalKey();
}

/// Holds the article preamble (content before first heading) and the parsed sections.
class ParsedHeritageArticle {
  final String introMarkdown;
  final List<HeritageArticleSection> sections;

  const ParsedHeritageArticle({
    required this.introMarkdown,
    required this.sections,
  });

  bool get hasSections => sections.isNotEmpty;
}

/// Parses full markdown content into structured sections based on ## and ### headings.
ParsedHeritageArticle parseHeritageArticle(String markdown) {
  if (markdown.trim().isEmpty) {
    return const ParsedHeritageArticle(introMarkdown: '', sections: []);
  }

  final lines = markdown.split('\n');
  final headingRegex = RegExp(r'^(#{2,3})\s+(.+)$');

  String intro = '';
  final sections = <HeritageArticleSection>[];

  int currentLevel = 0;
  String currentTitle = '';
  final currentLines = <String>[];
  bool foundFirstHeading = false;
  int sectionCounter = 0;

  void flushSection() {
    if (currentLines.isNotEmpty && currentTitle.isNotEmpty) {
      sectionCounter++;
      final cleanTitle = _cleanHeadingTitle(currentTitle);
      sections.add(
        HeritageArticleSection(
          id: 'sec_$sectionCounter',
          title: cleanTitle,
          level: currentLevel,
          markdown: currentLines.join('\n'),
        ),
      );
      currentLines.clear();
    }
  }

  final introLines = <String>[];

  for (final line in lines) {
    final match = headingRegex.firstMatch(line.trimRight());
    if (match != null) {
      if (!foundFirstHeading) {
        foundFirstHeading = true;
        intro = introLines.join('\n').trim();
      } else {
        flushSection();
      }

      currentLevel = match.group(1)!.length; // 2 or 3
      currentTitle = match.group(2)!.trim();
      currentLines.add(line);
    } else {
      if (!foundFirstHeading) {
        introLines.add(line);
      } else {
        currentLines.add(line);
      }
    }
  }

  // Flush remaining lines
  if (foundFirstHeading) {
    flushSection();
  } else {
    intro = introLines.join('\n').trim();
  }

  return ParsedHeritageArticle(
    introMarkdown: intro,
    sections: sections,
  );
}

/// Strips markdown asterisks, links, and footnotes from heading titles for clean TOC display.
String _cleanHeadingTitle(String title) {
  var s = title.trim();
  // Strip bold/italic markdown
  s = s.replaceAll('***', '').replaceAll('**', '').replaceAll('*', '');
  // Strip footnote references [1], [^1], etc.
  s = s.replaceAll(RegExp(r'\[\^?\d+\]'), '');
  // Normalize whitespace
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}
