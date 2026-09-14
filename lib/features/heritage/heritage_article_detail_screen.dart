import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../../core/services/heritage_translation_service.dart';
import 'models/heritage_section_model.dart';
import 'widgets/floating_toc_pill.dart';
import 'widgets/heritage_article_content_view.dart';

class HeritageArticleDetailScreen extends ConsumerStatefulWidget {
  final int pageId;
  final String? initialTitle;
  final Color accentColor;
  final String? heroImagePath;

  const HeritageArticleDetailScreen({
    super.key,
    required this.pageId,
    this.initialTitle,
    this.accentColor = const Color(0xFF1E40AF),
    this.heroImagePath,
  });

  @override
  ConsumerState<HeritageArticleDetailScreen> createState() =>
      _HeritageArticleDetailScreenState();
}

class _HeritageArticleDetailScreenState
    extends ConsumerState<HeritageArticleDetailScreen> {
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

  Future<void> _refreshArticle() async {
    setState(() => _isRefreshing = true);
    try {
      final fresh = await refreshHeritageArticleByPageId(ref, widget.pageId);
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
    final articleAsync = ref.watch(
      heritageArticleByPageIdProvider(widget.pageId),
    );

    return Scaffold(
      body: articleAsync.when(
        data: (article) {
          final footnotes = article?.footnotes ?? [];
          final htmlContent = article?.htmlContent;
          final rawTitle =
              article?.title ?? widget.initialTitle ?? 'app_title'.tr();
          final displayTitle = sanitizeArticleTitle(
            rawTitle,
            fallbackLabel: widget.initialTitle,
          );
          final parsedArticle = htmlContent != null && htmlContent.isNotEmpty
              ? parseHeritageArticle(htmlContent)
              : null;

          return Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 1. Sliver App Bar with Background Image & Actions
                  SliverAppBar(
                    expandedHeight: 220.0,
                    pinned: true,
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    actions: [
                      IconButton(
                        icon: _isRefreshing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                        tooltip: 'heritage.sync_tooltip'.tr(),
                        onPressed: _isRefreshing ? null : _refreshArticle,
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
                        style: AppTheme.sliverAppBarTitleStyle(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (widget.heroImagePath != null)
                            Image.asset(
                              widget.heroImagePath!,
                              cacheWidth: 1080,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: widget.accentColor),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.accentColor,
                                    widget.accentColor.withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.menu_book_rounded,
                                  size: 72,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          // Protection overlay
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

                  // 2. Article Content Body
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
                            // Main Content
                            if (htmlContent != null && htmlContent.isNotEmpty)
                              HeritageArticleContentView(
                                htmlContent: htmlContent,
                                footnotes: footnotes,
                                accentColor: widget.accentColor,
                                sections: parsedArticle?.sections,
                                introMarkdown: parsedArticle?.introMarkdown,
                                onFootnoteTap: (fn) => showFootnoteBottomSheet(
                                  context: context,
                                  footnote: fn,
                                  accentColor: widget.accentColor,
                                ),
                              )
                            else
                              Text(
                                article?.textContent ?? '',
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
                  accentColor: widget.accentColor,
                  scrollController: _scrollController,
                ),
            ],
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(
            backgroundColor: widget.accentColor,
            foregroundColor: Colors.white,
            title: Text(widget.initialTitle ?? 'app_title'.tr()),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            backgroundColor: widget.accentColor,
            foregroundColor: Colors.white,
            title: Text(widget.initialTitle ?? 'app_title'.tr()),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'common.error'.tr(args: [e.toString()]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text('common.retry'.tr()),
                    onPressed: _refreshArticle,
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
