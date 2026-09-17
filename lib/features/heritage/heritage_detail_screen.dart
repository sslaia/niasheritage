import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../../core/widgets/app_bar_circle_action.dart';
import '../../core/services/heritage_translation_service.dart';
import '../../core/wikimedia/wiki_config.dart';
import 'models/heritage_section_model.dart';
import 'widgets/floating_toc_pill.dart';
import 'widgets/heritage_article_content_view.dart';

/// Consolidated detail screen for Nias Heritage.
///
/// Can be instantiated in two modes:
/// 1. [HeritageDetailScreen.section] for the 7 primary heritage topics, which
///    automatically queries localized content via [heritageDisplayArticleProvider].
/// 2. [HeritageDetailScreen.article] for individual article viewing by page ID
///    (such as introduction essays).
class HeritageDetailScreen extends ConsumerStatefulWidget {
  final HeritageSection? section;
  final int? pageId;
  final String? initialTitle;
  final Color? accentColor;
  final String? heroImagePath;

  const HeritageDetailScreen({
    super.key,
    this.section,
    this.pageId,
    this.initialTitle,
    this.accentColor,
    this.heroImagePath,
  }) : assert(section != null || pageId != null, 'Either section or pageId must be provided');

  /// Creates a detail screen configured for a [HeritageSection].
  const HeritageDetailScreen.section(
    HeritageSection this.section, {
    super.key,
  })  : pageId = null,
        initialTitle = null,
        accentColor = null,
        heroImagePath = null;

  /// Creates a detail screen for a specific article [pageId].
  const HeritageDetailScreen.article({
    super.key,
    required int this.pageId,
    this.initialTitle,
    this.accentColor,
    this.heroImagePath,
  }) : section = null;

  @override
  ConsumerState<HeritageDetailScreen> createState() => _HeritageDetailScreenState();
}

class _HeritageDetailScreenState extends ConsumerState<HeritageDetailScreen> {
  late final ScrollController _scrollController;
  bool _isRefreshing = false;

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

  Color get _effectiveAccentColor =>
      widget.section?.accentColor ?? widget.accentColor ?? const Color(0xFF1E40AF);

  String? get _effectiveHeroImagePath =>
      widget.section?.heroImagePath ?? widget.heroImagePath;

  int get _effectivePageId =>
      widget.section?.pageId ?? widget.pageId ?? 0;

  Future<void> _refreshArticle(String currentLang) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      if (widget.section != null) {
        final fresh = await refreshHeritageArticleByCategory(
          ref: ref,
          category: widget.section!.category,
          lang: currentLang,
          pageId: widget.section!.pageId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                fresh != null
                    ? 'heritage.refresh_success'.tr()
                    : 'heritage.refresh_error'.tr(),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (widget.pageId != null) {
        final fresh = await refreshHeritageArticleByPageId(ref, widget.pageId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                fresh != null
                    ? 'heritage.refresh_success'.tr()
                    : 'heritage.refresh_error'.tr(),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'heritage.server_error'.tr()}: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLang =
        Localizations.maybeLocaleOf(context)?.languageCode ?? 'nia';

    final AsyncValue<HeritageDisplayArticle?> articleAsync;
    if (widget.section != null) {
      articleAsync = ref.watch(
        heritageDisplayArticleProvider(
          HeritageArticleQueryParam(
            category: widget.section!.category,
            pageId: widget.section!.pageId,
            lang: currentLang,
          ),
        ),
      );
    } else {
      articleAsync = ref.watch(
        heritageArticleByPageIdProvider(widget.pageId!),
      );
    }

    final accentColor = _effectiveAccentColor;
    final heroImagePath = _effectiveHeroImagePath;

    return Scaffold(
      body: articleAsync.when(
        data: (article) {
          final footnotes = article?.footnotes ?? [];
          final htmlContent = article?.htmlContent;

          final String displayTitle;
          if (widget.section != null) {
            displayTitle = widget.section!.titleKey.tr();
          } else {
            final rawTitle = article?.title ?? widget.initialTitle ?? 'app_title'.tr();
            displayTitle = sanitizeArticleTitle(
              rawTitle,
              fallbackLabel: widget.initialTitle,
            );
          }

          final parsedArticle = htmlContent != null && htmlContent.isNotEmpty
              ? parseHeritageArticle(htmlContent)
              : null;

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 1. Sliver App Bar with Background Hero Image & High-Contrast Actions
                  SliverAppBar(
                    expandedHeight: 260.0,
                    pinned: true,
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    leading: const AppBarCircleBackButton(),
                    actions: [
                      AppBarCircleAction(
                        child: _isRefreshing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                                tooltip: 'heritage.refresh_tooltip'.tr(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _isRefreshing ? null : () => _refreshArticle(currentLang),
                              ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsetsDirectional.only(
                        start: 56.0,
                        end: 56.0,
                        bottom: 14.0,
                      ),
                      title: Text(
                        displayTitle,
                        style: AppTheme.sliverAppBarTitleStyle(fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (heroImagePath != null)
                            Hero(
                              tag: 'heritage_hero_$_effectivePageId',
                              child: Image.asset(
                                heroImagePath,
                                cacheWidth: 1080,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(color: accentColor),
                              ),
                            )
                          else if (article?.imageUrl != null && article!.imageUrl!.isNotEmpty)
                            Image.network(
                              article.imageUrl!,
                              fit: BoxFit.cover,
                              headers: WikiConfig.headers,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: accentColor),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    accentColor,
                                    accentColor.withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  widget.section?.icon ?? Icons.menu_book_rounded,
                                  size: 72,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          // Protection overlay gradient for text legibility
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

                  // 2. Extension Slot: Specialized components (e.g. Timeline Animation)
                  if (widget.section == HeritageSection.timeline)
                    const SliverToBoxAdapter(
                      child: SizedBox.shrink(), // Future interactive timeline animation slot
                    ),

                  // 3. Article Content Body
                  SliverToBoxAdapter(
                    child: ResponsiveContentWrapper(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 24.0,
                        ),
                        child: (htmlContent != null && htmlContent.isNotEmpty)
                            ? HeritageArticleContentView(
                                htmlContent: htmlContent,
                                footnotes: footnotes,
                                accentColor: accentColor,
                                sections: parsedArticle?.sections,
                                introHtml: parsedArticle?.introHtml,
                                hideHeroInBody: true,
                                onFootnoteTap: (fn) => showFootnoteBottomSheet(
                                  context: context,
                                  footnote: fn,
                                  accentColor: accentColor,
                                ),
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'heritage.no_content'.tr(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Bottom padding for scroll clearance
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),

              // 4. Floating Table of Contents Pill
              if (parsedArticle != null && parsedArticle.hasSections)
                FloatingTocPill(
                  sections: parsedArticle.sections,
                  scrollController: _scrollController,
                  accentColor: accentColor,
                ),
            ],
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            leading: const AppBarCircleBackButton(),
            title: Text(
              widget.section?.titleKey.tr() ?? widget.initialTitle ?? '',
              style: AppTheme.sliverAppBarTitleStyle(fontSize: 18),
            ),
          ),
          body: Center(
            child: CircularProgressIndicator(color: accentColor),
          ),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            leading: const AppBarCircleBackButton(),
            title: Text(
              widget.section?.titleKey.tr() ?? widget.initialTitle ?? '',
              style: AppTheme.sliverAppBarTitleStyle(fontSize: 18),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'heritage.loading_error'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: accentColor),
                    onPressed: () => _refreshArticle(currentLang),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text('common.retry'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
