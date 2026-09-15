import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders the footer attribution text with an interactive clickable link for
/// "Wikimedia Commons" that opens the Hero Images attribution bottom sheet.
class FooterAttribution extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double maxWidth;

  const FooterAttribution({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
    this.maxWidth = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullText = 'footer.attribution'.tr();
    const linkWord = 'Wikimedia Commons';
    final parts = fullText.split(linkWord);

    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 11,
      color: theme.colorScheme.outline,
      height: 1.4,
    );

    final linkStyle = baseStyle?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      fontSize: 9,
      decorationColor: theme.colorScheme.primary,
    );

    Widget attributionContent;

    if (parts.length == 2) {
      attributionContent = Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: parts[0]),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => showImagesAttributionSheet(context),
                  child: Text(linkWord, style: linkStyle),
                ),
              ),
            ),
            TextSpan(text: parts[1]),
          ],
        ),
        textAlign: TextAlign.center,
      );
    } else {
      attributionContent = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => showImagesAttributionSheet(context),
          child: Text(fullText, style: linkStyle, textAlign: TextAlign.center),
        ),
      );
    }

    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: attributionContent,
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: content);
    }

    return content;
  }
}

/// Displays a modal bottom sheet listing hero image attributions from assets/images/images.md
void showImagesAttributionSheet(BuildContext context) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Hero Images (Wikimedia Commons)',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'common.close'.tr(),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<String>(
                    future: DefaultAssetBundle.of(context)
                        .loadString('assets/images/images.md'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'home.images_list_load_error'.tr(),
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        );
                      }
                      return Markdown(
                        controller: scrollController,
                        data: snapshot.data!,
                        selectable: true,
                        onTapLink: (text, href, title) async {
                          if (href != null && href.startsWith('http')) {
                            final uri = Uri.parse(href);
                            try {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.inAppBrowserView,
                              );
                            } catch (_) {}
                          }
                        },
                        styleSheet: MarkdownStyleSheet.fromTheme(theme)
                            .copyWith(
                              a: TextStyle(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                              h1: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              h2: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                              p: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                            ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
