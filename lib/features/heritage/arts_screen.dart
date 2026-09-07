import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../../core/services/heritage_translation_service.dart';
import 'models/heritage_section_model.dart';
import 'widgets/floating_toc_pill.dart';
import 'widgets/heritage_article_content_view.dart';

class ArtsScreen extends ConsumerStatefulWidget {
  const ArtsScreen({super.key});

  static const accentColor = Color(0xFFDC2626); // Crimson Red
  static const int pageId = 4798; // Permanent Page ID for Fanari ba Fanunö
  static const String rawPageTitle = 'Fanari ba Fanunö Nono Niha';
  static String get sanitizedPageTitle =>
      rawPageTitle.trim().replaceAll(' ', '_');

  @override
  ConsumerState<ArtsScreen> createState() => _ArtsScreenState();
}

class _ArtsScreenState extends ConsumerState<ArtsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLang = context.locale.languageCode;
    final articleAsync = ref.watch(
      heritageDisplayArticleProvider(
        HeritageArticleQueryParam(
          category: 'arts',
          pageId: ArtsScreen.pageId,
          lang: currentLang,
        ),
      ),
    );

    return Scaffold(
      body: articleAsync.when(
        data: (article) {
          final footnotes = article?.footnotes ?? [];
          final htmlContent = article?.htmlContent;
          final displayTitle = 'heritage.arts_title'.tr();
          final parsedArticle = htmlContent != null && htmlContent.isNotEmpty
              ? parseHeritageArticle(htmlContent)
              : null;

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 1. Sliver App Bar with Hero Image as background
                  SliverAppBar(
                    expandedHeight: 260.0,
                    pinned: true,
                    backgroundColor: ArtsScreen.accentColor,
                    foregroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        displayTitle,
                        style: AppTheme.sliverAppBarTitleStyle(),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'heritage_hero_${ArtsScreen.pageId}',
                            child: Image.asset(
                              'assets/images/arts.webp',
                              cacheWidth: 1080,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: ArtsScreen.accentColor,
                                child: const Center(
                                  child: Icon(
                                    Icons.theater_comedy_rounded,
                                    size: 72,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Gradient protection overlay for readability
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black38,
                                  Colors.transparent,
                                  Colors.black87,
                                ],
                                stops: [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Main Content Body
                  SliverToBoxAdapter(
                    child: ResponsiveContentWrapper(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Source Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ArtsScreen.accentColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: ArtsScreen.accentColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    article?.lang == 'id'
                                        ? 'Bahasa Indonesia'
                                        : article?.lang == 'en'
                                        ? 'English'
                                        : 'Li Niha',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: ArtsScreen.accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Overview / Description Text
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                'heritage.arts_desc'.tr(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Main Parsed Article Content with Interactive Footnotes
                            if (htmlContent != null && htmlContent.isNotEmpty)
                              HeritageArticleContentView(
                                htmlContent: htmlContent,
                                footnotes: footnotes,
                                accentColor: ArtsScreen.accentColor,
                                sections: parsedArticle?.sections,
                                introMarkdown: parsedArticle?.introMarkdown,
                                onFootnoteTap: (fn) => showFootnoteBottomSheet(
                                  context: context,
                                  footnote: fn,
                                  accentColor: ArtsScreen.accentColor,
                                ),
                              )
                            else
                              Text(
                                article?.textContent ??
                                    'heritage.dance_desc'.tr(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.6,
                                ),
                              ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (parsedArticle != null && parsedArticle.hasSections)
                FloatingTocPill(
                  sections: parsedArticle.sections,
                  accentColor: ArtsScreen.accentColor,
                  scrollController: _scrollController,
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('common.error'.tr(args: [e.toString()])),
          ),
        ),
      ),
    );
  }
}
