import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/widgets/app_bar_circle_action.dart';
import '../../heritage/widgets/heritage_article_content_view.dart';
import 'providers/bible_providers.dart';
import 'services/bible_service.dart';

class BibleBookScreen extends ConsumerStatefulWidget {
  final String book;
  final int initialChapter;
  final BibleService? bibleService;

  const BibleBookScreen({
    super.key,
    required this.book,
    this.initialChapter = 1,
    this.bibleService,
  });

  @override
  ConsumerState<BibleBookScreen> createState() => _BibleBookScreenState();
}

class _BibleBookScreenState extends ConsumerState<BibleBookScreen> {
  late String _currentBook;
  late int _currentChapter;
  final ScrollController _scrollController = ScrollController();

  static const Color bibleAccentColor = Color(0xFF2563EB); // Deep Bible Blue

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
    _currentChapter = widget.initialChapter;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  /// Opens the Book Selector modal bottom sheet so users can easily switch books
  void _openBookSelector(BuildContext context, List<BibleBookEntry> allBooks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final ntBooks = allBooks.where((b) => b.category == 'NT').toList();
        final otBooks = allBooks.where((b) => b.category == 'OT').toList();

        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            expand: false,
            builder: (ctx, scrollCtrl) {
              return Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, color: bibleAccentColor),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'bible.select_book'.tr(),
                            style: AppTheme.subheadingStyle(color: theme.colorScheme.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Scrollable Books List
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (ntBooks.isNotEmpty) ...[
                          Text(
                            'bible.new_testament'.tr(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: bibleAccentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ntBooks.map((b) {
                              final isSelected = b.name == _currentBook;
                              return ChoiceChip(
                                label: Text(b.name),
                                selected: isSelected,
                                selectedColor: bibleAccentColor.withValues(alpha: 0.2),
                                onSelected: (val) {
                                  Navigator.pop(sheetContext);
                                  if (b.name != _currentBook) {
                                    setState(() {
                                      _currentBook = b.name;
                                      _currentChapter = 1;
                                    });
                                    _scrollToTop();
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (otBooks.isNotEmpty) ...[
                          Text(
                            'bible.old_testament'.tr(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: bibleAccentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: otBooks.map((b) {
                              final isSelected = b.name == _currentBook;
                              return ChoiceChip(
                                label: Text(b.name),
                                selected: isSelected,
                                selectedColor: bibleAccentColor.withValues(alpha: 0.2),
                                onSelected: (val) {
                                  Navigator.pop(sheetContext);
                                  if (b.name != _currentBook) {
                                    setState(() {
                                      _currentBook = b.name;
                                      _currentChapter = 1;
                                    });
                                    _scrollToTop();
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Opens Chapter selection bottom sheet
  void _openChapterSelector(BuildContext context, List<int> chapters) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '$_currentBook - ${'bible.select_chapter'.tr()}',
                        style: AppTheme.subheadingStyle(color: theme.colorScheme.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const Divider(height: 16),

                // Grid of chapters
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: chapters.map((ch) {
                          final isSelected = ch == _currentChapter;
                          return SizedBox(
                            width: 52,
                            height: 44,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: isSelected ? bibleAccentColor : theme.colorScheme.surfaceContainerHighest,
                                foregroundColor: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                if (ch != _currentChapter) {
                                  setState(() {
                                    _currentChapter = ch;
                                  });
                                  _scrollToTop();
                                }
                              },
                              child: Text(
                                '$ch',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chaptersAsync = ref.watch(bibleOnlineChaptersProvider(_currentBook));
    final chapterQuery = BibleChapterQuery(book: _currentBook, chapter: _currentChapter);
    final contentAsync = ref.watch(bibleChapterContentProvider(chapterQuery));
    final booksAsync = ref.watch(bibleOnlineBooksProvider);

    final chaptersList = chaptersAsync.maybeWhen(
      data: (list) => list,
      orElse: () => [_currentChapter],
    );

    // Dynamic clean title e.g. "Mareko 3" (not "Mareko/3")
    final displayTitle = '$_currentBook $_currentChapter';

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'bible_chapter_fab',
        backgroundColor: bibleAccentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.format_list_numbered_rounded),
        label: Text(
          '$_currentChapter / ${chaptersList.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _openChapterSelector(context, chaptersList);
        },
      ),
      body: ResponsiveContentWrapper(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(bibleChapterContentProvider(chapterQuery));
            await ref.read(bibleChapterContentProvider(chapterQuery).future);
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Sliver App Bar with Dynamic Title & Protected Action Buttons
              SliverAppBar(
                expandedHeight: 180.0,
                pinned: true,
                backgroundColor: bibleAccentColor,
                foregroundColor: Colors.white,
                centerTitle: false,
                leading: const AppBarCircleBackButton(),
                actions: [
                  // Refresh Button with background circle protection
                  AppBarCircleAction.icon(
                    margin: const EdgeInsets.only(right: 6),
                    icon: Icons.refresh_rounded,
                    tooltip: 'common.refresh'.tr(),
                    onPressed: () {
                      ref.invalidate(bibleChapterContentProvider(chapterQuery));
                    },
                  ),

                  // Books Button with background circle protection
                  AppBarCircleAction.icon(
                    margin: const EdgeInsets.only(right: 12),
                    icon: Icons.menu_book_rounded,
                    tooltip: 'bible.select_book'.tr(),
                    onPressed: () {
                      final books = booksAsync.maybeWhen(
                        data: (b) => b,
                        orElse: () => <BibleBookEntry>[],
                      );
                      if (books.isNotEmpty) {
                        _openBookSelector(context, books);
                      } else {
                        ref.read(bibleOnlineBooksProvider.future).then((loadedBooks) {
                          if (context.mounted) {
                            _openBookSelector(context, loadedBooks);
                          }
                        });
                      }
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16, end: 110),
                  title: Text(
                    displayTitle,
                    style: AppTheme.sliverAppBarTitleStyle(fontSize: 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: bibleAccentColor,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black26,
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Chapter Content
              contentAsync.when(
                data: (content) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 96.0),
                      child: HeritageArticleContentView(
                        htmlContent: content.html,
                        footnotes: content.footnotes,
                        accentColor: bibleAccentColor,
                        onFootnoteTap: (footnote) {
                          showFootnoteBottomSheet(
                            context: context,
                            footnote: footnote,
                            accentColor: bibleAccentColor,
                          );
                        },
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'common.error'.tr(args: [err.toString()]),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: () => ref.invalidate(bibleChapterContentProvider(chapterQuery)),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text('common.retry'.tr()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
