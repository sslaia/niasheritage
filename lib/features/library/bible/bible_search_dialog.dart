import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/database/database.dart';
import 'providers/bible_providers.dart';
import 'bible_single_chapter_screen.dart';

class BibleSearchDialog extends ConsumerStatefulWidget {
  const BibleSearchDialog({super.key});

  @override
  ConsumerState<BibleSearchDialog> createState() => _BibleSearchDialogState();
}

class _BibleSearchDialogState extends ConsumerState<BibleSearchDialog> {
  final TextEditingController _controller = TextEditingController();
  List<Bible> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchedQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchedQuery = query;
    });

    try {
      final results = await ref.read(bibleVerseSearchProvider(query).future);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
      }
    }
  }

  List<TextSpan> _buildHighlightedSpans(
    String text,
    String keyword,
    TextStyle normalStyle,
    TextStyle highlightStyle,
  ) {
    if (keyword.isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    final lowerKeyword = keyword.toLowerCase();
    final lowerText = text.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerKeyword, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: normalStyle));
        }
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: normalStyle));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: highlightStyle,
      ));
      start = index + keyword.length;
    }

    return spans.isEmpty ? [TextSpan(text: text, style: normalStyle)] : spans;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.search, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'bible.title'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search input box
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'bible.search_verses'.tr(),
                        isDense: true,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _controller.clear();
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _performSearch,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content Area
              Expanded(
                child: _buildContent(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.manage_search_rounded,
                size: 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'bible.search_prompt'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'bible.no_verses_found'.tr(args: [_searchedQuery]),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final normalStyle = theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ) ??
        const TextStyle();

    final highlightStyle = normalStyle.copyWith(
      backgroundColor: const Color(0xFFFFD54F),
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result count badge
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'bible.verses_found'.tr(args: ['${_results.length}']),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 8),

        // List of Verse Results
        Expanded(
          child: ListView.separated(
            itemCount: _results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final verse = _results[index];

              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BibleSingleChapterScreen(
                          book: verse.book,
                          initialChapter: verse.chapter,
                          targetVerse: verse.verse,
                          highlightKeyword: _searchedQuery,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: verse.category == 'OT'
                                    ? theme.colorScheme.secondaryContainer
                                    : theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                verse.category == 'OT'
                                    ? 'bible.ot_short'.tr()
                                    : 'bible.nt_short'.tr(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: verse.category == 'OT'
                                      ? theme.colorScheme.onSecondaryContainer
                                      : theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${verse.book} ${verse.chapter}:${verse.verse}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            children: _buildHighlightedSpans(
                              verse.textContent.trim(),
                              _searchedQuery,
                              normalStyle,
                              highlightStyle,
                            ),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
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
  }
}
