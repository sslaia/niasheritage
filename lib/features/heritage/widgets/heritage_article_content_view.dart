import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../core/utils/heritage_article_parser.dart';
import '../../../core/utils/url_launcher_utils.dart';
import '../../../core/wikimedia/wiki_config.dart';
import '../../../core/wikimedia/wiki_link_intent.dart';
import '../models/heritage_section_model.dart';

class HeritageArticleContentView extends StatelessWidget {
  final String htmlContent;
  final List<ArticleFootnote> footnotes;
  final Color accentColor;
  final void Function(ArticleFootnote footnote) onFootnoteTap;
  final void Function(String title, bool isRedLink)? onArticleTap;
  final void Function(String audioUrl)? onAudioTap;
  final List<HeritageArticleSection>? sections;
  final String? introHtml;
  final bool hideHeroInBody;

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
  });

  String get _effectiveIntro => introHtml ?? '';

  String _colorToHex(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  bool _handleUrlTap(String url) {
    final intent = parseWikiLink(url);

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
          onArticleTap!(title, isRedLink);
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

    if (tagName == 'table') {
      return {
        'border-collapse': 'collapse',
        'margin-top': '12px',
        'margin-bottom': '16px',
        'border': '1px solid $borderColor',
      };
    }
    if (tagName == 'th') {
      return {
        'background-color': thBg,
        'color': accentHex,
        'padding': '8px 12px',
        'border': '1px solid $borderColor',
        'text-align': 'left',
        'font-weight': 'bold',
        'font-size': '13px',
      };
    }
    if (tagName == 'td') {
      return {
        'padding': '8px 12px',
        'border': '1px solid $borderColor',
        'font-size': '13px',
      };
    }
    if (element.classes.contains('reference') || tagName == 'sup') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'text-decoration': 'none',
        'font-size': '11px',
      };
    }
    if (tagName == 'a') {
      return {
        'color': accentHex,
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
        'font-size': '20px',
        'line-height': '1.3',
      };
    }
    if (tagName == 'h2') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'margin-top': '22px',
        'margin-bottom': '6px',
        'font-size': '18px',
        'line-height': '1.3',
      };
    }
    if (tagName == 'h3') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'margin-top': '18px',
        'margin-bottom': '6px',
        'font-size': '16px',
        'line-height': '1.3',
      };
    }
    if (tagName == 'h4') {
      return {
        'color': accentHex,
        'font-weight': 'bold',
        'margin-top': '14px',
        'margin-bottom': '4px',
        'font-size': '14px',
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
    if (element.classes.contains('wiki-inline-icon')) {
      return {
        'max-height': '1.2em',
        'vertical-align': 'middle',
      };
    }
    if (element.classes.contains('mw-editsection') ||
        element.classes.contains('mw-editsection-bracket') ||
        element.classes.contains('mw-editsection-divider') ||
        element.classes.contains('mw-editsection-visualeditor') ||
        element.id == 'toc' ||
        element.classes.contains('toc') ||
        element.classes.contains('mw-empty-elt')) {
      return {'display': 'none'};
    }
    return null;
  }

  Widget? _buildCustomWidget(dynamic element) {
    final classes = element.classes as Set<dynamic>? ?? {};
    final tagName = element.localName as String?;

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

    // Hide any edit action anchor links
    if (tagName == 'a') {
      final href = (element.attributes['href'] as String? ?? '').toLowerCase();
      if (href.contains('action=edit') || href.contains('veaction=edit')) {
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

    // Render images as wide as text with rounded corners, or inline if icon
    if (tagName == 'img') {
      var src = element.attributes['src'] as String? ?? '';
      if (src.startsWith('//')) {
        src = 'https:$src';
      }
      if (src.isNotEmpty) {
        final isInlineIcon = classes.contains('wiki-inline-icon');
        if (isInlineIcon) {
          return Image.network(
            src,
            height: 20,
            fit: BoxFit.contain,
            headers: WikiConfig.headers,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              src,
              width: double.infinity,
              fit: BoxFit.cover,
              headers: WikiConfig.headers,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
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
            ),
          ),
        );
      }
    }

    return null;
  }

  Widget _buildHtmlWidget(String html, BuildContext context) {
    final theme = Theme.of(context);

    return HtmlWidget(
      html,
      onTapUrl: (url) {
        return _handleUrlTap(url);
      },
      textStyle: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 15,
        height: 1.7,
        color: theme.colorScheme.onSurface,
      ),
      customStylesBuilder: (element) => _buildCustomStyles(element, context),
      customWidgetBuilder: (element) => _buildCustomWidget(element),
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
