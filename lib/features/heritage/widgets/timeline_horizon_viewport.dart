import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/timeline_milestone_model.dart';
import 'timeline_track_painter.dart';
import 'timeline_milestone_card.dart';
import 'timeline_milestone_detail_sheet.dart';

/// Interactive viewport featuring 3D horizon scaling, snake track curve, and native gesture handling.
class TimelineHorizonViewport extends StatefulWidget {
  final List<TimelineMilestone> milestones;
  final List<TimelineEra> eras;
  final ScrollController scrollController;
  final ValueChanged<int> onActiveIndexChanged;
  final ValueChanged<int> onActiveEraChanged;

  const TimelineHorizonViewport({
    super.key,
    required this.milestones,
    required this.eras,
    required this.scrollController,
    required this.onActiveIndexChanged,
    required this.onActiveEraChanged,
  });

  /// Responsive item spacing along the timeline scroll track.
  static double calculateItemSpacing(double screenWidth, [double screenHeight = 800.0]) {
    if (screenHeight < 500) {
      return 220.0;
    } else if (screenWidth >= 1024) {
      return 480.0;
    } else if (screenWidth >= 600) {
      return 440.0;
    } else {
      return 280.0;
    }
  }

  /// Responsive card width for milestone cards.
  static double calculateCardWidth(double screenWidth, [double screenHeight = 800.0]) {
    if (screenHeight < 500) {
      return math.min(screenWidth * 0.72, 520.0);
    } else if (screenWidth >= 1024) {
      return math.min(screenWidth * 0.70, 720.0);
    } else if (screenWidth >= 600) {
      return math.min(screenWidth * 0.85, 620.0);
    } else {
      return math.min(screenWidth * 0.86, 380.0);
    }
  }

  @override
  State<TimelineHorizonViewport> createState() => _TimelineHorizonViewportState();
}

