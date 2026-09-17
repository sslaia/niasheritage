import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/widgets/app_bar_circle_action.dart';
import 'providers/bible_providers.dart';
import 'services/bible_service.dart';
import 'bible_book_screen.dart';

class BibleScreen extends ConsumerWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final booksAsync = ref.watch(bibleOnlineBooksProvider);

    final isDesktop = MediaQuery.of(context).size.width > 900;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return Scaffold(
      body: ResponsiveContentWrapper(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(bibleOnlineBooksProvider);
            await ref.read(bibleOnlineBooksProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Sliver App Bar with Title "Sura Ni'amoni'ö" and Hero Background
              SliverAppBar(
                expandedHeight: 220.0,
                pinned: true,
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                centerTitle: false,
                leading: const AppBarCircleBackButton(),
                actions: [
                  AppBarCircleAction.icon(
                    icon: Icons.refresh_rounded,
                    tooltip: 'common.refresh'.tr(),
                    onPressed: () {
                      ref.invalidate(bibleOnlineBooksProvider);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16, end: 64),
                  title: Text(
                    'bible.title'.tr(),
                    style: AppTheme.sliverAppBarTitleStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

              // 2. Books List
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
                          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.auto_stories,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'bible.new_testament'.tr(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: AppTheme.subheadingStyle(
                                    color: theme.colorScheme.onSurface,
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
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.4,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildBookCard(context, theme, ntBooks[index]),
                            childCount: ntBooks.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 20),
                      ),
                    ],

                    // Old Testament Section
                    if (otBooks.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'bible.old_testament'.tr(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: AppTheme.subheadingStyle(
                                    color: theme.colorScheme.onSurface,
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
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.4,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildBookCard(context, theme, otBooks[index]),
                            childCount: otBooks.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 60),
                      ),
                    ],
                  ];
                },
                loading: () => [
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
                error: (e, _) => [
                  SliverFillRemaining(
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
                              'common.error'.tr(args: [e.toString()]),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonalIcon(
                              onPressed: () => ref.invalidate(bibleOnlineBooksProvider),
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text('common.retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, ThemeData theme, BibleBookEntry book) {
    return Card(
      color: theme.colorScheme.surfaceContainer,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BibleBookScreen(book: book.name),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Center(
            child: Text(
              book.name,
              // Bigger, prominent font size as specified in BIBLE-SECTION-SCREEN-REDESIGN.md
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
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
