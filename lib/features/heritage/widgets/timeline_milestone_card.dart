import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/inline_formatting_helper.dart';
import '../models/timeline_milestone_model.dart';

/// Milestone card rendered along the winding timeline path.
///
/// Displays the full description (or summary if full description is unavailable)
/// within a constrained, scrollable container so that extra-long text never overflows
/// on phones, tablets, or desktop viewports.
class TimelineMilestoneCard extends StatefulWidget {
  final TimelineMilestone milestone;
  final String eraRoman;
  final bool isFocused;
  final VoidCallback onTap;
  final bool? showFullDescription;
  final double? maxDescriptionHeight;

  const TimelineMilestoneCard({
    super.key,
    required this.milestone,
    required this.eraRoman,
    required this.isFocused,
    required this.onTap,
    this.showFullDescription,
    this.maxDescriptionHeight,
  });

  @override
  State<TimelineMilestoneCard> createState() => _TimelineMilestoneCardState();
}

class _TimelineMilestoneCardState extends State<TimelineMilestoneCard> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant TimelineMilestoneCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.milestone.id != widget.milestone.id) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _resolveMaxDescriptionHeight(BuildContext context, bool isTabletOrDesktop) {
    if (widget.maxDescriptionHeight != null) {
      return widget.maxDescriptionHeight!;
    }
    final size = MediaQuery.sizeOf(context);
    final screenWidth = size.width;
    final screenHeight = size.height;
    if (screenHeight < 500) {
      // Landscape mobile phone: compact description height so the card fits on screen
      return 75.0;
    }
    if (screenWidth >= 1024) {
      return 260.0;
    } else if (screenWidth >= 600) {
      return 220.0;
    } else {
      return 130.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = widget.milestone.accentColor;
    final size = MediaQuery.sizeOf(context);
    final isLandscapeMobile = size.height < 500;
    final isTabletOrDesktop = size.width >= 600 && size.height >= 500;
    final useFullDesc = widget.showFullDescription ?? true;
    final hasFullDesc = widget.milestone.fullDescription.trim().isNotEmpty;
    final textToDisplay = (useFullDesc && hasFullDesc)
        ? widget.milestone.fullDescription
        : widget.milestone.summary;

    final maxDescHeight = _resolveMaxDescriptionHeight(context, isTabletOrDesktop);

    return Semantics(
      label: '${widget.milestone.dateDisplay}, ${widget.milestone.title}',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: accent.withValues(alpha: 0.15),
          highlightColor: accent.withValues(alpha: 0.08),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? (widget.isFocused
                      ? const Color(0xFF1E1F1E)
                      : const Color(0xFF171717))
                  : (widget.isFocused
                      ? Colors.white
                      : const Color(0xFFF9F7F4)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isFocused
                    ? accent.withValues(alpha: 0.8)
                    : accent.withValues(alpha: 0.25),
                width: widget.isFocused ? 2.0 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isFocused
                      ? accent.withValues(alpha: isDark ? 0.35 : 0.2)
                      : Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: widget.isFocused ? 18.0 : 8.0,
                  offset: widget.isFocused ? const Offset(0, 6) : const Offset(0, 3),
                  spreadRadius: widget.isFocused ? 1.0 : 0,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isTabletOrDesktop ? 22 : (isLandscapeMobile ? 16 : 18),
              vertical: isTabletOrDesktop ? 18 : (isLandscapeMobile ? 8 : 14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top badge row: Era tag, Date display, and Detail indicator
                Row(
                  children: [
                    // Era indicator pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ERA ${widget.eraRoman}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Date display badge
                    Flexible(
                      child: Text(
                        widget.milestone.dateDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF996515),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Detail arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: accent.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                SizedBox(height: isLandscapeMobile ? 5 : 10),

                // Milestone Headline
                Builder(
                  builder: (context) {
                    final titleStyle = GoogleFonts.newsreader(
                      fontSize: isLandscapeMobile
                          ? 14.5
                          : (widget.isFocused ? 17.5 : 16.0),
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      color: theme.colorScheme.onSurface,
                    );
                    return Text.rich(
                      TextSpan(
                        children: parseInlineFormattingSpans(
                          widget.milestone.title,
                          baseStyle: titleStyle,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                SizedBox(height: isLandscapeMobile ? 5 : 8),

                // Scrollable Narrative Description
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: maxDescHeight,
                  ),
                  child: Theme(
                    data: theme.copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(accent.withValues(alpha: 0.5)),
                        trackColor: WidgetStateProperty.all(accent.withValues(alpha: 0.08)),
                        radius: const Radius.circular(4),
                        thickness: WidgetStateProperty.all(3.0),
                      ),
                    ),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(right: 6),
                        child: Text.rich(
                          TextSpan(
                            children: parseInlineFormattingSpans(
                              textToDisplay,
                              baseStyle: (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: isTabletOrDesktop ? 13.5 : (isLandscapeMobile ? 11.5 : 12.5),
                                height: isTabletOrDesktop ? 1.5 : (isLandscapeMobile ? 1.35 : 1.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Citation count footnote indicator (if citations present)
                if (widget.milestone.citations.isNotEmpty) ...[
                  SizedBox(height: isLandscapeMobile ? 4 : 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${widget.milestone.citations.length} citation${widget.milestone.citations.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
