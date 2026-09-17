import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import '../utils/heritage_article_parser.dart' show ArticleFootnote, convertWikitablesToMarkdown;
import 'dynamic_html_rules.dart';

/// Result produced by [HtmlProcessor.process].
class ProcessedArticle {
  final String title;
  final String html;
  final String textContent;
  final String? heroImageUrl;
  final List<ArticleFootnote> footnotes;

  const ProcessedArticle({
    required this.title,
    required this.html,
    required this.textContent,
    this.heroImageUrl,
    this.footnotes = const [],
  });
}

/// Robust HTML sanitizer and processor implementing the wikimedia-article-engine architecture.
class HtmlProcessor {
  final DynamicHtmlRules rules;

  const HtmlProcessor({this.rules = const DynamicHtmlRules()});

  /// Processes raw MediaWiki HTML or mixed Wikibooks content into clean, responsive HTML.
  ProcessedArticle process({
    required String rawContent,
    String defaultTitle = '',
    bool hideHeroImageInBody = true,
  }) {
    if (rawContent.trim().isEmpty) {
      return ProcessedArticle(
        title: defaultTitle,
        html: '',
        textContent: '',
      );
    }

    var content = rawContent;

    // 1. If content contains Wikitable syntax ({| ... |}), convert to Markdown/HTML tables first
    if (content.contains('{|')) {
      content = convertWikitablesToMarkdown(content);
    }

    // 2. Pre-process Wikibooks/Incubator bracket links & files if present
    content = _preprocessWikiMarkup(content);

    // Parse into HTML document
    final doc = html_parser.parse(content);
    final container = doc.querySelector('.mw-parser-output, .mw-content-ltr') ?? doc.body ?? doc.documentElement!;

    // 3. Unwrap MediaWiki lazy loaded images (<noscript><img ...></noscript>)
    _unwrapLazyImages(container);

    // 4. Extract Footnotes before removing references section
    final footnotes = _extractFootnotes(container);

    // 5. Remove clutter, edit links, scripts, and navigation boxes according to dynamic rules
    _applyRemovalRules(container);

    // 6. Extract Hero Image Candidate and mark original container to avoid duplicate rendering
    final heroImageUrl = _extractHeroImage(container, hideHeroInBody: hideHeroImageInBody);

    // 7. Optimize Wikimedia / Commons Image URLs
    _optimizeImages(container);

    // 8. Wrap tables in responsive auto-scrolling containers
    _wrapTablesResponsively(container);

    // 9. Extract sanitized title
    final heading = doc.querySelector('#firstHeading, .firstHeading, h1');
    final title = heading?.text.trim().isNotEmpty == true ? heading!.text.trim() : defaultTitle;

    final cleanedHtml = container.innerHtml.trim();
    final textContent = container.text.trim();

    return ProcessedArticle(
      title: title,
      html: cleanedHtml,
      textContent: textContent,
      heroImageUrl: heroImageUrl,
      footnotes: footnotes,
    );
  }

