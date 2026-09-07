import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/utils/heritage_article_parser.dart';
import '../models/heritage_section_model.dart';

class HeritageArticleContentView extends StatelessWidget {
  final String htmlContent; // Accepts markdown or html content
  final List<ArticleFootnote> footnotes;
  final Color accentColor;
  final void Function(ArticleFootnote footnote) onFootnoteTap;
  final List<HeritageArticleSection>? sections;
  final String? introMarkdown;

  const HeritageArticleContentView({
    super.key,
    required this.htmlContent,
    required this.footnotes,
    required this.accentColor,
    required this.onFootnoteTap,
    this.sections,
    this.introMarkdown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final styleSheet = MarkdownStyleSheet(
        h1: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: accentColor,
          height: 1.3,
        ),
        h1Padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
        h2: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: accentColor,
          height: 1.3,
        ),
        h2Padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
        h3: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: accentColor,
          height: 1.3,
        ),
        h3Padding: const EdgeInsets.only(top: 16.0, bottom: 6.0),
        h4: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
        p: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          height: 1.7,
          color: theme.colorScheme.onSurface,
        ),
        pPadding: const EdgeInsets.only(bottom: 12.0),
        strong: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        em: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
        blockquote: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        blockquoteDecoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: accentColor,
              width: 4,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        listBullet: theme.textTheme.bodyMedium?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.bold,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
      );

    if (sections != null && sections!.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (introMarkdown != null && introMarkdown!.isNotEmpty)
            MarkdownBody(
              data: introMarkdown!,
              selectable: true,
              styleSheet: styleSheet,
            ),
          for (final section in sections!)
            KeyedSubtree(
              key: section.key,
              child: MarkdownBody(
                data: section.markdown,
                selectable: true,
                styleSheet: styleSheet,
              ),
            ),
        ],
      );
    }

    return MarkdownBody(
      data: htmlContent,
      selectable: true,
      styleSheet: styleSheet,
    );
  }
}

/// Displays a modal bottom sheet displaying the interactive citation reference.
void showFootnoteBottomSheet({
  required BuildContext context,
  required ArticleFootnote footnote,
  required Color accentColor,
}) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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

              // Title Row
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
                      'Umbu / Referensi',
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
              const Divider(height: 20),

              // Footnote Content Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: SelectableText(
                  footnote.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons (Copy Citation & External URL if present)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Salin'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: footnote.text));
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Referensi disalin ke papan klip'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
