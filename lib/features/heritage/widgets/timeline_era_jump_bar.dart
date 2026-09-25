import 'package:flutter/material.dart';
import '../models/timeline_milestone_model.dart';

/// Horizontal jump bar allowing fast navigation between the 7 Nias historical eras.
class TimelineEraJumpBar extends StatelessWidget {
  final List<TimelineEra> eras;
  final int activeEraIndex;
  final ValueChanged<int> onEraSelected;

  const TimelineEraJumpBar({
    super.key,
    required this.eras,
    required this.activeEraIndex,
    required this.onEraSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF131313) : const Color(0xFFFAF8F5))
            .withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            for (int index = 0; index < eras.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  final era = eras[index];
                  final isSelected = era.index == activeEraIndex;
                  final accent = era.accentColor;

                  return InkWell(
                    onTap: () => onEraSelected(index),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accent.withValues(alpha: isDark ? 0.3 : 0.15)
                            : (isDark
                                ? const Color(0xFF1F201F)
                                : const Color(0xFFEDE8E1)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? accent
                              : theme.colorScheme.outline.withValues(alpha: 0.2),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isSelected ? accent : theme.colorScheme.outline,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Era ${era.roman}: ${era.title}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? accent
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