  /// Preprocesses wikitext tags commonly encountered in Wikibooks and Wikimedia Incubator articles.
  String _preprocessWikiMarkup(String raw) {
    var s = raw;

    // Remove wiki template tags like {{Wb/nia/...}} or {{reflist}}
    s = s.replaceAll(RegExp(r'\{\{[^\}]+\}\}', caseSensitive: false), '');

    // Strip categories [[Category:...]], [[Kategori:...]], or unbracketed Category:... / Kategori:...
    s = s.replaceAll(RegExp(r'(?:\[\[)?(?:Category|Kategori):[^\n\]<]+(?:\]\])?', caseSensitive: false), '');

    // Strip MediaWiki magic words like __TOC__, __NOTOC__
    s = s.replaceAll(RegExp(r'__[A-Z]+__'), '');

    // Convert [[File:...]] / [[Berkas:...]] embeds to standard <img> tags
    s = s.replaceAllMapped(
      RegExp(r'\[\[(?:File|Berkas|Gambar|Image):([^|\]]+)(?:\|([^\]]*))?\]\]', caseSensitive: false),
      (match) {
        final rawFileName = match.group(1)?.trim() ?? '';
        final rest = match.group(2) ?? '';
        final parts = rest.split('|').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

        // Extract caption if present
        String caption = '';
        for (final p in parts.reversed) {
          final lower = p.toLowerCase().trim();
          final isSize = RegExp(r'^(?:\d+x)?\d+px$|^x\d+px$', caseSensitive: false).hasMatch(lower);
          final isPosition = {'left', 'right', 'center', 'none', 'kiri', 'kanan', 'tengah', 'tidakada'}.contains(lower);
          final isFrame = {'thumb', 'thumbnail', 'jmpl', 'mini', 'frame', 'frameless', 'tanpabingkai', 'bingkai', 'border'}.contains(lower);
          final isParam = lower.startsWith('alt=') || lower.startsWith('link=') || lower.startsWith('upright') || lower.startsWith('class=');
          if (!isSize && !isPosition && !isFrame && !isParam) {
            caption = p;
            break;
          }
        }

        final cleanFileName = rawFileName.replaceAll(' ', '_');
        final encodedFileName = Uri.encodeComponent(cleanFileName);
        final imageUrl = 'https://commons.wikimedia.org/wiki/Special:FilePath/$encodedFileName?width=800';

        return '''
<figure class="thumb tright">
  <img src="$imageUrl" alt="$caption" class="thumbimage" />
  ${caption.isNotEmpty ? '<figcaption class="thumbcaption">$caption</figcaption>' : ''}
</figure>
''';
      },
    );

    // Convert internal wiki links [[Target|Label]] -> <a href="/wiki/Target">Label</a>
    s = s.replaceAllMapped(
      RegExp(r'\[\[([^|\]]+)(?:\|([^\]]+))?\]\]'),
      (match) {
        final target = match.group(1)!.trim();
        final label = match.group(2)?.trim() ?? target;
        final cleanTarget = target.replaceAll(' ', '_');
        return '<a href="/wiki/$cleanTarget">$label</a>';
      },
    );

    // Convert MediaWiki Headings
    s = s.replaceAllMapped(
      RegExp(r'^\s*====\s*(.*?)\s*====\s*$', multiLine: true),
      (m) => '\n\n<h4>${m.group(1)?.trim()}</h4>\n\n',
    );
    s = s.replaceAllMapped(
      RegExp(r'^\s*===\s*(.*?)\s*===\s*$', multiLine: true),
      (m) => '\n\n<h3>${m.group(1)?.trim()}</h3>\n\n',
    );
    s = s.replaceAllMapped(
      RegExp(r'^\s*==\s*(.*?)\s*==\s*$', multiLine: true),
      (m) => '\n\n<h2>${m.group(1)?.trim()}</h2>\n\n',
    );
    s = s.replaceAllMapped(
      RegExp(r'^\s*=\s*(.*?)\s*=\s*$', multiLine: true),
      (m) => '\n\n<h1>${m.group(1)?.trim()}</h1>\n\n',
    );

    // Convert wikitext bold and italic
    s = s.replaceAllMapped(RegExp(r"'''''(.*?)'''''"), (m) => '<b><i>${m.group(1)}</i></b>');
    s = s.replaceAllMapped(RegExp(r"'''(.*?)'''"), (m) => '<b>${m.group(1)}</b>');
    s = s.replaceAllMapped(RegExp(r"''(.*?)''"), (m) => '<i>${m.group(1)}</i>');

    // Convert horizontal rules
    s = s.replaceAll(RegExp(r'^\s*----\s*$', multiLine: true), '\n\n<hr>\n\n');

    // Ensure protocol-relative images have https:
    s = s.replaceAll('src="//', 'src="https://');

    // If the content is not already wrapped in paragraph tags, convert double-newline blocks into <p> tags
    if (!s.contains('<p>') && !s.contains('<p ')) {
      final paragraphs = s.split(RegExp(r'\n\s*\n'));
      s = paragraphs.map((p) {
        final trimmed = p.trim();
        if (trimmed.isEmpty) return '';
        if (trimmed.startsWith('<div') ||
            trimmed.startsWith('<figure') ||
            trimmed.startsWith('<table') ||
            trimmed.startsWith('<h1') ||
            trimmed.startsWith('<h2') ||
            trimmed.startsWith('<h3') ||
            trimmed.startsWith('<h4') ||
            trimmed.startsWith('<hr') ||
            trimmed.startsWith('<ul') ||
            trimmed.startsWith('<ol') ||
            trimmed.startsWith('<blockquote')) {
          return trimmed;
        }
        final lines = trimmed.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).join('<br>');
        return '<p>$lines</p>';
      }).where((p) => p.isNotEmpty).join('\n');
    }

