import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../../../core/wikimedia/dynamic_html_rules.dart';
import '../../../core/utils/heritage_article_parser.dart'
    show convertWikitablesToMarkdown;

/// The 7 distinct topical sections of Nias Heritage.
enum HeritageSection {
  origin(
    category: 'origin',
    pageId: 5050,
    rawPageTitle: 'Böröta Nono Niha',
    accentColor: Color(0xFF6366F1), // Indigo
    heroImagePath: 'assets/images/origin.webp',
    titleKey: 'heritage.origin_title',
    descKey: 'heritage.origin_desc',
    badgeKey: 'heritage_badges.origin',
    icon: Icons.explore_rounded,
  ),
  timeline(
    category: 'timeline',
    pageId: 5053,
    rawPageTitle: 'Ofanöŵa Ginötö',
    accentColor: Color(0xFFEA580C), // Deep Orange
    heroImagePath: 'assets/images/timeline.webp',
    titleKey: 'heritage.timeline_title',
    descKey: 'heritage.timeline_desc',
    badgeKey: 'heritage_badges.timeline',
    icon: Icons.timeline_rounded,
  ),
  architecture(
    category: 'architecture',
    pageId: 5038,
    rawPageTitle: 'Fangotomosi Omo Niha',
    accentColor: Color(0xFFD97706), // Amber
    heroImagePath: 'assets/images/architecture.webp',
    titleKey: 'heritage.architecture_title',
    descKey: 'heritage.architecture_desc',
    badgeKey: 'heritage_badges.architecture',
    icon: Icons.home_work_rounded,
  ),
  megalith(
    category: 'megalith',
    pageId: 5039,
    rawPageTitle: 'Gowe Megalit',
    accentColor: Color(0xFF059669), // Emerald
    heroImagePath: 'assets/images/megalith.webp',
    titleKey: 'heritage.megalith_title',
    descKey: 'heritage.megalith_desc',
    badgeKey: 'heritage_badges.megalith',
    icon: Icons.landscape_rounded,
  ),
  arts(
    category: 'arts',
    pageId: 5040,
    rawPageTitle: 'Nekhe-Nekhe',
    accentColor: Color(0xFFDC2626), // Crimson Red
    heroImagePath: 'assets/images/arts.webp',
    titleKey: 'heritage.arts_title',
    descKey: 'heritage.arts_desc',
    badgeKey: 'heritage_badges.arts',
    icon: Icons.theater_comedy_rounded,
  ),
  clothing(
    category: 'clothing',
    pageId: 5044,
    rawPageTitle: 'Baru ba Gama-Gama',
    accentColor: Color(0xFF7C3AED), // Royal Violet
    heroImagePath: 'assets/images/clothing.webp',
    titleKey: 'heritage.clothing_title',
    descKey: 'heritage.clothing_desc',
    badgeKey: 'heritage_badges.clothing',
    icon: Icons.checkroom_rounded,
  ),
  village(
    category: 'village',
    pageId: 5046,
    rawPageTitle: 'Banua ba Amakhoita',
    accentColor: Color(0xFF0891B2), // Teal Cyan
    heroImagePath: 'assets/images/village.webp',
    titleKey: 'heritage.village_title',
    descKey: 'heritage.village_desc',
    badgeKey: 'heritage_badges.village',
    icon: Icons.holiday_village_rounded,
  );

  final String category;
  final int pageId;
  final String rawPageTitle;
  final Color accentColor;
  final String heroImagePath;
  final String titleKey;
  final String descKey;
  final String badgeKey;
  final IconData icon;

  const HeritageSection({
    required this.category,
    required this.pageId,
    required this.rawPageTitle,
    required this.accentColor,
    required this.heroImagePath,
    required this.titleKey,
    required this.descKey,
    required this.badgeKey,
    required this.icon,
  });

  /// Sanitized MediaWiki title with underscores instead of spaces.
  String get sanitizedPageTitle => rawPageTitle.trim().replaceAll(' ', '_');

  /// Locates a [HeritageSection] matching a category string, if any.
  static HeritageSection? fromCategory(String category) {
    for (final s in HeritageSection.values) {
      if (s.category == category) return s;
    }
    return null;
  }
}

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
  }) : html = html ?? markdown ?? '',
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

  bool get hasSections => sections.isNotEmpty;
}

/// Parses HTML or Markdown content into structured sections based on headings.
ParsedHeritageArticle parseHeritageArticle(String content) {
  if (content.trim().isEmpty) {
    return const ParsedHeritageArticle(introHtml: '', sections: []);
  }

  // If content contains HTML tags (<h2, <h3, <p, <div)
  if (content.contains('<h2') ||
      content.contains('<h3') ||
      content.contains('<div') ||
      content.contains('<p')) {
    return _parseHtmlSections(content);
  }

  // Otherwise fallback to markdown line parsing
  return _parseMarkdownSections(content);
}

ParsedHeritageArticle _parseHtmlSections(String html) {
  final fragment = html_parser.parseFragment(html);
  final container = fragment.querySelector('.mw-parser-output') ?? fragment;

  // Clean out all edit section buttons/links, brackets, and dividers completely
  container
      .querySelectorAll(
        '.mw-editsection, .mw-editsection-bracket, .mw-editsection-divider, .mw-editsection-visualeditor, .mw-empty-elt',
      )
      .forEach((el) => el.remove());

  // Remove standalone heading edit links while strictly preserving red links (missing articles)
  container
      .querySelectorAll('a[href*="action=edit"], a[href*="veaction=edit"]')
      .forEach((el) {
        final href = (el.attributes['href'] ?? '').toLowerCase();
        final isRedLink = href.contains('redlink=1') || el.classes.contains('new');
        if (!isRedLink) {
          el.remove();
        }
      });

  final introElements = <dom.Element>[];
  final sections = <HeritageArticleSection>[];
  List<dom.Element>? currentElements;
  String currentTitle = '';
  int currentLevel = 2;
  int sectionCounter = 0;

  void flushSection() {
    if (currentElements != null &&
        currentElements!.isNotEmpty &&
        currentTitle.isNotEmpty) {
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
      if (const DynamicHtmlRules().isReferenceHeading(rawTitle)) {
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
    return ParsedHeritageArticle(introHtml: html, sections: const []);
  }

  return ParsedHeritageArticle(introHtml: introHtml, sections: sections);
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

  return ParsedHeritageArticle(introHtml: intro, sections: sections);
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
