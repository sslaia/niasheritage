import 'package:flutter/widgets.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import '../../../core/utils/heritage_article_parser.dart';

/// Represents a distinct section or subsection of a heritage article.
class HeritageArticleSection {
  final String id;
  final String title;
  final int level; // 2 for h2, 3 for h3
  final String html;
  final GlobalKey key;

  HeritageArticleSection({
    required this.id,
    required this.title,
    required this.level,
    String? html,
    String? markdown,
    GlobalKey? key,
  })  : html = html ?? markdown ?? '',
        key = key ?? GlobalKey();

  String get markdown => html;
}

/// Holds the article preamble (content before first heading) and the parsed sections.
class ParsedHeritageArticle {
  final String introHtml;
  final List<HeritageArticleSection> sections;

  const ParsedHeritageArticle({
    required this.introHtml,
    required this.sections,
  });

  String get introMarkdown => introHtml;
  bool get hasSections => sections.isNotEmpty;
}

/// Parses HTML or Markdown content into structured sections based on headings.
ParsedHeritageArticle parseHeritageArticle(String content) {
  if (content.trim().isEmpty) {
    return const ParsedHeritageArticle(introHtml: '', sections: []);
  }

  // If content contains HTML tags (<h2, <h3, <p, <div)
  if (content.contains('<h2') || content.contains('<h3') || content.contains('<div') || content.contains('<p')) {
    return _parseHtmlSections(content);
  }

  // Otherwise fallback to markdown line parsing
  return _parseMarkdownSections(content);
}

ParsedHeritageArticle _parseHtmlSections(String html) {
  final fragment = html_parser.parseFragment(html);
  final container = fragment.querySelector('.mw-parser-output') ?? fragment;

  // Clean out all edit section buttons/links, brackets, and dividers completely
  container.querySelectorAll(
    '.mw-editsection, .mw-editsection-bracket, .mw-editsection-divider, .mw-editsection-visualeditor, a[href*="action=edit"], a[href*="veaction=edit"], .mw-empty-elt',
  ).forEach((el) => el.remove());

  final introElements = <dom.Element>[];
  final sections = <HeritageArticleSection>[];
  List<dom.Element>? currentElements;
  String currentTitle = '';
  int currentLevel = 2;
  int sectionCounter = 0;

  void flushSection() {
    if (currentElements != null && currentElements!.isNotEmpty && currentTitle.isNotEmpty) {
      sectionCounter++;
      final cleanTitle = _cleanHeadingTitle(currentTitle);
      final sectionHtml = currentElements!.map((e) => e.outerHtml).join('\n');
      sections.add(
        HeritageArticleSection(
          id: 'sec_$sectionCounter',
          title: cleanTitle,
          level: currentLevel,
          html: sectionHtml,
        ),
      );
      currentElements = null;
    }
  }

  for (final node in container.children) {
    dom.Element? headingEl;
    if (node.localName == 'h2' || node.localName == 'h3') {
      headingEl = node;
    } else {
      headingEl = node.querySelector('h2, h3');
    }

    if (headingEl != null) {
      final rawTitle = headingEl.text.trim();
      final lower = rawTitle.toLowerCase();
      if (lower == 'sumber' ||
          lower == 'references' ||
          lower == 'umbu' ||
          lower == 'pranala luar' ||
          lower == 'lihat pula' ||
          lower == 'catatan kaki') {
        break;
      }

      flushSection();

      currentLevel = headingEl.localName == 'h2' ? 2 : 3;
      currentTitle = rawTitle;
      currentElements = [node];
    } else {
      if (currentElements == null) {
        introElements.add(node);
      } else {
        currentElements!.add(node);
      }
    }
  }

  flushSection();

  final introHtml = introElements.map((e) => e.outerHtml).join('\n').trim();

  if (sections.isEmpty && introHtml.isEmpty) {
    return ParsedHeritageArticle(
      introHtml: html,
      sections: const [],
    );
  }

  return ParsedHeritageArticle(
    introHtml: introHtml,
    sections: sections,
  );
}

ParsedHeritageArticle _parseMarkdownSections(String markdown) {
  var text = markdown;
  if (text.contains('{|')) {
    text = convertWikitablesToMarkdown(text);
  }

  final lines = text.split('\n');
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
          html: currentLines.join('\n'),
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

  if (foundFirstHeading) {
    flushSection();
  } else {
    intro = introLines.join('\n').trim();
  }

  return ParsedHeritageArticle(
    introHtml: intro,
    sections: sections,
  );
}

/// Strips markdown asterisks, links, brackets, and edit tags from heading titles for clean TOC display.
String _cleanHeadingTitle(String title) {
  var s = title.trim();
  s = s.replaceAll('***', '').replaceAll('**', '').replaceAll('*', '');
  s = s.replaceAll(
    RegExp(
      r"\[?\s*(?:edit|sunting|bulö'?ö|bulö’ö)\s*(?:\||/)?\s*(?:bulö'?ö|bulö’ö)?\s*(?:kode|sumber)?\s*\]?",
      caseSensitive: false,
    ),
    '',
  );
  s = s.replaceAll(RegExp(r'\[\^?\d+\]'), '');
  s = s.replaceAll(RegExp(r'\[|\]'), '');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}
