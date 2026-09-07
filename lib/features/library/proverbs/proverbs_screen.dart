import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../../core/database/database.dart';
import '../../../core/database/providers.dart';
import 'proverbs_detail_screen.dart';

class ProverbsScreen extends ConsumerStatefulWidget {
  const ProverbsScreen({super.key});

  @override
  ConsumerState<ProverbsScreen> createState() => _ProverbsScreenState();
}

class _ProverbsScreenState extends ConsumerState<ProverbsScreen> {
  late final ScrollController _scrollController;
  Timer? _hideAlphabetBarTimer;

  String _searchQuery = '';
  String? _selectedLetter;
  int? _selectedItemId;
  bool _showAlphabetBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _hideAlphabetBarTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_showAlphabetBar) {
      setState(() {
        _showAlphabetBar = true;
      });
    }
    _hideAlphabetBarTimer?.cancel();
    _hideAlphabetBarTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showAlphabetBar = false;
        });
      }
    });
  }

  String _getFirstLetter(String text) {
    final trimmed = text.trim();
    for (int i = 0; i < trimmed.length; i++) {
      final char = trimmed[i].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(char)) {
        return char;
      }
    }
    return '';
  }

  void _openSearchDialog() {
    final textController = TextEditingController(text: _searchQuery);

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.search, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'amaedola.search_placeholder'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'amaedola.search_placeholder'.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  textController.clear();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
              Navigator.of(dialogContext).pop();
            },
          ),
          actions: [
            if (_searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                  });
                  Navigator.of(dialogContext).pop();
                },
                child: Text('common.close'.tr()),
              ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _searchQuery = textController.text.trim();
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlphabetBar(List<String> letters, ThemeData theme) {
    if (letters.isEmpty) return const SizedBox.shrink();

    return MouseRegion(
      onEnter: (_) => _hideAlphabetBarTimer?.cancel(),
      onExit: (_) => _onScroll(),
      child: AnimatedOpacity(
        opacity: _showAlphabetBar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: !_showAlphabetBar,
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
            constraints: const BoxConstraints(maxWidth: 30),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: letters.map((letter) {
                  final isSelected = _selectedLetter == letter;
                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        if (_selectedLetter == letter) {
                          _selectedLetter = null;
                        } else {
                          _selectedLetter = letter;
                        }
                      });
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                      _onScroll();
                    },
                    child: Container(
                      width: 24,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        letter,
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
    final amaedolasAsync = ref.watch(amaedolaStreamProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'proverbs_search_fab',
        onPressed: _openSearchDialog,
        tooltip: 'amaedola.search_placeholder'.tr(),
        child: Badge(
          isLabelVisible: _searchQuery.isNotEmpty,
          label: const Text('1'),
          child: const Icon(Icons.search_rounded),
        ),
      ),
      body: ResponsiveContentWrapper(
        child: amaedolasAsync.when(
          data: (items) {
            // Extract sorted alphabetical letters that have items
            final letterSet = <String>{};
            for (final item in items) {
              final letter = _getFirstLetter(item.textContent);
              if (letter.isNotEmpty) {
                letterSet.add(letter);
              }
            }
            final sortedLetters = letterSet.toList()..sort();

            // Apply search query & letter filter
            final filteredItems = items.where((item) {
              final query = _searchQuery.toLowerCase();
              final textMatches = item.textContent.toLowerCase().contains(query);
              final meaningMatches = item.meaning.toLowerCase().contains(query);
              final meaningIdMatches = (item.meaningId ?? '').toLowerCase().contains(query);
              final meaningEnMatches = (item.meaningEn ?? '').toLowerCase().contains(query);
              final labelMatches = item.label.toLowerCase().contains(query);

              final matchesSearch = query.isEmpty ||
                  textMatches ||
                  meaningMatches ||
                  meaningIdMatches ||
                  meaningEnMatches ||
                  labelMatches;

              final matchesLetter = _selectedLetter == null ||
                  _getFirstLetter(item.textContent) == _selectedLetter;

              return matchesSearch && matchesLetter;
            }).toList();

            // Alphabetical sorting by textContent
            filteredItems.sort((a, b) {
              return a.textContent.toLowerCase().compareTo(b.textContent.toLowerCase());
            });

            // Set default selected item for desktop split pane
            if (isDesktop && _selectedItemId == null && filteredItems.isNotEmpty) {
              _selectedItemId = filteredItems.first.id;
            }

            Amaedola? activeItem;
            if (_selectedItemId != null) {
              final match = items.where((e) => e.id == _selectedItemId);
              if (match.isNotEmpty) {
                activeItem = match.first;
              } else if (filteredItems.isNotEmpty) {
                activeItem = filteredItems.first;
              }
            } else if (filteredItems.isNotEmpty) {
              activeItem = filteredItems.first;
            }

            final listScrollView = CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. Sliver App Bar with Hero Image banner
                SliverAppBar(
                  expandedHeight: 240.0,
                  pinned: true,
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'sections.proverbs'.tr(),
                      style: AppTheme.sliverAppBarTitleStyle(),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'proverbs_hero',
                          child: Image.asset(
                            'assets/images/proverbs.webp',
                            cacheWidth: 1080,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF059669),
                              child: const Center(
                                child: Icon(
                                  Icons.format_quote_rounded,
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
                  actions: [
                    if (_selectedLetter != null || _searchQuery.isNotEmpty)
                      IconButton(
                        tooltip: 'common.close'.tr(),
                        icon: const Icon(Icons.filter_alt_off_rounded),
                        onPressed: () {
                          setState(() {
                            _selectedLetter = null;
                            _searchQuery = '';
                          });
                        },
                      ),
                  ],
                ),

                // Active Filters Chips (Letter or Search)
                if (_selectedLetter != null || _searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (_selectedLetter != null)
                            InputChip(
                              avatar: const Icon(Icons.sort_by_alpha, size: 16),
                              label: Text('Letter: $_selectedLetter'),
                              onDeleted: () {
                                setState(() {
                                  _selectedLetter = null;
                                });
                              },
                            ),
                          if (_searchQuery.isNotEmpty)
                            InputChip(
                              avatar: const Icon(Icons.search, size: 16),
                              label: Text('Search: "$_searchQuery"'),
                              onDeleted: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                // Count Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'amaedola.count_found'.tr(args: [filteredItems.length.toString()]),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ),

                // Proverbs List or Empty State
                if (filteredItems.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('amaedola.no_matches'.tr()),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 36.0, 80.0),
                    sliver: SliverList.separated(
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected = activeItem?.id == item.id;

                        return Card(
                          elevation: isSelected && isDesktop ? 2 : 0,
                          color: isSelected && isDesktop
                              ? theme.colorScheme.surfaceContainerHighest
                              : theme.colorScheme.surfaceContainer,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                _selectedItemId = item.id;
                              });
                              if (!isDesktop) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProverbsDetailPage(item: item),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.textContent,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.label,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSecondaryContainer,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.meaning.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      item.meaning,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
              ],
            );

            final listWithAlphabetBar = Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification &&
                        notification.scrollDelta != null &&
                        notification.scrollDelta!.abs() > 0.5) {
                      _onScroll();
                    }
                    return false;
                  },
                  child: listScrollView,
                ),
                Positioned(
                  right: 4,
                  top: 70,
                  bottom: 90,
                  child: _buildAlphabetBar(sortedLetters, theme),
                ),
              ],
            );

            if (isDesktop) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: listWithAlphabetBar,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 3,
                    child: activeItem == null
                        ? Center(child: Text('amaedola.select_to_view'.tr()))
                        : ProverbsDetailWidget(item: activeItem),
                  ),
                ],
              );
            }

            return listWithAlphabetBar;
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text('amaedola.error_loading'.tr(args: [e.toString()])),
          ),
        ),
      ),
    );
  }
}

// Backwards compatibility alias
typedef AmaedolaScreen = ProverbsScreen;
