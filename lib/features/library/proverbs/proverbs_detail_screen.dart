import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/database/database.dart';
import '../../../core/services/wiki_sync_provider.dart';

class ProverbsDetailWidget extends ConsumerWidget {
  final Amaedola item;

  const ProverbsDetailWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Label Chip
          Row(
            children: [
              Flexible(
                child: Chip(
                  avatar: const Icon(Icons.label_outlined, size: 16),
                  label: Text(
                    item.label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Proverbs / Amaedola Saying Text
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.format_quote_rounded, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'sections.proverbs'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.textContent,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Meaning (Eluaha)
          if (item.meaning.isNotEmpty) ...[
            Text(
              'amaedola.meaning_title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.meaning,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
          ],

          // Indonesian Meaning
          if (item.meaningId != null && item.meaningId!.isNotEmpty) ...[
            Text(
              'amaedola.meaning_id_title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.meaningId!,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
          ],

          // English Meaning
          if (item.meaningEn != null && item.meaningEn!.isNotEmpty) ...[
            Text(
              'amaedola.meaning_en_title'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.meaningEn!,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
          ],

          // Source URL
          if (item.url != null && item.url!.isNotEmpty) ...[
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.link_outlined, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'amaedola.source_url'.tr(args: [
                      item.url!.replaceAll(
                        'https://incubator.wikimedia.org/wiki/Wb/nia/Amaedola/',
                        'https://nia.wikipedia.org/wiki/Amaedola/',
                      ),
                    ]),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ProverbsDetailPage extends ConsumerStatefulWidget {
  final Amaedola item;

  const ProverbsDetailPage({super.key, required this.item});

  @override
  ConsumerState<ProverbsDetailPage> createState() => _ProverbsDetailPageState();
}

class _ProverbsDetailPageState extends ConsumerState<ProverbsDetailPage> {
  @override
  void initState() {
    super.initState();
    _checkPageForOnlineUpdates();
  }

  void _checkPageForOnlineUpdates() async {
    try {
      final letter = widget.item.url?.split('/').last ?? widget.item.label;
      final updated = await ref.read(wikiSyncServiceProvider).checkAndUpdateSinglePage(
        pageId: widget.item.pageId,
        pageTitle: 'Amaedola/$letter',
        pageType: 'amaedola',
        wikiHost: 'nia.wikipedia.org',
        letter: letter,
      );
      if (updated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('amaedola.sync_success_page'.tr())),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('amaedola.details_title'.tr()),
      ),
      body: SafeArea(
        child: ResponsiveContentWrapper(
          child: ProverbsDetailWidget(item: widget.item),
        ),
      ),
    );
  }
}

// Backwards compatibility aliases
typedef AmaedolaDetailWidget = ProverbsDetailWidget;
typedef AmaedolaDetailPage = ProverbsDetailPage;
