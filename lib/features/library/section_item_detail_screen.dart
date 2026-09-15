import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../heritage/widgets/heritage_article_content_view.dart';

class SectionItemDetailScreen extends StatelessWidget {
  final String title;
  final String text;
  final String? description;
  final String? url;
  final Color sectionColor;
  final String sectionKey;

  const SectionItemDetailScreen({
    super.key,
    required this.title,
    required this.text,
    this.description,
    this.url,
    required this.sectionColor,
    required this.sectionKey,
  });

  String _getSectionTitle(String key) {
    switch (key) {
      case 'recitation':
      case 'epic':
      case 'hoho':
        final tr = 'sections.recitation'.tr();
        if (tr.contains('sections.')) return 'sections.epic'.tr();
        return tr;
      case 'stories':
      case 'mano_mano':
        return 'sections.stories'.tr();
      case 'songs':
      case 'sinuno':
        return 'sections.songs'.tr();
      case 'writings':
      case 'sinura':
        return 'sections.writings'.tr();
      case 'articles':
      case 'sura_amilita':
        return 'sections.articles'.tr();
      default:
        return 'sections.$key'.tr();
    }
  }

  String _formatHtmlContent(String raw) {
    var content = raw.trim();

    // 1. Remove all content from subheading Fabaliŵa lala or Bale zato to the end
    content = content.replaceFirst(
      RegExp(r'(?:<h[1-6][^>]*>\s*|==+\s*|^|\n)\s*(?:Fabali[ŵw]a\s+lala|Bale\s+zato)[\s\S]*$', caseSensitive: false),
      '',
    ).trim();

    // 2. Hide category names in text (e.g. "Kategori:Sura amilita", "[[Category:...]]", "[[Kategori:...]]")
    content = content.replaceAll(
      RegExp(r'(?:\[\[)?(?:Kategori|Category):[^\n\]<]+(?:\]\])?', caseSensitive: false),
      '',
    ).trim();

    // 3. Remove wiki template references like {{Wb/nia/NavBuku1}}
    content = content.replaceAll(
      RegExp(r'\{\{[^\}]+\}\}', caseSensitive: false),
      '',
    ).trim();

    // 4. Strip MediaWiki magic words like __TOC__, __NOTOC__
    content = content.replaceAll(RegExp(r'__[A-Z]+__'), '');

    // 5. Strip edit section links (e.g. [bulö'ö | bulö'ö kode], [sunting], [edit])
    content = content.replaceAll(
      RegExp(
        r'\[(?:bulö.ö(?:\s*\|\s*bulö.ö\s*kode)?|sunting(?:\s*\|\s*sunting\s*sumber)?|edit(?:\s*\|\s*edit\s*source)?)[^\]]*\]',
        caseSensitive: false,
      ),
      '',
    );

    // 6. Convert MediaWiki images [[File:...]] or [[Berkas:...]] or [[Gambar:...]] to HTML <img>
    content = content.replaceAllMapped(
      RegExp(r'\[\[(?:File|Berkas|Gambar|Image):([^|\]]+)(?:\|([^\]]*))?\]\]', caseSensitive: false),
      (match) {
        final rawFileName = match.group(1)?.trim() ?? '';
        final rest = match.group(2) ?? '';
        final parts = rest.split('|').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

        // Extract caption if present (ignoring sizes, alignments, and MediaWiki display options)
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
\n\n<div style="margin: 18px 0; text-align: center;">
  <img src="$imageUrl" style="width: 100%; border-radius: 12px; display: block;" />
  ${caption.isNotEmpty ? '<div style="margin-top: 6px; font-size: 13px; font-style: italic; color: #666; text-align: center;">$caption</div>' : ''}
</div>\n\n
''';
      },
    );

    // 7. Convert MediaWiki internal links [[Target|Label]] -> Label, [[Target]] -> Target
    content = content.replaceAllMapped(
      RegExp(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]'),
      (m) => m.group(1)!,
    );

    // 8. Convert MediaWiki Headings (surrounded by double-newlines so they form standalone HTML blocks)
    content = content.replaceAllMapped(
      RegExp(r'^\s*====\s*(.*?)\s*====\s*$', multiLine: true),
      (m) => '\n\n<h4>${m.group(1)?.trim()}</h4>\n\n',
    );
    content = content.replaceAllMapped(
      RegExp(r'^\s*===\s*(.*?)\s*===\s*$', multiLine: true),
      (m) => '\n\n<h3>${m.group(1)?.trim()}</h3>\n\n',
    );
    content = content.replaceAllMapped(
      RegExp(r'^\s*==\s*(.*?)\s*==\s*$', multiLine: true),
      (m) => '\n\n<h2>${m.group(1)?.trim()}</h2>\n\n',
    );
    content = content.replaceAllMapped(
      RegExp(r'^\s*=\s*(.*?)\s*=\s*$', multiLine: true),
      (m) => '\n\n<h1>${m.group(1)?.trim()}</h1>\n\n',
    );

    // 9. Convert MediaWiki bold & italic
    content = content.replaceAllMapped(RegExp(r"'''''(.*?)'''''"), (m) => '<b><i>${m.group(1)}</i></b>');
    content = content.replaceAllMapped(RegExp(r"'''(.*?)'''"), (m) => '<b>${m.group(1)}</b>');
    content = content.replaceAllMapped(RegExp(r"''(.*?)''"), (m) => '<i>${m.group(1)}</i>');

    // 10. Convert horizontal rules
    content = content.replaceAll(RegExp(r'^\s*----\s*$', multiLine: true), '\n\n<hr>\n\n');

    // 11. Ensure protocol-relative images have https:
    content = content.replaceAll('src="//', 'src="https://');

    // If the content is already full HTML with paragraph tags, return it
    if (content.contains('<p>') || content.contains('<p ')) {
      return content;
    }

    // 12. Otherwise, convert text blocks between newlines into HTML paragraphs
    final paragraphs = content.split(RegExp(r'\n\s*\n'));
    return paragraphs.map((p) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) return '';
      // If the block is already an HTML block element (e.g. image container, heading, table, hr), preserve it
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
      return '<p style="margin-bottom: 16px; line-height: 1.75; font-size: 16px;">$lines</p>';
    }).where((p) => p.isNotEmpty).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkSection = ThemeData.estimateBrightnessForColor(sectionColor) == Brightness.dark;
    final appBarFgColor = isDarkSection ? Colors.white : const Color(0xFF1E1B4B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sectionColor,
        foregroundColor: appBarFgColor,
        iconTheme: IconThemeData(color: appBarFgColor),
        actionsIconTheme: IconThemeData(color: appBarFgColor),
        centerTitle: false,
        title: Text(
          _getSectionTitle(sectionKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: appBarFgColor,
          ),
        ),
        actions: [
          if (url != null && url!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded),
              tooltip: 'common.open_in_browser'.tr().contains('common.')
                  ? 'Wikibooks'
                  : 'common.open_in_browser'.tr(),
              onPressed: () async {
                final uri = Uri.tryParse(url!);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                }
              },
            ),
        ],
      ),
      body: ResponsiveContentWrapper(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card with Centered Title & Description
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: sectionColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sectionColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: sectionColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          description!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: sectionColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Formatted Reading Content using HeritageArticleContentView (Wiki Rendering Skill)
              HeritageArticleContentView(
                htmlContent: _formatHtmlContent(text),
                footnotes: const [],
                accentColor: sectionColor,
                onFootnoteTap: (fn) => showFootnoteBottomSheet(
                  context: context,
                  footnote: fn,
                  accentColor: sectionColor,
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
