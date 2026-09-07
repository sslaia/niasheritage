import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/heritage_section_model.dart';

class FloatingTocPill extends StatefulWidget {
  final List<HeritageArticleSection> sections;
  final Color accentColor;
  final ScrollController? scrollController;

  const FloatingTocPill({
    super.key,
    required this.sections,
    required this.accentColor,
    this.scrollController,
  });

  @override
  State<FloatingTocPill> createState() => _FloatingTocPillState();
}

class _FloatingTocPillState extends State<FloatingTocPill> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isVisible = true;
  HeritageArticleSection? _activeSection;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (widget.scrollController == null) return;
    final controller = widget.scrollController!;

    // Hide pill on active downward scroll, show on upward scroll
    if (controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isVisible && !_isExpanded) {
        setState(() => _isVisible = false);
      }
    } else if (controller.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
      }
    }
  }

  void _scrollToSection(HeritageArticleSection section) {
    setState(() {
      _isExpanded = false;
      _activeSection = section;
    });

    final targetContext = section.key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
        alignment: 0.08, // Leaves space below the pinned SliverAppBar
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sections.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final maxWidth = mediaQuery.size.width;
    final popoverWidth = (maxWidth - 40).clamp(280.0, 360.0);

    return Positioned(
      bottom: 24,
      right: 18,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          // Dismiss tap barrier when expanded
          if (_isExpanded)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _isExpanded = false),
              ),
            ),

          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expanded Popover Menu Card
              if (_isExpanded) ...[
                Material(
                  color: Colors.transparent,
                  child: Container(
                    width: popoverWidth,
                    constraints: BoxConstraints(
                      maxHeight: mediaQuery.size.height * 0.55,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E).withValues(alpha: 0.92)
                          : Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: widget.accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.format_list_bulleted_rounded,
                                      size: 18,
                                      color: widget.accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'heritage.toc'.tr(),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 20),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => setState(() => _isExpanded = false),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),

                            // Section List
                            Flexible(
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                shrinkWrap: true,
                                itemCount: widget.sections.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 2),
                                itemBuilder: (context, index) {
                                  final sec = widget.sections[index];
                                  final isSub = sec.level > 2;
                                  final isSelected = _activeSection?.id == sec.id;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => _scrollToSection(sec),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: isSub ? 7 : 9,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? widget.accentColor.withValues(alpha: 0.15)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (isSub) ...[
                                            const SizedBox(width: 14),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Icon(
                                                Icons.subdirectory_arrow_right_rounded,
                                                size: 14,
                                                color: widget.accentColor.withValues(alpha: 0.8),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                          ] else ...[
                                            Padding(
                                              padding: const EdgeInsets.only(top: 3),
                                              child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: widget.accentColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Expanded(
                                            child: Text(
                                              sec.title,
                                              style: TextStyle(
                                                fontSize: isSub ? 12.5 : 13.5,
                                                fontWeight: isSub ? FontWeight.normal : FontWeight.w600,
                                                color: isSelected
                                                    ? widget.accentColor
                                                    : theme.colorScheme.onSurface,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // Floating Pill Button
              AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                offset: _isVisible || _isExpanded ? Offset.zero : const Offset(0, 1.8),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isVisible || _isExpanded ? 1.0 : 0.0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => setState(() => _isExpanded = !_isExpanded),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.accentColor.withValues(alpha: _isExpanded ? 0.95 : 0.88),
                                  widget.accentColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 250),
                                  turns: _isExpanded ? 0.25 : 0.0,
                                  child: Icon(
                                    _isExpanded ? Icons.close_rounded : Icons.toc_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isExpanded ? 'common.close'.tr() : 'heritage.toc'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (!_isExpanded) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      widget.sections.length.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
