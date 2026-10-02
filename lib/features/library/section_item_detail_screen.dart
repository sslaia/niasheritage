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
import '../../core/wikimedia/wiki_link_intent.dart';
import '../../core/services/heritage_translation_service.dart';
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
  late String _title;
  late ProcessedArticle _processedArticle;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentText = widget.text;
    _title = sanitizeArticleTitle(widget.title);
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
    if (oldWidget.title != widget.title) {
      _title = sanitizeArticleTitle(widget.title);
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
      final isIncubator = widget.url?.contains('incubator.wikimedia.org') == true;
      final String host = isIncubator ? WikiConfig.incubatorHost : WikiConfig.wikipediaHost;

      // Determine page title
      String? wikiPageTitle;
      if (widget.url != null && widget.url!.isNotEmpty) {
        final uri = Uri.tryParse(widget.url!);
        if (uri != null && uri.path.contains('/wiki/')) {
          var extracted = Uri.decodeComponent(uri.path.substring(uri.path.indexOf('/wiki/') + 6));
          if (!isIncubator && extracted.startsWith('Wb/nia/')) {
            extracted = extracted.substring(7);
          }
          wikiPageTitle = extracted;
        }
      }

      final currentCleanTitle = _title.trim().replaceAll(' ', '_');
      if (wikiPageTitle == null || wikiPageTitle.isEmpty) {
        wikiPageTitle = isIncubator ? 'Wb/nia/$currentCleanTitle' : currentCleanTitle;
      }

      final service = widget.wikiApiService ?? WikiApiService();
      final result = await service.parseArticle(
        host: host,
        pageId: widget.pageId,
        pageTitle: wikiPageTitle,
        timeout: const Duration(seconds: 12),
      );

      final freshResult = result;
      if (freshResult != null && freshResult.rawHtml.trim().isNotEmpty && mounted) {
        final newProcessed = _processContent(freshResult.rawHtml);
        final rawTitle = freshResult.displayTitle.isNotEmpty ? freshResult.displayTitle : freshResult.title;
        final cleanTitle = sanitizeArticleTitle(rawTitle);

        setState(() {
          _currentText = freshResult.rawHtml;
          _processedArticle = newProcessed;
          if (cleanTitle.isNotEmpty && cleanTitle.toLowerCase() != 'otoritas') {
            _title = cleanTitle;
          }
        });

        // Asynchronously persist to local database if database is provided
        if (widget.database != null) {
          final db = widget.database!;
          final freshHtml = freshResult.rawHtml;
          final Value<String> titleVal = (_title.isNotEmpty && _title.toLowerCase() != 'otoritas')
              ? Value<String>(_title)
              : const Value.absent();
          try {
            if (widget.sectionKey == 'stories' || widget.sectionKey == 'mano_mano') {
              if (widget.pageId != null && widget.pageId! > 0) {
                await (db.update(db.stories)..where((t) => t.pageId.equals(widget.pageId!))).write(
                  StoriesCompanion(title: titleVal, textContent: Value(freshHtml)),
                );
              } else if (widget.id != null) {
                await (db.update(db.stories)..where((t) => t.id.equals(widget.id!))).write(
                  StoriesCompanion(title: titleVal, textContent: Value(freshHtml)),
                );
              }
            } else if (widget.sectionKey == 'writings' ||
                widget.sectionKey == 'articles') {
              if (widget.pageId != null && widget.pageId! > 0) {
                await (db.update(db.writings)..where((t) => t.pageId.equals(widget.pageId!))).write(
                  WritingsCompanion(title: titleVal, textContent: Value(freshHtml)),
                );
              } else if (widget.id != null) {
                await (db.update(db.writings)..where((t) => t.id.equals(widget.id!))).write(
                  WritingsCompanion(title: titleVal, textContent: Value(freshHtml)),
                );
              }
            } else if (widget.sectionKey == 'recitation') {
              if (widget.pageId != null && widget.pageId! > 0) {
                await (db.update(db.recitations)..where((t) => t.pageId.equals(widget.pageId!))).write(
                  RecitationsCompanion(title: titleVal, textContent: Value(freshHtml)),
                );
              } else if (widget.id != null) {
                await (db.update(db.recitations)..where((t) => t.id.equals(widget.id!))).write(
                  RecitationsCompanion(title: titleVal, textContent: Value(freshHtml)),
                );
              }
            } else if (widget.sectionKey == 'songs') {
              if (widget.pageId != null && widget.pageId! > 0) {
                await (db.update(db.songs)..where((t) => t.pageId.equals(widget.pageId!))).write(
                  SongsCompanion(title: titleVal, textContent: Value(freshHtml)),
                );
              } else if (widget.id != null) {
                await (db.update(db.songs)..where((t) => t.id.equals(widget.id!))).write(
                  SongsCompanion(title: titleVal, textContent: Value(freshHtml)),
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

  Future<void> _handleArticleTap(
    String rawTargetTitle,
    bool isRedLink,
    String? wikiHost,
  ) async {
    if (isRedLink) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('heritage.red_link_notice'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final (targetTitle, resolvedHost) = resolveInterwikiTitle(rawTargetTitle, wikiHost);
    final cleanTitle = sanitizeArticleTitle(targetTitle);
    if (cleanTitle.isEmpty) return;

    int? matchedId;
    int? matchedPageId;
    String matchedText = '';
    String? matchedDesc;
    String? matchedUrl;
    String targetSectionKey = widget.sectionKey;

    if (widget.database != null) {
      final db = widget.database!;
      try {
        // 1. Check current section first
        if (widget.sectionKey == 'recitation') {
          final rows = await (db.select(db.recitations)..where((t) => t.title.equals(cleanTitle))).get();
          if (rows.isNotEmpty) {
            matchedId = rows.first.id;
            matchedPageId = rows.first.pageId;
            matchedText = rows.first.textContent;
            matchedDesc = rows.first.description;
            matchedUrl = rows.first.url;
          }
        } else if (widget.sectionKey == 'stories' || widget.sectionKey == 'mano_mano') {
          final rows = await (db.select(db.stories)..where((t) => t.title.equals(cleanTitle))).get();
          if (rows.isNotEmpty) {
            matchedId = rows.first.id;
            matchedPageId = rows.first.pageId;
            matchedText = rows.first.textContent;
            matchedDesc = rows.first.description;
            matchedUrl = rows.first.url;
          }
        } else if (widget.sectionKey == 'songs') {
          final rows = await (db.select(db.songs)..where((t) => t.title.equals(cleanTitle))).get();
          if (rows.isNotEmpty) {
            matchedId = rows.first.id;
            matchedPageId = rows.first.pageId;
            matchedText = rows.first.textContent;
            matchedDesc = rows.first.category;
            matchedUrl = rows.first.url;
          }
        } else if (widget.sectionKey == 'writings') {
          final rows = await (db.select(db.writings)..where((t) => t.title.equals(cleanTitle))).get();
          if (rows.isNotEmpty) {
            matchedId = rows.first.id;
            matchedPageId = rows.first.pageId;
            matchedText = rows.first.textContent;
            matchedDesc = rows.first.description;
            matchedUrl = rows.first.url;
            targetSectionKey = 'writings';
          }
        }

        // 2. If not found in current section, check other sections
        if (matchedText.isEmpty) {
          // Check recitations
          final recRows = await (db.select(db.recitations)..where((t) => t.title.equals(cleanTitle))).get();
          if (recRows.isNotEmpty) {
            matchedId = recRows.first.id;
            matchedPageId = recRows.first.pageId;
            matchedText = recRows.first.textContent;
            matchedDesc = recRows.first.description;
            matchedUrl = recRows.first.url;
            targetSectionKey = 'recitation';
          }
          // Check stories
          if (matchedText.isEmpty) {
            final storyRows = await (db.select(db.stories)..where((t) => t.title.equals(cleanTitle))).get();
            if (storyRows.isNotEmpty) {
              matchedId = storyRows.first.id;
              matchedPageId = storyRows.first.pageId;
              matchedText = storyRows.first.textContent;
              matchedDesc = storyRows.first.description;
              matchedUrl = storyRows.first.url;
              targetSectionKey = 'stories';
            }
          }
          // Check songs
          if (matchedText.isEmpty) {
            final songRows = await (db.select(db.songs)..where((t) => t.title.equals(cleanTitle))).get();
            if (songRows.isNotEmpty) {
              matchedId = songRows.first.id;
              matchedPageId = songRows.first.pageId;
              matchedText = songRows.first.textContent;
              matchedDesc = songRows.first.category;
              matchedUrl = songRows.first.url;
              targetSectionKey = 'songs';
            }
          }
          // Check writings (Nias Wikipedia)
          if (matchedText.isEmpty) {
            final artRows = await (db.select(db.writings)..where((t) => t.title.equals(cleanTitle))).get();
            if (artRows.isNotEmpty) {
              matchedId = artRows.first.id;
              matchedPageId = artRows.first.pageId;
              matchedText = artRows.first.textContent;
              matchedDesc = artRows.first.description;
              matchedUrl = artRows.first.url;
              targetSectionKey = 'writings';
            }
          }
          // Check heritage articles
          if (matchedText.isEmpty) {
            final hRows = await (db.select(db.heritageArticles)
                  ..where((t) => t.title.equals(cleanTitle)))
                .get();
            if (hRows.isNotEmpty) {
              matchedPageId = hRows.first.pageId;
              matchedText = hRows.first.htmlContent ?? hRows.first.textContent;
              matchedUrl = 'https://${hRows.first.wikiHost}/wiki/${hRows.first.pageTitle}';
              targetSectionKey = 'writings';
            } else {
              final hPageRows = await (db.select(db.heritageArticles)
                    ..where((t) => t.pageTitle.equals(cleanTitle)))
                  .get();
              if (hPageRows.isNotEmpty) {
                matchedPageId = hPageRows.first.pageId;
                matchedText = hPageRows.first.htmlContent ?? hPageRows.first.textContent;
                matchedUrl = 'https://${hPageRows.first.wikiHost}/wiki/${hPageRows.first.pageTitle}';
                targetSectionKey = 'writings';
              }
            }
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;

    final isIncubator = (matchedUrl != null && matchedUrl.contains('incubator.wikimedia.org'));
    final String host = isIncubator
        ? WikiConfig.incubatorHost
        : (resolvedHost ?? WikiConfig.wikipediaHost);
    final String url = (matchedUrl != null && matchedUrl.isNotEmpty)
        ? (isIncubator
            ? matchedUrl
            : matchedUrl.replaceFirst('https://incubator.wikimedia.org/wiki/Wb/nia/', 'https://nia.wikipedia.org/wiki/'))
        : (isIncubator
            ? 'https://$host/wiki/Wb/nia/${Uri.encodeComponent(cleanTitle.replaceAll(" ", "_"))}'
            : 'https://$host/wiki/${Uri.encodeComponent(cleanTitle.replaceAll(" ", "_"))}');

    // Seamless in-place style crossfade transition maintaining the navigation stack
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SectionItemDetailScreen(
          id: matchedId,
          pageId: matchedPageId,
          title: cleanTitle,
          text: matchedText,
          description: matchedDesc ?? widget.description,
          url: url,
          sectionColor: widget.sectionColor,
          sectionKey: targetSectionKey,
          database: widget.database,
          wikiApiService: widget.wikiApiService,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
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
                        _title,
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
                  defaultWikiHost: WikiConfig.wikipediaHost,
                  onFootnoteTap: (fn) => showFootnoteBottomSheet(
                    context: context,
                    footnote: fn,
                    accentColor: widget.sectionColor,
                  ),
                  onArticleTap: (targetTitle, isRedLink, wikiHost) =>
                      _handleArticleTap(targetTitle, isRedLink, wikiHost),
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
