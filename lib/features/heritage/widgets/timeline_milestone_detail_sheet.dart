import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/inline_formatting_helper.dart';
import '../models/timeline_milestone_model.dart';

/// Modal bottom sheet displaying detailed narrative, historical analysis, and citations.
class TimelineMilestoneDetailSheet extends StatelessWidget {
  final TimelineMilestone milestone;
  final TimelineEra? era;

  const TimelineMilestoneDetailSheet({
    super.key,
    required this.milestone,
    this.era,
  });

  static Future<void> show(
    BuildContext context, {
    required TimelineMilestone milestone,
    TimelineEra? era,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimelineMilestoneDetailSheet(
        milestone: milestone,
        era: era,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = milestone.accentColor;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191A19) : const Color(0xFFFAF8F5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: accent.withValues(alpha: 0.6),
            width: 2.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: mediaQuery.viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        era != null ? 'ERA ${era!.roman}' : 'NIAS TIMELINE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        milestone.dateDisplay,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF996515),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Scrollable narrative content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Era Period Context
                      if (era != null && era!.title.isNotEmpty) ...[
                        Text(
                          era!.title.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Milestone Title
                      Text.rich(
                        TextSpan(
                          children: parseInlineFormattingSpans(
                            milestone.title,
                            baseStyle: GoogleFonts.newsreader(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Description paragraphs
                      ..._buildDescriptionParagraphs(context, milestone.fullDescription),

                      // Citations section
                      if (milestone.citations.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.source_outlined,
                                    size: 16,
                                    color: theme.colorScheme.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Historical Sources & References',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...milestone.citations.map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      '• Reference $c in Nias Historical Archives',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDescriptionParagraphs(BuildContext context, String text) {
    final theme = Theme.of(context);
    final paragraphs = text.split('\n\n');

    return paragraphs.map((p) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) return const SizedBox.shrink();

      // Check for special callouts like "Mythological Connection:" or "The Replacement Mystery:"
      final isCallout = trimmed.startsWith('Mythological Connection:') ||
          trimmed.startsWith('Hubungan Mitologis:') ||
          trimmed.startsWith('The Replacement Mystery:') ||
          trimmed.startsWith('Misteri Pergantian Populasi:') ||
          trimmed.startsWith('The Birth of Earthly Settlements:') ||
          trimmed.startsWith('Lahirnya Pemukiman Pertama:') ||
          trimmed.startsWith('A Young Stone Tradition:') ||
          trimmed.startsWith('The Transition of Carving:') ||
          trimmed.startsWith('Transisi Seni Ukir:');

      if (isCallout) {
        final colonIndex = trimmed.indexOf(':');
        final title = trimmed.substring(0, colonIndex + 1);
        final body = trimmed.substring(colonIndex + 1).trim();

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: milestone.accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(
                color: milestone.accentColor,
                width: 3.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: milestone.accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: parseInlineFormattingSpans(
                    body,
                    baseStyle: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Text.rich(
          TextSpan(
            children: parseInlineFormattingSpans(
              trimmed,
              baseStyle: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                height: 1.5,
                fontSize: 14.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
