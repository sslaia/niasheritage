import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'providers/bible_providers.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/database/database.dart';
import '../../../core/services/wiki_sync_provider.dart';

class BibleSingleChapterScreen extends ConsumerStatefulWidget {
  final String book;
  final int initialChapter;
  final int? targetVerse;
  final String? highlightKeyword;

  const BibleSingleChapterScreen({
    super.key,
    required this.book,
    required this.initialChapter,
    this.targetVerse,
    this.highlightKeyword,
  });

  @override
  ConsumerState<BibleSingleChapterScreen> createState() => _BibleSingleChapterScreenState();
}

class _BibleSingleChapterScreenState extends ConsumerState<BibleSingleChapterScreen> {
  late int _currentChapter;
  int? _targetVerse;
  String? _highlightKeyword;

  late final ScrollController _scrollController;
  Timer? _hideChapterBarTimer;
  bool _showChapterBar = false;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _targetVerse = widget.targetVerse;
    _highlightKeyword = widget.highlightKeyword;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _checkPageForOnlineUpdates();
  }

  @override
  void dispose() {
    _hideChapterBarTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_showChapterBar) {
      setState(() {
        _showChapterBar = true;
      });
    }
    _hideChapterBarTimer?.cancel();
    _hideChapterBarTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showChapterBar = false;
        });
      }
    });
  }

  void _checkPageForOnlineUpdates() async {
    try {
      final verses = await ref.read(
        bibleChapterVersesProvider(BibleChapterParam(book: widget.book, chapter: _currentChapter)).future,
      );
      if (verses.isNotEmpty) {
        final firstVerse = verses.first;
        final updated = await ref.read(wikiSyncServiceProvider).checkAndUpdateSinglePage(
          pageId: firstVerse.pageId,
          pageTitle: 'Wb/nia/${widget.book}/$_currentChapter',
          pageType: 'bible',
          book: widget.book,
          chapter: _currentChapter,
          category: firstVerse.category,
        );
        if (updated && mounted) {
          ref.invalidate(
            bibleChapterVersesProvider(BibleChapterParam(book: widget.book, chapter: _currentChapter)),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('bible.updated_chapter_server'.tr())),
          );
        }
      }
    } catch (_) {}
  }

  void _openFindInPageDialog() {
    final textController = TextEditingController(text: _highlightKeyword ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.find_in_page_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'bible.find_in_page'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ],
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'bible.find_in_page_hint'.tr(),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: textController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        textController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              Navigator.pop(dialogContext);
              final trimmed = val.trim();
              setState(() {
                _highlightKeyword = trimmed.isNotEmpty ? trimmed : null;
              });
            },
          ),
          actions: [
            if (_highlightKeyword != null && _highlightKeyword!.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  setState(() {
                    _highlightKeyword = null;
                  });
                },
                child: Text('bible.clear_highlight'.tr()),
              ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                final trimmed = textController.text.trim();
                setState(() {
                  _highlightKeyword = trimmed.isNotEmpty ? trimmed : null;
                });
              },
              child: Text('bible.find_in_page_action'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _showReferencesBottomSheet(BuildContext context, List<String> references, String? note) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'bible.cross_references'.tr(),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (references.isNotEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: references.map((refStr) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Icon(Icons.bookmark_outline, size: 16, color: theme.colorScheme.onPrimaryContainer),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: SelectableText(
                                          refStr,
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ] else ...[
                          Text(
                            'bible.no_cross_references'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                        if (note != null && note.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: theme.colorScheme.secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SelectableText(
                                    note,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapterBar(List<int> chapters, ThemeData theme) {
    if (chapters.isEmpty) return const SizedBox.shrink();

    return MouseRegion(
      onEnter: (_) => _hideChapterBarTimer?.cancel(),
      onExit: (_) => _onScroll(),
      child: AnimatedOpacity(
        opacity: _showChapterBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: !_showChapterBar,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            constraints: const BoxConstraints(maxWidth: 34),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: chapters.map((ch) {
                  final isSelected = _currentChapter == ch;
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _currentChapter = ch;
                        _targetVerse = null;
                      });
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                      _onScroll();
                      _checkPageForOnlineUpdates();
                    },
                    child: Container(
                      width: 28,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$ch',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chaptersAsync = ref.watch(bibleBookChaptersProvider(widget.book));
    final versesAsync = ref.watch(
      bibleChapterVersesProvider(BibleChapterParam(book: widget.book, chapter: _currentChapter)),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'single_chapter_find_fab',
        tooltip: 'bible.find_in_page'.tr(),
        onPressed: _openFindInPageDialog,
        child: const Icon(Icons.find_in_page_rounded),
      ),
      body: ResponsiveContentWrapper(
        child: chaptersAsync.when(
          data: (chapters) {
            final scrollContent = CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. Sliver App Bar consisting only the name of the book and the chapter number
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  title: Text(
                    '${widget.book} $_currentChapter',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: false,
                ),

                // Active Keyword Chip if Find in Page is active
                if (_highlightKeyword != null && _highlightKeyword!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 42.0, 0.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: InputChip(
                          avatar: const Icon(Icons.highlight, size: 16),
                          label: Text(
                            '${'bible.highlighted'.tr()}: "$_highlightKeyword"',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onDeleted: () {
                            setState(() {
                              _highlightKeyword = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                // Verses Content Area
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 42.0, 80.0),
                  sliver: SliverToBoxAdapter(
                    child: SelectionArea(
                      child: versesAsync.when(
                        data: (verses) {
                          if (verses.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'bible.no_verses'.tr(),
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                            );
                          }
                          return _buildContinuousParagraphView(context, theme, verses);
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(child: Text('common.error'.tr(args: [e.toString()]))),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );

            return Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is UserScrollNotification ||
                        (notification is ScrollUpdateNotification &&
                            notification.scrollDelta != null &&
                            notification.scrollDelta!.abs() > 0.5) ||
                        notification is OverscrollNotification) {
                      _onScroll();
                    }
                    return false;
                  },
                  child: scrollContent,
                ),
                // 3. Scroll-activated vertical chapter strip on the right edge
                Positioned(
                  right: 4,
                  top: 70,
                  bottom: 90,
                  child: _buildChapterBar(chapters, theme),
                ),
              ],
            );
          },
          loading: () => CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                title: Text(
                  '${widget.book} $_currentChapter',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: false,
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (e, _) => CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                title: Text(
                  '${widget.book} $_currentChapter',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: false,
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('common.error'.tr(args: [e.toString()]))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinuousParagraphView(BuildContext context, ThemeData theme, List<Bible> verses) {
    final List<InlineSpan> spans = [];

    for (int i = 0; i < verses.length; i++) {
      final verse = verses[i];
      final rawText = verse.textContent;
      final prevText = i > 0 ? verses[i - 1].textContent.trim() : '';

      final bool isNewParagraph = i > 0 &&
          (rawText.startsWith('\n') ||
           prevText.endsWith(':') ||
           prevText.endsWith('."') ||
           prevText.endsWith('?"') ||
           prevText.endsWith('!"') ||
           prevText.endsWith('imane:') ||
           prevText.endsWith('imanö:'));

      if (isNewParagraph) {
        spans.add(const TextSpan(text: '\n\n'));
      }

      final bool isTargetVerse = _targetVerse != null && verse.verse == _targetVerse;

      // Verse number with trailing space for clean copying
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTargetVerse ? 6.0 : 0.0,
              vertical: isTargetVerse ? 2.0 : 0.0,
            ),
            margin: const EdgeInsets.only(right: 6, left: 4),
            decoration: isTargetVerse
                ? BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              '${verse.verse} ',
              style: TextStyle(
                color: isTargetVerse
                    ? theme.colorScheme.onPrimaryContainer
                    : const Color(0xFF2E7D32),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      final displayText = rawText.trimLeft();
      final references = verse.reference ?? [];

      final normalStyle = theme.textTheme.bodyLarge?.copyWith(
            height: 1.8,
            color: theme.colorScheme.onSurface,
          ) ??
          const TextStyle();

      final highlightStyle = normalStyle.copyWith(
        backgroundColor: const Color(0xFFFFD54F),
        color: Colors.black,
        fontWeight: FontWeight.bold,
      );

      spans.addAll(_buildHighlightedSpans(
        '$displayText ',
        _highlightKeyword,
        normalStyle,
        highlightStyle,
      ));

      // Interactive reference badge disabled from SelectionArea text copy
      if (references.isNotEmpty || (verse.note != null && verse.note!.isNotEmpty)) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SelectionContainer.disabled(
              child: GestureDetector(
                onTap: () => _showReferencesBottomSheet(context, references, verse.note),
                child: Container(
                  margin: const EdgeInsets.only(left: 2, right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_outline, size: 11, color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 2),
                      Text(
                        references.isNotEmpty ? '${references.length}' : '*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Text.rich(
        TextSpan(children: spans),
      ),
    );
  }

  List<TextSpan> _buildHighlightedSpans(
    String text,
    String? keyword,
    TextStyle normalStyle,
    TextStyle highlightStyle,
  ) {
    if (keyword == null || keyword.trim().isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    final cleanKeyword = keyword.trim();
    final lowerKeyword = cleanKeyword.toLowerCase();
    final lowerText = text.toLowerCase();
    final List<TextSpan> result = [];

    int start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerKeyword, start);
      if (index == -1) {
        if (start < text.length) {
          result.add(TextSpan(text: text.substring(start), style: normalStyle));
        }
        break;
      }
      if (index > start) {
        result.add(TextSpan(text: text.substring(start, index), style: normalStyle));
      }
      result.add(TextSpan(
        text: text.substring(index, index + cleanKeyword.length),
        style: highlightStyle,
      ));
      start = index + cleanKeyword.length;
    }

    return result.isEmpty ? [TextSpan(text: text, style: normalStyle)] : result;
  }
}
