import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bar_circle_action.dart';
import 'models/timeline_milestone_model.dart';
import 'providers/timeline_providers.dart';
import 'services/timeline_repository.dart';
import 'widgets/timeline_era_jump_bar.dart';
import 'widgets/timeline_horizon_viewport.dart';

/// Animated Heritage's History Timeline screen.
///
/// Features a smooth, winding snake-like track with 3D horizon scaling:
/// active nodes expand into full prominence at the viewport focal center,
/// while past milestones shrink and fade upwards into the distant horizon.
class HeritageTimelineScreen extends ConsumerStatefulWidget {
  const HeritageTimelineScreen({super.key});

  @override
  ConsumerState<HeritageTimelineScreen> createState() =>
      _HeritageTimelineScreenState();
}

class _HeritageTimelineScreenState
    extends ConsumerState<HeritageTimelineScreen> {
  late final ScrollController _scrollController;
  int _activeMilestoneIndex = 0;
  int _activeEraIndex = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshTimeline(String languageCode) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final updated = await TimelineRepository.syncFromWiki(
        languageCode: languageCode,
      );
      if (mounted) {
        if (updated != null) {
          ref.invalidate(timelineDataProvider(languageCode));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('heritage.timeline_sync_success'.tr()),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('heritage.timeline_sync_no_changes'.tr()),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _scrollToEra(int eraIndex, List<TimelineMilestone> milestones) {
    final targetMilestoneIndex = milestones.indexWhere(
      (m) => m.eraIndex == eraIndex,
    );
    if (targetMilestoneIndex != -1) {
      final size = MediaQuery.sizeOf(context);
      final itemSpacing = TimelineHorizonViewport.calculateItemSpacing(
        size.width,
        size.height,
      );
      final targetOffset = targetMilestoneIndex * itemSpacing;
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToBeginning() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final languageCode = context.locale.languageCode;
    final timelineAsync = ref.watch(timelineDataProvider(languageCode));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor:
            (isDark ? AppTheme.darkBackground : AppTheme.lightBackground)
                .withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: false,
        leading: const AppBarCircleBackButton(),
        title: Text(
          'heritage.timeline_title'.tr(),
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Refresh from Wikipedia action
          AppBarCircleAction(
            child: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    tooltip: 'heritage.refresh_tooltip'.tr(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _refreshTimeline(languageCode),
                  ),
          ),
          const SizedBox(width: 8),

          // Jump to beginning button
          if (_activeMilestoneIndex > 2)
            IconButton(
              icon: const Icon(Icons.vertical_align_top_rounded),
              tooltip: 'heritage.timeline_top'.tr(),
              onPressed: _scrollToBeginning,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: timelineAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  'heritage.timeline_load_error'.tr(args: [err.toString()]),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.refresh(timelineDataProvider(languageCode)),
                  child: Text('common.retry'.tr()),
                ),
              ],
            ),
          ),
        ),
        data: (timelineData) {
          final milestones = timelineData.milestones;
          final eras = timelineData.eras;

          if (milestones.isEmpty) {
            return Center(
              child: Text('heritage.timeline_empty'.tr()),
            );
          }

          final activeMilestone =
              milestones[_activeMilestoneIndex.clamp(0, milestones.length - 1)];

          return Column(
            children: [
              // Sticky Era Navigation Jump Bar
              TimelineEraJumpBar(
                eras: eras,
                activeEraIndex: _activeEraIndex,
                onEraSelected: (eraIdx) => _scrollToEra(eraIdx, milestones),
              ),

              // Interactive 3D Horizon Viewport
              Expanded(
                child: Stack(
                  children: [
                    TimelineHorizonViewport(
                      milestones: milestones,
                      eras: eras,
                      scrollController: _scrollController,
                      onActiveIndexChanged: (idx) {
                        setState(() => _activeMilestoneIndex = idx);
                      },
                      onActiveEraChanged: (eraIdx) {
                        setState(() => _activeEraIndex = eraIdx);
                      },
                    ),

                    // Floating bottom status pill: shows milestone index & active era
                    Positioned(
                      bottom: MediaQuery.sizeOf(context).height < 500 ? 8 : 18,
                      right: MediaQuery.sizeOf(context).height < 500 ? 10 : 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDark ? const Color(0xFF1E201E) : Colors.white)
                                  .withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: activeMilestone.accentColor.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.3 : 0.08,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timeline_rounded,
                              size: 14,
                              color: activeMilestone.accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_activeMilestoneIndex + 1} / ${milestones.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
