import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/utils/url_launcher_utils.dart';
import '../../core/database/database.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../../core/widgets/app_bar_circle_action.dart';
import '../../core/wikimedia/html_processor.dart';
import '../../core/wikimedia/wiki_api_service.dart';
import '../../core/wikimedia/wiki_config.dart';
import '../heritage/widgets/heritage_article_content_view.dart';

class SectionItemDetailScreen extends StatefulWidget {
  final int? id;
  final int? pageId;
  final String title;
  final String text;
  final String? description;
  final String? url;
  final Color sectionColor;
  final String sectionKey;
  final AppDatabase? database;
  final WikiApiService? wikiApiService;

  const SectionItemDetailScreen({
    super.key,
    this.id,
    this.pageId,
    required this.title,
    required this.text,
    this.description,
    this.url,
    required this.sectionColor,
    required this.sectionKey,
    this.database,
    this.wikiApiService,
  });

  @override
  State<SectionItemDetailScreen> createState() => _SectionItemDetailScreenState();
}

class _SectionItemDetailScreenState extends State<SectionItemDetailScreen> {
  late String _currentText;
  late ProcessedArticle _processedArticle;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentText = widget.text;
    _processedArticle = _processContent(_currentText);

    // Automatically refresh from the Wikimedia server on open if internet connection exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoRefreshFromWiki();
    });
  }

  @override
  void didUpdateWidget(covariant SectionItemDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _currentText = widget.text;
      _processedArticle = _processContent(_currentText);
    }
  }

  String _getSectionTitle(String key) {
    switch (key) {
      case 'recitation':
        return 'sections.recitation'.tr();
      case 'stories':
        return 'sections.stories'.tr();
      case 'songs':
        return 'sections.songs'.tr();
      case 'writings':
        return 'sections.writings'.tr();
      case 'articles':
        return 'sections.articles'.tr();
      default:
        return 'sections.$key'.tr();
    }
  }

  ProcessedArticle _processContent(String raw) {
    var content = raw.trim();

    // 1. Remove all content from subheading Fabaliŵa lala or Bale zato to the end
    content = content.replaceFirst(
      RegExp(r'(?:<h[1-6][^>]*>\s*|==+\s*|^|\n)\s*(?:Fabali[ŵw]a\s+lala|Bale\s+zato)[\s\S]*$', caseSensitive: false),
      '',
    ).trim();

    return const HtmlProcessor().process(
      rawContent: content,
      defaultTitle: widget.title,
      hideHeroImageInBody: false,
    );
  }

  Future<void> _autoRefreshFromWiki({bool force = false}) async {
    if (!mounted || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Determine host
      String host = WikiConfig.incubatorHost;
      if (widget.url != null && widget.url!.isNotEmpty) {
        final uri = Uri.tryParse(widget.url!);
        if (uri != null && uri.host.isNotEmpty) {
          host = uri.host;
        }
      } else if (widget.sectionKey == 'articles' || widget.sectionKey == 'sura_amilita') {
        host = WikiConfig.wikipediaHost;
      }

      // Determine page title
      String? wikiPageTitle;
      if (widget.url != null && widget.url!.isNotEmpty) {
        final uri = Uri.tryParse(widget.url!);
        if (uri != null && uri.path.contains('/wiki/')) {
          wikiPageTitle = Uri.decodeComponent(uri.path.substring(uri.path.indexOf('/wiki/') + 6));
        }
      }

      if (wikiPageTitle == null || wikiPageTitle.isEmpty) {
        final cleanTitle = widget.title.trim().replaceAll(' ', '_');
        if (host == WikiConfig.incubatorHost) {
          wikiPageTitle = cleanTitle.startsWith('Wb/nia/') ? cleanTitle : 'Wb/nia/$cleanTitle';
        } else {
          wikiPageTitle = cleanTitle;
        }
      }

      final service = widget.wikiApiService ?? WikiApiService();
      final result = await service.parseArticle(
        host: host,
        pageId: widget.pageId,
        pageTitle: wikiPageTitle,
        timeout: const Duration(seconds: 12),
      );

      if (result != null && result.rawHtml.trim().isNotEmpty && mounted) {
        final newProcessed = _processContent(result.rawHtml);
        setState(() {
          _currentText = result.rawHtml;
          _processedArticle = newProcessed;
        });

        // Asynchronously persist to local database if database is provided
        if (widget.database != null) {
          final db = widget.database!;
          final freshHtml = result.rawHtml;
          try {
            if (widget.sectionKey == 'stories' || widget.sectionKey == 'mano_mano') {
              if (widget.pageId != null && widget.pageId! > 0) {
                await (db.update(db.stories)..where((t) => t.pageId.equals(widget.pageId!))).write(
                  StoriesCompanion(textContent: Value(freshHtml)),
                );
              } else if (widget.id != null) {
                await (db.update(db.stories)..where((t) => t.id.equals(widget.id!))).write(
                  StoriesCompanion(textContent: Value(freshHtml)),
                );
              }
            } else if (widget.sectionKey == 'articles' ||
                widget.sectionKey == 'writings') {
              if (widget.pageId != null && widget.pageId! > 0) {
                await (db.update(db.articles)..where((t) => t.pageId.equals(widget.pageId!))).write(
                  ArticlesCompanion(textContent: Value(freshHtml)),
                );
              } else if (widget.id != null) {
                await (db.update(db.articles)..where((t) => t.id.equals(widget.id!))).write(
                  ArticlesCompanion(textContent: Value(freshHtml)),
                );
              }
            } else if (widget.sectionKey == 'recitation') {
              if (widget.pageId != null && widget.pageId! > 0) {
                await (db.update(db.recitations)..where((t) => t.pageId.equals(widget.pageId!))).write(
                  RecitationsCompanion(textContent: Value(freshHtml)),
                );
              } else if (widget.id != null) {
                await (db.update(db.recitations)..where((t) => t.id.equals(widget.id!))).write(
                  RecitationsCompanion(textContent: Value(freshHtml)),
                );
              }
            } else if (widget.sectionKey == 'songs') {
              if (widget.pageId != null && widget.pageId! > 0) {
                await (db.update(db.songs)..where((t) => t.pageId.equals(widget.pageId!))).write(
                  SongsCompanion(textContent: Value(freshHtml)),
                );
              } else if (widget.id != null) {
                await (db.update(db.songs)..where((t) => t.id.equals(widget.id!))).write(
                  SongsCompanion(textContent: Value(freshHtml)),
                );
              }
            }
          } catch (_) {
            // Non-critical local db cache write failure ignored
          }
        }
      }
    } catch (_) {
      // Offline, network timeout, or server error gracefully handled; local cached version remains visible
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkSection = ThemeData.estimateBrightnessForColor(widget.sectionColor) == Brightness.dark;
    final appBarFgColor = isDarkSection ? Colors.white : const Color(0xFF1E1B4B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.sectionColor,
        foregroundColor: appBarFgColor,
        iconTheme: IconThemeData(color: appBarFgColor),
        actionsIconTheme: IconThemeData(color: appBarFgColor),
        centerTitle: false,
        leading: const AppBarCircleBackButton(),
        title: Text(
          _getSectionTitle(widget.sectionKey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: appBarFgColor,
          ),
        ),
        actions: [
          if (_isRefreshing)
            const AppBarCircleAction(
              margin: EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            AppBarCircleAction.icon(
              margin: EdgeInsets.only(
                right: widget.url != null && widget.url!.isNotEmpty ? 8.0 : 12.0,
              ),
              icon: Icons.refresh_rounded,
              tooltip: 'common.refresh'.tr(),
              onPressed: () => _autoRefreshFromWiki(force: true),
            ),
          if (widget.url != null && widget.url!.isNotEmpty)
            AppBarCircleAction.icon(
              margin: const EdgeInsets.only(right: 12.0),
              icon: Icons.open_in_browser_rounded,
              tooltip: 'common.open_in_browser'.tr(),
              onPressed: () async {
                final uri = Uri.tryParse(widget.url!);
                if (uri != null) {
                  await openInAppBrowser(uri);
                }
              },
            ),
        ],
      ),
      body: ResponsiveContentWrapper(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: RefreshIndicator(
          onRefresh: () => _autoRefreshFromWiki(force: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card with Centered Title & Description
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: widget.sectionColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.sectionColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.sectionColor,
                        ),
                      ),
                      if (widget.description != null && widget.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          widget.description!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Article Content View with Footnotes, Wikitables, and Clean Links
                HeritageArticleContentView(
                  htmlContent: _processedArticle.html,
                  footnotes: _processedArticle.footnotes,
                  accentColor: widget.sectionColor,
                  onFootnoteTap: (fn) => showFootnoteBottomSheet(
                    context: context,
                    footnote: fn,
                    accentColor: widget.sectionColor,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
