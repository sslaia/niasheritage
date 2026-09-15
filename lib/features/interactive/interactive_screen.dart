import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/footer_attribution.dart';
import 'nias_course_screen.dart';
import 'nias_newsletter_screen.dart';
import 'nias_crossword_screen.dart';
import 'nias_gallery_screen.dart';

class InteractiveScreen extends StatelessWidget {
  const InteractiveScreen({super.key});

  static const accentColor = Color(0xFF0891B2); // Teal Cyan

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Banner
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 16,
                bottom: 16,
                right: 16,
              ),
              title: Text(
                'interactive.hero_title'.tr(),
                style: AppTheme.sliverAppBarTitleStyle(),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/interactive.webp',
                    cacheWidth: 1080,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Dark gradient overlay for text readability
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hero Subtitle description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'interactive.hero_subtitle'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // Content Sections List
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Crosswords & Gamification Section
                _buildSectionCard(
                  context: context,
                  title: 'interactive.crosswords_title'.tr(),
                  badge: 'interactive.crosswords_badge'.tr(),
                  description: 'interactive.crosswords_desc'.tr(),
                  actionLabel: 'interactive.crosswords_action'.tr(),
                  icon: Icons.extension_rounded,
                  accentColor: const Color(0xFF10B981), // Emerald green
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NiasCrosswordScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Community Newsletter Section
                _buildSectionCard(
                  context: context,
                  title: 'interactive.newsletter_title'.tr(),
                  badge: 'interactive.newsletter_badge'.tr(),
                  description: 'interactive.newsletter_desc'.tr(),
                  actionLabel: 'interactive.newsletter_action'.tr(),
                  icon: Icons.newspaper_rounded,
                  accentColor: const Color(0xFF0891B2), // Cyan
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NiasNewsletterScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Language Course Section
                _buildSectionCard(
                  context: context,
                  title: 'interactive.course_title'.tr(),
                  badge: 'interactive.course_badge'.tr(),
                  description: 'interactive.course_desc'.tr(),
                  actionLabel: 'interactive.course_action'.tr(),
                  icon: Icons.school_rounded,
                  accentColor: const Color(0xFFD97706), // Amber
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NiasCourseScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Media Gallery Section
                _buildSectionCard(
                  context: context,
                  title: 'interactive.gallery_title'.tr(),
                  badge: 'interactive.gallery_badge'.tr(),
                  description: 'interactive.gallery_desc'.tr(),
                  actionLabel: 'interactive.gallery_action'.tr(),
                  icon: Icons.photo_library_rounded,
                  accentColor: const Color(0xFFF59E0B), // Warm Gold
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NiasGalleryScreen(),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(
            child: FooterAttribution(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String badge,
    required String description,
    required String? actionLabel,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Icon, Badge, and Trailing Arrow
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: accentColor, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isComingSoon
                        ? Icons.lock_outline_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              if (actionLabel != null) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: onTap,
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text(actionLabel),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