    return s;
  }

  /// Unwraps images stored inside `<noscript>` tags used by MediaWiki lazy-loading.
  void _unwrapLazyImages(dom.Element container) {
    final noscripts = container.querySelectorAll('noscript');
    for (final ns in noscripts) {
      final nsHtml = ns.innerHtml;
      if (nsHtml.contains('<img')) {
        final fragment = html_parser.parseFragment(nsHtml);
        ns.parentNode?.insertBefore(fragment, ns);
      }
      ns.remove();
    }
    container.querySelectorAll('.lazy-image-placeholder').forEach((el) => el.remove());
  }

  /// Extracts structured footnotes from `<ol class="references">` or citation list items.
  List<ArticleFootnote> _extractFootnotes(dom.Element container) {
    final footnotes = <ArticleFootnote>[];
    final refElements = container.querySelectorAll('ol.references > li, li[id*="cite_note"], li[id*="cite&#95;note"]');

    int indexCounter = 1;
    for (final ref in refElements) {
      final rawId = ref.attributes['id'] ?? 'cite_note-$indexCounter';
      final normalizedId = rawId.replaceAll('&#95;', '_');

      // Remove backlink arrow inside footnote text
      ref.querySelectorAll('.mw-cite-backlink, a[href^="#cite_ref-"]').forEach((el) => el.remove());

      final refText = ref.text.trim();
      String? refUrl;
      final extLink = ref.querySelector('a.external, a[href^="http"]');
      if (extLink != null) {
        refUrl = extLink.attributes['href'];
      }

      footnotes.add(ArticleFootnote(
        index: indexCounter,
        id: normalizedId,
        text: refText,
        url: refUrl,
      ));
      indexCounter++;
    }

    return footnotes;
  }

  /// Removes unwanted elements according to dynamic rules.
  void _applyRemovalRules(dom.Element container) {
    // 1. Explicit removal selectors
    for (final selector in rules.removeSelectors) {
      container.querySelectorAll(selector).forEach((el) => el.remove());
    }

    // 2. Hide or suppress reference/bibliography blocks from inline scroll flow
    for (final selector in rules.hideSelectors) {
      container.querySelectorAll(selector).forEach((el) => el.remove());
    }

    // 3. Remove section headings and trailing content matching reference/appendix keywords
    final headings = container.querySelectorAll('h1, h2, h3, h4, h5, h6');
    for (final heading in headings) {
      final headingText = heading.text.trim();
      final headingId = (heading.attributes['id'] ?? '').replaceAll('_', ' ').trim();
      if (rules.isReferenceHeading(headingText) || rules.isReferenceHeading(headingId)) {
        // If wrapped in a heading container (e.g. MediaWiki's div.mw-heading), target the container
        dom.Element target = heading;
        if (heading.parent != null &&
            heading.parent != container &&
            heading.parent!.classes.contains('mw-heading')) {
          target = heading.parent!;
        }

        // Remove target and all subsequent siblings in its parent
        final parent = target.parent;
        if (parent != null) {
          final siblings = parent.children.toList();
          final targetIdx = siblings.indexOf(target);
          if (targetIdx != -1) {
            for (int i = siblings.length - 1; i >= targetIdx; i--) {
              siblings[i].remove();
            }
          }
        } else {
          target.remove();
        }
        break;
      }
    }
  }

  /// Identifies the first non-icon image in the document as hero image, and optionally
  /// marks its container with class `hidden-hero-container` to avoid duplicate display.
  String? _extractHeroImage(dom.Element container, {required bool hideHeroInBody}) {
    final images = container.querySelectorAll('img');
    for (final img in images) {
      final src = img.attributes['src'] ?? '';
      if (src.isEmpty || isIcon(src)) continue;

      final optimizedUrl = cleanWikimediaImageUrl(src);
      if (optimizedUrl.isNotEmpty) {
        if (hideHeroInBody) {
          // Find the enclosing figure, thumb, or infobox container
          dom.Element? targetContainer = img;
          while (targetContainer != null && targetContainer != container) {
            final classes = targetContainer.classes;
            final tag = targetContainer.localName;
            if (tag == 'figure' ||
                classes.contains('thumb') ||
                classes.contains('tright') ||
                classes.contains('tleft') ||
                classes.contains('infobox-image') ||
                classes.contains('thumbinner')) {
              break;
            }
            targetContainer = targetContainer.parent;
          }

          if (targetContainer != null && targetContainer != container) {
            targetContainer.classes.add('hidden-hero-container');
          } else {
            img.classes.add('hidden-hero-container');
          }
        }
        return optimizedUrl;
      }
    }
    return null;
  }

  /// Rewrites image URLs for responsive display, adds protocol, and flags inline icons.
  void _optimizeImages(dom.Element container) {
    final images = container.querySelectorAll('img');
    for (final img in images) {
      var src = img.attributes['src'] ?? '';
      if (src.isEmpty) continue;

      final isAnIcon = isIcon(src);
      final optimized = cleanWikimediaImageUrl(src);
      img.attributes['src'] = optimized;

      if (isAnIcon) {
        img.classes.add('wiki-inline-icon');
      }
    }
  }

  /// Wraps tables in horizontally auto-scrolling container divs to prevent layout overflows.
  void _wrapTablesResponsively(dom.Element container) {
    final tables = container.querySelectorAll('table');
    for (final table in tables) {
      // Avoid double-wrapping if already inside a scroll container
      if (table.parent?.classes.contains('wiki-table-scroll-wrapper') == true) {
        continue;
      }

      table.attributes['style'] = 'width: 100%; border-collapse: collapse; margin: 12px 0;';

      final wrapper = dom.Element.tag('div')
        ..classes.add('wiki-table-scroll-wrapper')
        ..attributes['style'] = 'overflow-x: auto; width: 100%; -webkit-overflow-scrolling: touch; margin: 12px 0;';

      table.parentNode?.insertBefore(wrapper, table);
      wrapper.append(table);
    }
  }

  /// Highlights search query occurrences inside the HTML text nodes.
  static String highlightSearchQuery(String html, String query) {
    final q = query.trim();
    if (q.isEmpty || html.isEmpty) return html;

    final doc = html_parser.parseFragment(html);
    int matchCounter = 0;

    void processNode(dom.Node node) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        final text = node.text ?? '';
        final lowerText = text.toLowerCase();
        final lowerQuery = q.toLowerCase();

        if (lowerText.contains(lowerQuery)) {
          final parent = node.parentNode;
          if (parent == null) return;
          if (parent is dom.Element && (parent.localName == 'script' || parent.localName == 'style')) {
            return;
          }

          final parts = <dom.Node>[];
          int lastIdx = 0;

          while (true) {
            final matchIdx = lowerText.indexOf(lowerQuery, lastIdx);
            if (matchIdx == -1) break;

            if (matchIdx > lastIdx) {
              parts.add(dom.Text(text.substring(lastIdx, matchIdx)));
            }

            final matchedText = text.substring(matchIdx, matchIdx + q.length);
            final highlightSpan = dom.Element.tag('span')
              ..classes.add('search-highlight')
              ..attributes['data-index'] = '$matchCounter'
              ..text = matchedText;

            parts.add(highlightSpan);
            matchCounter++;
            lastIdx = matchIdx + q.length;
          }

          if (lastIdx < text.length) {
            parts.add(dom.Text(text.substring(lastIdx)));
          }

          for (final p in parts) {
            parent.insertBefore(p, node);
          }
          node.remove();
        }
      } else {
        final children = List<dom.Node>.from(node.nodes);
        for (final child in children) {
          processNode(child);
        }
      }
    }

    final rootChildren = List<dom.Node>.from(doc.nodes);
    for (final child in rootChildren) {
      processNode(child);
    }

    return doc.outerHtml;
  }

  /// Determines if an image URL corresponds to an icon or technical graphic rather than
  /// article photography.
  static bool isIcon(String src) {
    final lower = src.toLowerCase();
    return lower.contains('gnome') ||
        lower.contains('ambox') ||
        lower.contains('question_book') ||
        lower.contains('disambig') ||
        lower.contains('edit-clear') ||
        lower.contains('padlock') ||
        lower.contains('wikimedia-button') ||
        lower.contains('magnifying_glass') ||
        lower.contains('sound-icon') ||
        lower.contains('speaker') ||
        lower.contains('red_pog') ||
        lower.contains('blue_pog') ||
        lower.contains('icon') ||
        lower.endsWith('.svg');
  }

  /// Cleans and optimizes a Wikimedia image URL.
  static String cleanWikimediaImageUrl(String rawSrc) {
    var src = rawSrc.trim();
    if (src.isEmpty) return '';

    if (src.startsWith('//')) {
      src = 'https:$src';
    }

    // Strip trailing query parameters (?utm=..., etc.), except for Special:FilePath and Special:Redirect which require ?width=...
    if (src.contains('?') && !src.contains('Special:FilePath') && !src.contains('Special:Redirect')) {
      src = src.split('?').first;
    }

    src = src.replaceAll('&amp;', '&');

    // Standardize thumb widths to 500px
    if (src.contains('/thumb/')) {
      final parts = src.split('/');
      final last = parts.last;
      final match = RegExp(r'^\d+px-(.+)').firstMatch(last);
      if (match != null) {
        final originalName = match.group(1)!;
        parts.removeLast();
        parts.add('500px-$originalName');
        src = parts.join('/');
      }
    }

    return src;
  }
}
