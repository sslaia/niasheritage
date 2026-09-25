import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../core/utils/heritage_article_parser.dart';
import '../../../core/utils/url_launcher_utils.dart';
import '../../../core/wikimedia/wiki_config.dart';
import '../../../core/wikimedia/wiki_link_intent.dart';
import '../../../core/widgets/full_screen_image_viewer.dart';
import '../models/heritage_section_model.dart';

class HeritageArticleContentView extends StatelessWidget {
  final String htmlContent;
  final List<ArticleFootnote> footnotes;
  final Color accentColor;
  final void Function(ArticleFootnote footnote) onFootnoteTap;
  final Function? onArticleTap;
  final void Function(String audioUrl)? onAudioTap;
  final List<HeritageArticleSection>? sections;
  final String? introHtml;
  final bool hideHeroInBody;
  final String defaultWikiHost;

  const HeritageArticleContentView({
    super.key,
    required this.htmlContent,
    required this.footnotes,
    required this.accentColor,
    required this.onFootnoteTap,
    this.onArticleTap,
    this.onAudioTap,
    this.sections,
    this.introHtml,
    this.hideHeroInBody = false,
    this.defaultWikiHost = 'nia.wikipedia.org',
  });

  String get _effectiveIntro => introHtml ?? '';

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  bool _handleUrlTap(String url) {
    final intent = parseWikiLink(url, defaultWikiHost: defaultWikiHost);

    switch (intent) {
      case ShowReferenceIntent(:final referenceId, :final index):
        final cleanId = referenceId.replaceFirst(RegExp(r'^(footnote-|cite_note-|fn-|cite_ref-)'), '');

        // Check footnotes list, falling back to on-the-fly extraction from htmlContent
        List<ArticleFootnote> activeFootnotes = footnotes;
        if (activeFootnotes.isEmpty && htmlContent.isNotEmpty) {
          activeFootnotes = parseHeritageArticleHtml(htmlText: htmlContent, defaultTitle: '').footnotes;
        }

        // 1. Direct ID match (comparing normalized forms)
        for (final f in activeFootnotes) {
          final fNorm = f.id.replaceAll('&#95;', '_');
          final fClean = fNorm.replaceFirst(RegExp(r'^(footnote-|cite_note-|fn-|cite_ref-)'), '');
          if (fNorm == referenceId ||
              fClean == cleanId ||
              'cite_note-$fClean' == referenceId ||
              '#$fNorm' == url.replaceAll('&#95;', '_') ||
              f.id == cleanId ||
              f.id == referenceId) {
            onFootnoteTap(f);
            return true;
          }
        }

        // 2. Numeric match (e.g. cite_note-1 -> index 1)
        for (final f in activeFootnotes) {
          if (f.index == index) {
            onFootnoteTap(f);
            return true;
          }
        }

        // 3. Fallback: If no matching footnote found by index in activeFootnotes, still show bottom sheet
        onFootnoteTap(ArticleFootnote(index: index, id: 'cite_note-$index', text: ''));
        return true;

      case PlayAudioIntent(:final audioUrl):
        if (onAudioTap != null) {
          onAudioTap!(audioUrl);
        }
        return true;

      case NavigateToArticleIntent(:final title, :final isRedLink, :final wikiHost):
        if (onArticleTap != null) {
          final fn = onArticleTap!;
          if (fn is void Function(String, bool, String?)) {
            fn(title, isRedLink, wikiHost);
          } else if (fn is void Function(String, bool)) {
            fn(title, isRedLink);
          } else {
            try {
              (fn as dynamic)(title, isRedLink, wikiHost);
            } catch (_) {
              (fn as dynamic)(title, isRedLink);
            }
          }
          return true;
        }
        final host = wikiHost ?? (title.startsWith('Wb/nia') ? WikiConfig.incubatorHost : 'nia.wikipedia.org');
        final fallbackUrl = 'https://$host/wiki/${Uri.encodeComponent(title.replaceAll(' ', '_'))}';
        openInAppBrowserUrl(fallbackUrl);
        return true;

      case OpenExternalUrlIntent(:final url):
        openInAppBrowserUrl(url);
        return true;

      case IgnoreLinkIntent():
        return false;
    }
  }

