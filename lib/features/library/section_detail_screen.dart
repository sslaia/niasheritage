import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import '../../core/database/providers.dart';
import '../../core/services/wiki_sync_provider.dart';
import 'section_item_detail_screen.dart';

final sectionItemsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, sectionKey) async {
  final db = ref.watch(databaseProvider);

  if (sectionKey == 'recitation' || sectionKey == 'epic' || sectionKey == 'hoho') {
    final rows = await (db.select(db.recitations)..orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)])).get();
    return rows
        .map((r) => {
              'id': r.id,
              'title': r.title,
              'text': r.textContent,
              'description': r.description ?? r.descId ?? r.descEn ?? '',
              'url': r.url,
            })
        .toList();
  } else if (sectionKey == 'stories' || sectionKey == 'mano_mano') {
    final rows = await (db.select(db.stories)..orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)])).get();
    return rows
        .map((r) => {
              'id': r.id,
              'title': r.title,
              'text': r.textContent,
              'description': r.description ?? r.origin ?? '',
              'url': r.url,
            })
        .toList();
  } else if (sectionKey == 'songs' || sectionKey == 'sinuno') {
    final rows = await (db.select(db.songs)..orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)])).get();
    return rows
        .map((r) => {
              'id': r.id,
              'title': r.title,
              'text': r.textContent,
              'description': r.category,
              'url': r.url,
            })
        .toList();
  } else if (sectionKey == 'articles' || sectionKey == 'sura_amilita') {
    final rows = await (db.select(db.articles)
          ..where((t) => t.category.equals('featured'))
          ..orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)]))
        .get();
    return rows
        .map((r) => {
              'id': r.id,
              'title': r.title,
              'text': r.textContent,
              'description': r.description ?? 'Wikipedia Nias',
              'url': 'https://nia.wikipedia.org/wiki/${Uri.encodeComponent(r.title)}',
            })
        .toList();
  } else if (sectionKey == 'writings' || sectionKey == 'sinura') {
    final rows = await (db.select(db.articles)
          ..where((t) => t.category.isNotValue('featured'))
          ..orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)]))
        .get();
    return rows
        .map((r) => {
              'id': r.id,
              'title': r.title,
              'text': r.textContent,
              'description': r.description ?? r.category,
              'url': null,
            })
        .toList();
  }

  return [];
});

// Alias for compatibility
final sectionItemsStreamProvider = sectionItemsProvider;

class SectionDetailScreen extends ConsumerStatefulWidget {
  final String sectionKey;
  final String title;

  const SectionDetailScreen({
    super.key,
    required this.sectionKey,
    required this.title,
  });

  @override
  ConsumerState<SectionDetailScreen> createState() => _SectionDetailScreenState();
}

class _SectionDetailScreenState extends ConsumerState<SectionDetailScreen> {
  String _searchQuery = '';
  bool _isSyncing = false;

  Future<void> _syncSection() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final syncService = ref.read(wikiSyncServiceProvider);
    String? catTitle;
    String pageType = 'article';
    String wikiHost = 'incubator.wikimedia.org';

    switch (widget.sectionKey) {
      case 'songs':
      case 'sinuno':
        catTitle = 'Category:Wb/nia/Sinunö Nono Niha';
        pageType = 'song';
        break;
      case 'stories':
      case 'mano_mano':
        catTitle = 'Category:Wb/nia/Manö-manö';
        pageType = 'stories';
        break;
      case 'recitation':
      case 'epic':
      case 'hoho':
        catTitle = 'Category:Wb/nia/Hoho';
        pageType = 'recitation';
        break;
      case 'writings':
      case 'sinura':
        catTitle = 'Category:Wb/nia/Sinura amilita';
        pageType = 'article';
        break;
      case 'articles':
      case 'sura_amilita':
        catTitle = 'Kategori:Sura amilita';
        pageType = 'featured_article';
        wikiHost = 'nia.wikipedia.org';
        break;
      case 'proverbs':
      case 'bible':
      default:
        // Proverbs and Bible are exempt from category discoveries
        catTitle = null;
        break;
    }

