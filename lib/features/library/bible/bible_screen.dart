import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import 'providers/bible_providers.dart';
import 'bible_single_book_screen.dart';
import 'bible_search_dialog.dart';

class BibleScreen extends ConsumerWidget {
  const BibleScreen({super.key});

  void _openSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const BibleSearchDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final booksAsync = ref.watch(bibleBooksStreamProvider);

    final isDesktop = MediaQuery.of(context).size.width > 900;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'bible_search_fab',
        onPressed: () => _openSearchDialog(context),
        tooltip: 'bible.search_verses'.tr(),
        child: const Icon(Icons.search_rounded),
      ),
      body: ResponsiveContentWrapper(
        child: CustomScrollView(
          slivers: [
            // 1. Sliver App Bar with Hero Image banner
            SliverAppBar(
              expandedHeight: 240.0,
              pinned: true,
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'bible.title'.tr(),
                  style: AppTheme.sliverAppBarTitleStyle(),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'bible_hero',
                      child: Image.asset(
                        'assets/images/bible.webp',
                        cacheWidth: 1080,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF2563EB),
                          child: const Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              size: 72,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
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

            ...booksAsync.when(
              data: (allBooks) {
                final ntBooks = allBooks.where((b) => b.category == 'NT').toList();
                final otBooks = allBooks.where((b) => b.category == 'OT').toList();

                if (allBooks.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'bible.no_books'.tr(),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ];
                }

                return [
                  // New Testament Section
                  if (ntBooks.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_stories,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'bible.new_testament'.tr(),
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildBookCard(context, theme, ntBooks[index]),
                          childCount: ntBooks.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],

                  // Old Testament Section
                  if (otBooks.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.menu_book,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'bible.old_testament'.tr(),
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildBookCard(context, theme, otBooks[index]),
                          childCount: otBooks.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('common.error'.tr(args: [e.toString()]))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, ThemeData theme, BibleBookInfo book) {
    return Card(
      color: theme.colorScheme.surfaceContainer,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BibleSingleBookScreen(book: book.book),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
          child: Center(
            child: Text(
              book.book,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