class _TimelineHorizonViewportState extends State<TimelineHorizonViewport> {
  int _lastNotifiedIndex = -1;
  int _lastNotifiedEra = -1;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScrollTick);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScrollTick);
    super.dispose();
  }

  void _handleScrollTick() {
    if (!mounted || widget.milestones.isEmpty) return;
    final size = MediaQuery.sizeOf(context);
    final itemSpacing = TimelineHorizonViewport.calculateItemSpacing(
      size.width,
      size.height,
    );
    final offset = widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;
    final closestIndex = (offset / itemSpacing).round().clamp(0, widget.milestones.length - 1);

    if (closestIndex != _lastNotifiedIndex) {
      _lastNotifiedIndex = closestIndex;
      widget.onActiveIndexChanged(closestIndex);

      final milestone = widget.milestones[closestIndex];
      if (milestone.eraIndex != _lastNotifiedEra) {
        _lastNotifiedEra = milestone.eraIndex;
        widget.onActiveEraChanged(milestone.eraIndex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isLandscapeMobile = screenHeight < 500;
        final isTabletOrDesktop = screenWidth >= 600 && screenHeight >= 500;
        final itemSpacing = TimelineHorizonViewport.calculateItemSpacing(screenWidth, screenHeight);
        final cardWidth = TimelineHorizonViewport.calculateCardWidth(screenWidth, screenHeight);
        final focusY = isLandscapeMobile ? 16.0 : screenHeight * 0.44;
        final horizonY = isLandscapeMobile ? 6.0 : 55.0;

        final amplitude = isLandscapeMobile
            ? 32.0
            : (screenWidth < 500 ? 26.0 : (isTabletOrDesktop ? 68.0 : 54.0));

        return Stack(
          children: [
            // 1. Background snake track custom painter
            Positioned.fill(
              child: AnimatedBuilder(
                animation: widget.scrollController,
                builder: (context, _) {
                  final offset = widget.scrollController.hasClients
                      ? widget.scrollController.offset
                      : 0.0;

                  final activeMilestone = widget.milestones.isNotEmpty
                      ? widget.milestones[(_lastNotifiedIndex).clamp(0, widget.milestones.length - 1)]
                      : null;
                  final accentColor = activeMilestone?.accentColor ?? const Color(0xFFD4AF37);

                  return CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: TimelineTrackPainter(
                      scrollOffset: offset,
                      itemSpacing: itemSpacing,
                      totalCount: widget.milestones.length,
                      amplitude: amplitude,
                      baseColor: theme.colorScheme.outline,
                      accentColor: accentColor,
                      isDark: isDark,
                      focusY: focusY,
                      horizonY: horizonY,
                    ),
                  );
                },
              ),
            ),

            // 2. Horizon atmosphere glow gradient at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (isDark ? const Color(0xFF131313) : const Color(0xFFFAF8F5))
                            .withValues(alpha: 0.95),
                        (isDark ? const Color(0xFF131313) : const Color(0xFFFAF8F5))
                            .withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. Fluid, interactive ListView hosting milestone cards with 3D horizon scaling
            Positioned.fill(
              child: AnimatedBuilder(
                animation: widget.scrollController,
                builder: (context, _) {
                  final offset = widget.scrollController.hasClients
                      ? widget.scrollController.offset
                      : 0.0;

                  return ListView.builder(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: focusY,
                      bottom: math.max(60.0, screenHeight - focusY - itemSpacing + 80.0),
                    ),
                    itemCount: widget.milestones.length,
                    itemExtent: itemSpacing,
                    itemBuilder: (context, index) {
                      final isLastItem = index == widget.milestones.length - 1;
                      final milestone = widget.milestones[index];
                      final itemNaturalY = index * itemSpacing;
                      final diff = itemNaturalY - offset;

                      double dy = 0.0;
                      double scale = 1.0;
                      double opacity = 1.0;

                      if (diff < 0) {
                        if (isLastItem) {
                          // The final milestone stays pinned at the focal center,
                          // remaining visible and prominent even if users scroll further down.
                          scale = 1.0;
                          opacity = 1.0;
                          final visualY = focusY;
                          final nominalY = focusY + diff;
                          dy = visualY - nominalY;
                        } else {
                          // Receding towards horizon
                          final factor = (-diff / (isLandscapeMobile ? 240.0 : (isTabletOrDesktop ? 480.0 : 380.0))).clamp(0.0, 1.0);
                          scale = (1.0 - 0.75 * factor).clamp(0.25, 1.0);
                          opacity = math.pow(1.0 - factor, 1.5).toDouble().clamp(0.0, 1.0);

                          final visualY = focusY - (focusY - horizonY) * (1.0 - math.exp(-2.5 * factor));
                          final nominalY = focusY + diff;
                          dy = visualY - nominalY;
                        }
                      } else {
                        // Emerging from below
                        final factor = (diff / (isLandscapeMobile ? 300.0 : (isTabletOrDesktop ? 550.0 : 450.0))).clamp(0.0, 1.0);
                        scale = (1.0 - 0.35 * factor).clamp(0.65, 1.0);
                        opacity = (1.0 - 0.7 * factor).clamp(0.0, 1.0);
                        dy = 0.0;
                      }

                      final waveVal = itemNaturalY / itemSpacing;
                      final dx = math.sin(waveVal * math.pi) * amplitude;
                      final isFocused = diff.abs() < (isTabletOrDesktop ? 100 : (isLandscapeMobile ? 50 : 70)) || (isLastItem && diff < 0);

                      final era = widget.eras.firstWhere(
                        (e) => e.id == milestone.eraId,
                        orElse: () => widget.eras.isNotEmpty
                            ? widget.eras[0]
                            : const TimelineEra(
                                id: '',
                                roman: 'I',
                                index: 0,
                                title: '',
                                period: '',
                                accentColor: Color(0xFFD4AF37),
                              ),
                      );

                      return Align(
                        alignment: isLandscapeMobile ? Alignment.topCenter : Alignment.center,
                        child: Transform.translate(
                          offset: Offset(dx, dy),
                          child: Transform.scale(
                            scale: scale,
                            alignment: isLandscapeMobile ? Alignment.topCenter : Alignment.center,
                            child: Opacity(
                              opacity: opacity,
                              child: SizedBox(
                                width: cardWidth,
                                child: RepaintBoundary(
                                  child: TimelineMilestoneCard(
                                    milestone: milestone,
                                    eraRoman: era.roman,
                                    isFocused: isFocused,
                                    showFullDescription: true,
                                    onTap: () {
                                      TimelineMilestoneDetailSheet.show(
                                        context,
                                        milestone: milestone,
                                        era: era,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
