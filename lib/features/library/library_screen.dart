import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/footer_attribution.dart';
import '../../core/database/providers.dart';
import 'proverbs/proverbs_screen.dart';
import 'bible/bible_screen.dart';
import 'section_detail_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  static const accentColor = Color(0xFF6D4C41); // Deep Warm Brown / Teak Wood

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final proverbsAsync = ref.watch(proverbsStreamProvider);
    final proverbsCount = proverbsAsync.maybeWhen(
      data: (items) => items.length,
      orElse: () => 749,
    );

    final List<Map<String, dynamic>> sections = [
      {
        'key': 'proverbs',
        'title': 'sections.proverbs'.tr(),
        'nativeTitle': 'Amaedola',
        'desc': 'sections.proverbs_desc'.tr(),
        'icon': Icons.format_quote_rounded,
        'color': const Color(0xFFD97706), // Amber
        'badge': 'library.badges.proverbs'.tr(args: [proverbsCount.toString()]),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProverbsScreen()),
        ),
      },
      {
        'key': 'bible',
        'title': 'sections.bible'.tr(),
        'nativeTitle': "Sura Ni'amoni'ö",
        'desc': 'sections.bible_desc'.tr(),
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF2563EB), // Blue
        'badge': 'library.badges.bible'.tr(),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BibleScreen()),
        ),
      },
      {
        'key': 'recitation',
        'title': 'sections.recitation'.tr().contains('sections.') ? 'sections.epic'.tr() : 'sections.recitation'.tr(),
        'nativeTitle': 'Hoho',
        'desc': 'sections.recitation_desc'.tr().contains('sections.') ? 'sections.epic_desc'.tr() : 'sections.recitation_desc'.tr(),
        'icon': Icons.auto_stories_rounded,
        'color': const Color(0xFF6366F1), // Indigo
        'badge': 'library.badges.recitation'.tr().contains('library.badges.') ? 'library.badges.epic'.tr() : 'library.badges.recitation'.tr(),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SectionDetailScreen(
              sectionKey: 'recitation',
              title: 'sections.recitation'.tr().contains('sections.') ? 'sections.epic'.tr() : 'sections.recitation'.tr(),
            ),
          ),
        ),
      },
      {
        'key': 'stories',
        'title': 'sections.stories'.tr(),
        'nativeTitle': 'Manö-manö',
        'desc': 'sections.stories_desc'.tr(),
        'icon': Icons.import_contacts_rounded,
        'color': const Color(0xFFEAB308), // Yellow
        'badge': 'library.badges.stories'.tr(),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SectionDetailScreen(
              sectionKey: 'stories',
              title: 'sections.stories'.tr(),
            ),
          ),
        ),
      },
      {
        'key': 'songs',
        'title': 'sections.songs'.tr(),
        'nativeTitle': 'Sinunö',
        'desc': 'sections.songs_desc'.tr(),
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFFFF5722), // Deep Orange
        'badge': 'library.badges.songs'.tr(),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SectionDetailScreen(
              sectionKey: 'songs',
              title: 'sections.songs'.tr(),
            ),
          ),
        ),
      },
      {
        'key': 'writings',
        'title': 'sections.writings'.tr(),
        'nativeTitle': 'Sinura',
        'desc': 'sections.writings_desc'.tr(),
        'icon': Icons.article_rounded,
        'color': const Color(0xFF2563EB), // Blue
        'badge': 'library.badges.writings'.tr(),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SectionDetailScreen(
              sectionKey: 'writings',
              title: 'sections.writings'.tr(),
            ),
          ),
        ),
      },
      {
        'key': 'articles',
        'title': 'sections.articles'.tr(),
        'nativeTitle': 'Sura Amilita',
        'desc': 'sections.articles_desc'.tr(),
        'icon': Icons.auto_awesome_rounded,
        'color': const Color(0xFF059669), // Emerald Green
        'badge': 'library.badges.articles'.tr(),
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SectionDetailScreen(
              sectionKey: 'articles',
              title: 'sections.articles'.tr(),
            ),
          ),
        ),
      },
    ];

    final filteredSections = sections.where((sec) {
      final title = (sec['title'] as String).toLowerCase();
      final native = (sec['nativeTitle'] as String).toLowerCase();
      final desc = (sec['desc'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) ||
          native.contains(query) ||
          desc.contains(query);
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Banner with Drawing Image
          SliverAppBar(
            expandedHeight: 220.0,
            pinned: true,
            backgroundColor: LibraryScreen.accentColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 16,
                bottom: 16,
                right: 16,
              ),
              title: Text(
                'library.title'.tr(),
                style: AppTheme.sliverAppBarTitleStyle(),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/library.webp',
                    cacheWidth: 1080,
                    fit: BoxFit.cover,
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 48,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.collections_bookmark_rounded,
                            color: Color(0xFFF59E0B),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'library.header_badge'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar & Main Section Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      hintText: 'search_placeholder'.tr(),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'library.collections_title'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Cards Grid / List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSections.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sec = filteredSections[index];
                      final Color cardColor = sec['color'] as Color;

                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        child: InkWell(
                          onTap: sec['onTap'] as VoidCallback,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: cardColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: cardColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    sec['icon'] as IconData,
                                    color: cardColor,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              sec['title'] as String,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: 130,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: cardColor.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              sec['badge'] as String,
                                              style: TextStyle(
                                                color: cardColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        sec['desc'] as String,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              height: 1.3,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const FooterAttribution(
                    padding: EdgeInsets.only(top: 8.0, bottom: 32.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