    try {
      int updatedCount = 0;
      if (catTitle != null) {
        final discovered = await syncService.discoverCategoryPages(
          categoryTitle: catTitle,
          pageType: pageType,
          wikiHost: wikiHost,
          force: true,
        );
        if (discovered.isNotEmpty) {
          updatedCount = await syncService.updateChangedPages(discovered);
        }
      }

      if (updatedCount > 0) {
        ref.invalidate(sectionItemsProvider(widget.sectionKey));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedCount > 0
                  ? 'settings.sync_success'.tr(args: [updatedCount.toString()])
                  : 'settings.already_up_to_date'.tr(),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('settings.sync_error'.tr(args: [e.toString()])),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Color _getSectionColor(String sectionKey) {
    switch (sectionKey) {
      case 'stories':
      case 'mano_mano':
        return const Color(0xFFEAB308); // Yellow
      case 'recitation':
      case 'epic':
      case 'hoho':
        return const Color(0xFF6366F1); // Indigo
      case 'songs':
      case 'sinuno':
        return const Color(0xFFFF5722); // Deep Orange
      case 'articles':
      case 'sura_amilita':
        return const Color(0xFF059669); // Emerald Green
      case 'writings':
      case 'sinura':
      default:
        return const Color(0xFF2563EB); // Blue
    }
  }

  String _getHeroImagePath(String sectionKey) {
    switch (sectionKey) {
      case 'stories':
      case 'mano_mano':
        return 'assets/images/stories.webp';
      case 'recitation':
      case 'epic':
      case 'hoho':
        return 'assets/images/recitation.webp';
      case 'songs':
      case 'sinuno':
        return 'assets/images/songs.webp';
      case 'articles':
      case 'sura_amilita':
        return 'assets/images/library.webp';
      case 'writings':
      case 'sinura':
      default:
        return 'assets/images/writings.webp';
    }
  }

  IconData _getSectionIcon(String sectionKey) {
    switch (sectionKey) {
      case 'stories':
      case 'mano_mano':
        return Icons.import_contacts_rounded;
      case 'recitation':
      case 'epic':
      case 'hoho':
        return Icons.menu_book_rounded;
      case 'songs':
      case 'sinuno':
        return Icons.music_note_rounded;
      case 'articles':
      case 'sura_amilita':
        return Icons.auto_awesome_rounded;
      case 'writings':
      case 'sinura':
      default:
        return Icons.article_rounded;
    }
  }

  String _cleanPreviewText(String rawText) {
    return rawText
        // Remove wiki files and images e.g. [[File:...]], [[Berkas:...]], [[Gambar:...]], [[Image:...]]
        .replaceAll(RegExp(r'\[\[(?:File|Berkas|Gambar|Image):[^\]]+\]\]', caseSensitive: false), '')
        // Remove wiki templates {{...}}
        .replaceAll(RegExp(r'\{\{[^\}]+\}\}'), '')
        // Remove headings ==...==
        .replaceAll(RegExp(r'==+[^=]+==+'), '')
        // Convert internal wiki links [[Target|Label]] -> Label, [[Target]] -> Target
        .replaceAllMapped(RegExp(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]'), (m) => m.group(1) ?? '')
        // Remove bold and italics
        .replaceAll(RegExp(r"'''?"), '')
        // Remove HTML tags
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        // Normalize whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(sectionItemsProvider(widget.sectionKey));
    final Color sectionColor = _getSectionColor(widget.sectionKey);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _syncSection,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 240.0,
              pinned: true,
              backgroundColor: sectionColor,
              foregroundColor: Colors.white,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    child: _isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.sync_rounded, color: Colors.white),
                            tooltip: 'settings.sync'.tr(),
                            onPressed: _syncSection,
                          ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.title,
                  style: AppTheme.sliverAppBarTitleStyle(),
                ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'library_hero_${widget.sectionKey}',
                    child: Image.asset(
                      _getHeroImagePath(widget.sectionKey),
                      cacheWidth: 1080,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: sectionColor,
                        child: Center(
                          child: Icon(
                            _getSectionIcon(widget.sectionKey),
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

          // Search Bar
          SliverToBoxAdapter(
            child: ResponsiveContentWrapper(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'search_placeholder'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
            ),
          ),

          // Items Content
          itemsAsync.when(
            data: (items) {
              final filtered = items.where((item) {
                final title = (item['title'] as String).toLowerCase();
                final text = (item['text'] as String).toLowerCase();
                final desc = (item['description'] as String).toLowerCase();
                final query = _searchQuery.toLowerCase();
                return title.contains(query) || text.contains(query) || desc.contains(query);
              }).toList();

              if (items.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: ResponsiveContentWrapper(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: sectionColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.construction_rounded, size: 56, color: sectionColor),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'library.work_in_progress'.tr(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: sectionColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'library_empty'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'library.update_from_settings_hint'.tr(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: ResponsiveContentWrapper(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.outline),
                            const SizedBox(height: 16),
                            Text(
                              'library_empty'.tr(),
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: ResponsiveContentWrapper(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final rawText = item['text'] as String;
                      final previewText = _cleanPreviewText(rawText);
                      return Card(
                        elevation: 1,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: sectionColor.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SectionItemDetailScreen(
                                  title: item['title'] as String,
                                  text: item['text'] as String,
                                  description: item['description'] as String?,
                                  url: item['url'] as String?,
                                  sectionColor: sectionColor,
                                  sectionKey: widget.sectionKey,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] as String,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (item['description'] != null &&
                                              (item['description'] as String).isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              item['description'] as String,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: sectionColor,
                                    ),
                                  ],
                                ),
                                if (previewText.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    previewText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('common.error'.tr(args: [e.toString()]))),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

