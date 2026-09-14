import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../../core/services/heritage_translation_service.dart';
import 'models/heritage_section_model.dart';
import 'widgets/floating_toc_pill.dart';
import 'widgets/heritage_article_content_view.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  static const accentColor = Color(0xFFEA580C); // Deep Orange
  static const int pageId = 5053; // Permanent Page ID for Ofanöŵa Ginötö
  static const String rawPageTitle = 'Ofanöŵa Ginötö';
  static String get sanitizedPageTitle =>
      rawPageTitle.trim().replaceAll(' ', '_');

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
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
          category: 'timeline',
          pageId: TimelineScreen.pageId,
          lang: currentLang,
        ),
      ),
    );

    return Scaffold(
      body: articleAsync.when(
        data: (article) {
          final footnotes = article?.footnotes ?? [];
          final htmlContent = article?.htmlContent;
          final displayTitle = 'heritage.timeline_title'.tr();
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
                    backgroundColor: TimelineScreen.accentColor,
                    foregroundColor: Colors.white,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'heritage.refresh_tooltip'.tr(),
                        onPressed: () async {
                          await refreshHeritageArticleByCategory(
                            ref: ref,
                            category: 'timeline',
                            lang: currentLang,
                            pageId: TimelineScreen.pageId,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('heritage.refresh_success'.tr()),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        displayTitle,
                        style: AppTheme.sliverAppBarTitleStyle(),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'heritage_hero_${TimelineScreen.pageId}',
                            child: Image.asset(
                              'assets/images/timeline.webp',
                              cacheWidth: 1080,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: TimelineScreen.accentColor,
                                    child: const Center(
                                      child: Icon(
                                        Icons.timeline_rounded,
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
                            // Main Parsed Article Content with Interactive Footnotes
                            if (htmlContent != null && htmlContent.isNotEmpty)
                              HeritageArticleContentView(
                                htmlContent: htmlContent,
                                footnotes: footnotes,
                                accentColor: TimelineScreen.accentColor,
                                sections: parsedArticle?.sections,
                                introMarkdown: parsedArticle?.introMarkdown,
                                onFootnoteTap: (fn) => showFootnoteBottomSheet(
                                  context: context,
                                  footnote: fn,
                                  accentColor: TimelineScreen.accentColor,
                                ),
                              )
                            else
                              Text(
                                article?.textContent ??
                                    'heritage.timeline_desc'.tr(),
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
                  accentColor: TimelineScreen.accentColor,
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