  Map<String, String>? _buildCustomStyles(dynamic element, BuildContext context) {
    final tagName = element.localName as String?;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? '#444c56' : '#d0d7de';
    final thBg = isDark ? '#21262d' : '#f6f8fa';
    final accentHex = _colorToHex(accentColor);
    final blockquoteBg = _colorToHex(accentColor.withValues(alpha: 0.08));

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final h1Size = (20 * textScale).round();
    final h2Size = (18 * textScale).round();
    final h3Size = (16 * textScale).round();
    final h4Size = (14 * textScale).round();
    final cellSize = (13 * textScale).round();

    if (tagName == 'table') {
      return {
        'border-collapse': 'collapse',
        'margin-top': '12px',
        'margin-bottom': '16px',
        'border': '1px solid $borderColor',
        'min-width': '100%',
      };
    }
    if (tagName == 'th') {
      return {
        'background-color': thBg,
        'color': accentHex,
        'padding': '10px 14px',
        'border': '1px solid $borderColor',
        'text-align': 'left',
        'font-weight': 'bold',
        'font-size': '${cellSize}px',
        'min-width': '130px',
      };
    }
    if (tagName == 'td') {
      return {
        'padding': '10px 14px',
        'border': '1px solid $borderColor',
        'font-size': '${cellSize}px',
        'min-width': '130px',
      };
    }
    if (element.classes.contains('reference') || tagName == 'sup') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'text-decoration': 'none',
        'font-size': '${(11 * textScale).round()}px',
      };
    }
    if (tagName == 'a') {
      final href = (element.attributes['href'] as String? ?? '').toLowerCase();
      final isRedLink = element.classes.contains('new') || href.contains('redlink=1');
      final linkColor = isRedLink
          ? (isDark ? '#e57373' : '#ba0000')
          : accentHex;
      return {
        'color': linkColor,
        'text-decoration': 'none',
        'font-weight': '600',
      };
    }
    if (tagName == 'p') {
      return {
        'margin-top': '0px',
        'margin-bottom': '12px',
      };
    }
    if (tagName == 'h1') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'margin-top': '24px',
        'margin-bottom': '6px',
        'font-size': '${h1Size}px',
        'line-height': '1.3',
      };
    }
    if (tagName == 'h2') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'margin-top': '22px',
        'margin-bottom': '6px',
        'font-size': '${h2Size}px',
        'line-height': '1.3',
      };
    }
    if (tagName == 'h3') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'margin-top': '18px',
        'margin-bottom': '6px',
        'font-size': '${h3Size}px',
        'line-height': '1.3',
      };
    }
    if (tagName == 'h4') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'margin-top': '14px',
        'margin-bottom': '4px',
        'font-size': '${h4Size}px',
        'line-height': '1.3',
      };
    }
    if (element.classes.contains('mw-heading')) {
      return {
        'margin-top': '0px',
        'margin-bottom': '0px',
      };
    }
    if (tagName == 'blockquote') {
      return {
        'background-color': blockquoteBg,
        'border-left': '4px solid $accentHex',
        'padding': '10px 16px',
        'margin': '12px 0',
        'font-style': 'italic',
      };
    }
    if (element.classes.contains('hidden-hero-container') && hideHeroInBody) {
      return {'display': 'none'};
    }
    if (element.classes.contains('search-highlight')) {
      return {
        'background-color': '#fde047',
        'color': '#000000',
        'padding': '1px 3px',
        'border-radius': '3px',
        'font-weight': 'bold',
      };
    }
    if (element.classes.contains('wiki-inline-icon') || element.classes.contains('heritage-inline-icon')) {
      return {
        'max-height': '1.2em',
        'vertical-align': 'middle',
      };
    }
    if (element.classes.contains('mw-editsection') ||
        element.classes.contains('mw-editsection-bracket') ||
        element.classes.contains('mw-editsection-divider') ||
        element.classes.contains('mw-editsection-visualeditor') ||
        element.classes.contains('infobox') ||
        element.classes.contains('infobox_v3') ||
        element.classes.contains('infobox_v2') ||
        element.classes.contains('infobox-subbox') ||
        element.classes.contains('sidebar') ||
        element.classes.contains('vertical-navbox') ||
        (tagName == 'table' && element.classes.contains('vcard')) ||
        element.id == 'toc' ||
        element.classes.contains('toc') ||
        element.classes.contains('mw-empty-elt')) {
      return {'display': 'none'};
    }
    return null;
  }

  Widget? _buildCustomWidget(dynamic element, BuildContext context) {
    final classes = element.classes as Set<dynamic>? ?? {};
    final tagName = element.localName as String?;

    // General Rule: Never show infoboxes or sidebars
    if (classes.contains('infobox') ||
        classes.contains('infobox_v3') ||
        classes.contains('infobox_v2') ||
        classes.contains('infobox-subbox') ||
        classes.contains('sidebar') ||
        classes.contains('vertical-navbox') ||
        (tagName == 'table' && classes.contains('vcard'))) {
      return const SizedBox.shrink();
    }

    // Hide hero image container inside article body when displayed in hero header
    if (classes.contains('hidden-hero-container') && hideHeroInBody) {
      return const SizedBox.shrink();
    }

    // Hide edit section completely (e.g. [bulö'ö | bulö'ö kode] / [sunting | sunting sumber])
    if (classes.contains('mw-editsection') ||
        classes.contains('mw-editsection-bracket') ||
        classes.contains('mw-editsection-divider') ||
        classes.contains('mw-editsection-visualeditor') ||
        classes.contains('mw-empty-elt')) {
      return const SizedBox.shrink();
    }

    // Hide any edit action anchor links (except red links, which represent missing articles with valid text)
    if (tagName == 'a') {
      final href = (element.attributes['href'] as String? ?? '').toLowerCase();
      final isRedLink = href.contains('redlink=1') || classes.contains('new');
      if (!isRedLink && (href.contains('action=edit') || href.contains('veaction=edit'))) {
        return const SizedBox.shrink();
      }
    }

    // Hide inline bottom references list since footnotes are displayed in bottom sheet on tap
    if (classes.contains('reflist') ||
        classes.contains('mw-references-wrap') ||
        classes.contains('references') ||
        element.id == 'references') {
      return const SizedBox.shrink();
    }

    // Hide footnote & incubator navigation subheadings as footnotes are handled via bottom sheets
    if (tagName == 'h1' ||
        tagName == 'h2' ||
        tagName == 'h3' ||
        tagName == 'h4' ||
        tagName == 'h5' ||
        tagName == 'h6' ||
        classes.contains('mw-heading')) {
      final text = (element.text as String? ?? '').trim().toLowerCase();
      final id = (element.id as String? ?? '').toLowerCase();
      if (text.startsWith('famotokhi ba gahe') || id.contains('famotokhi_ba_gahe') || text == 'famotokhi') {
        return const SizedBox.shrink();
      }
      if (text.startsWith('fabaliŵa lala') ||
          text.startsWith('fabaliwa lala') ||
          id.contains('fabaliwa_lala') ||
          id.contains('fabaliŵa_lala') ||
          text.startsWith('bale zato') ||
          id.contains('bale_zato')) {
        return const SizedBox.shrink();
      }
    }

    // 1. Intercept galleries (<ul class="gallery"> or <div class="gallery">)
    if (classes.contains('gallery')) {
      return _buildNativeGallery(context, element);
    }

    // 2. Intercept figures and thumbnails (<figure typeof="mw:File/Thumb"> or .thumb)
    final isFigureOrThumb = tagName == 'figure' ||
        classes.contains('thumb') ||
        classes.contains('tright') ||
        classes.contains('tleft') ||
        (element.attributes['typeof'] as String? ?? '').contains('mw:File/Thumb');

    if (isFigureOrThumb) {
      if (classes.contains('hidden-hero-container') && hideHeroInBody) {
        return const SizedBox.shrink();
      }

      final img = tagName == 'img' ? element : element.querySelector('img');
      if (img != null) {
        final imgClasses = img.classes as Set<dynamic>? ?? {};
        final isInlineIcon = imgClasses.contains('wiki-inline-icon') || imgClasses.contains('heritage-inline-icon');
        if (isInlineIcon) {
          return _buildInlineIcon(img);
        }

        final caption = (element.querySelector('.caption')?.text as String? ??
                element.querySelector('.thumbcaption')?.text as String? ??
                element.querySelector('figcaption')?.text as String?)
            ?.trim();

        return _buildFullWidthImage(context, img, caption);
      }
    }

    // 3. Standalone images
    if (tagName == 'img') {
      if (classes.contains('hidden-hero-container') && hideHeroInBody) {
        return const SizedBox.shrink();
      }
      final isInlineIcon = classes.contains('wiki-inline-icon') || classes.contains('heritage-inline-icon');
      if (isInlineIcon) {
        return _buildInlineIcon(element);
      }
      return _buildFullWidthImage(context, element, null);
    }

    return null;
  }

  Widget _buildInlineIcon(dynamic element) {
    var src = element.attributes['src'] as String? ?? '';
    if (src.startsWith('//')) {
      src = 'https:$src';
    }
    if (src.isEmpty) return const SizedBox.shrink();
    return Image.network(
      src,
      height: 20,
      fit: BoxFit.contain,
      headers: WikiConfig.headers,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildFullWidthImage(BuildContext context, dynamic img, String? caption) {
    var src = img.attributes['src'] as String? ?? '';
    if (src.isEmpty) return const SizedBox.shrink();
    if (src.startsWith('//')) {
      src = 'https:$src';
    }
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(
                    imagePath: src,
                    caption: caption,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: src,
                child: Image.network(
                  src,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  headers: WikiConfig.headers,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 36),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (caption != null && caption.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                caption.trim(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNativeGallery(BuildContext context, dynamic galleryElement) {
    final items = galleryElement.querySelectorAll('.gallerybox') as List<dynamic>? ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final box = items[index];
          final img = box.querySelector('img');
          final caption = (box.querySelector('.gallerytext')?.text as String? ?? '').trim();

          if (img == null) return const SizedBox.shrink();
          var src = img.attributes['src'] as String? ?? '';
          if (src.isEmpty) return const SizedBox.shrink();
          if (src.startsWith('//')) {
            src = 'https:$src';
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(
                    imagePath: src,
                    caption: caption.isNotEmpty ? caption : null,
                  ),
                ),
              );
            },
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: src,
                      child: Image.network(
                        src,
                        fit: BoxFit.cover,
                        headers: WikiConfig.headers,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 36),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: Text(
                          caption,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHtmlWidget(String html, BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return HtmlWidget(
      html,
      factoryBuilder: () => HeritageTableWidgetFactory(),
      onTapUrl: (url) {
        return _handleUrlTap(url);
      },
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 15 * textScale,
        height: 1.7,
        color: theme.colorScheme.onSurface,
      ),
      customStylesBuilder: (element) => _buildCustomStyles(element, context),
      customWidgetBuilder: (element) => _buildCustomWidget(element, context),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (sections != null && sections!.isNotEmpty) {
      final intro = _effectiveIntro;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intro.isNotEmpty) _buildHtmlWidget(intro, context),
          for (int i = 0; i < sections!.length; i++)
            KeyedSubtree(
              key: sections![i].key,
              child: Padding(
                padding: EdgeInsets.only(
                  top: i == 0 && intro.isEmpty ? 0.0 : (sections![i].level == 2 ? 26.0 : 20.0),
                ),
                child: _buildHtmlWidget(sections![i].html, context),
              ),
            ),
        ],
      );
    }

    return _buildHtmlWidget(htmlContent, context);
  }
}

/// Displays a modal bottom sheet displaying the interactive citation reference.
void showFootnoteBottomSheet({
  required BuildContext context,
  required ArticleFootnote footnote,
  required Color accentColor,
  String? languageCode,
}) {
  final theme = Theme.of(context);
  final lang = languageCode ??
      Localizations.maybeLocaleOf(context)?.languageCode ??
      'nia';
  final footnoteTitle = switch (lang) {
    'en' => 'Reference',
    'id' => 'Referensi',
    _ => 'Umbu',
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            top: 16,
            right: 20,
            bottom: 24 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row: Footnote number, Title, Close icon button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '[${footnote.index}]',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      footnoteTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Plain and simple footnote text
              SelectableText(
                footnote.text.trim().isNotEmpty
                    ? footnote.text
                    : (lang == 'en'
                        ? 'Citation reference [${footnote.index}]'
                        : (lang == 'id'
                            ? 'Referensi sitasi [${footnote.index}]'
                            : 'Umbu sitasi [${footnote.index}]')),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Custom [WidgetFactory] that ensures HTML tables have generous column widths
/// and allow smooth horizontal scrolling instead of squishing columns to screen width.
class HeritageTableWidgetFactory extends WidgetFactory {
  @override
  Widget? buildHorizontalScrollView(BuildTree tree, Widget child) {
    // General rule: never show infoboxes
    final classes = tree.element.classes;
    if (classes.contains('infobox') ||
        classes.contains('infobox_v3') ||
        classes.contains('infobox_v2') ||
        classes.contains('infobox-subbox') ||
        classes.contains('sidebar') ||
        classes.contains('vertical-navbox') ||
        classes.contains('vcard')) {
      return const SizedBox.shrink();
    }

    Widget content = child;
    if (child is CssSizingHint) {
      final rows = tree.element.querySelectorAll('tr');
      int maxCols = 0;
      for (final row in rows) {
        int cols = 0;
        for (final cell in row.children) {
          if (cell.localName == 'th' || cell.localName == 'td') {
            final span = int.tryParse(cell.attributes['colspan'] ?? '1') ?? 1;
            cols += span;
          }
        }
        maxCols = max(maxCols, cols);
      }

      final colCount = maxCols > 0 ? maxCols : 1;
      if (colCount >= 3) {
        final targetWidth = max(colCount * 140.0, 500.0);
        content = CssSizingHint(
          minWidth: targetWidth,
          maxWidth: double.infinity,
          child: child.child,
        );
      } else {
        content = CssSizingHint(
          maxWidth: double.infinity,
          child: child.child,
        );
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: content,
    );
  }
}
