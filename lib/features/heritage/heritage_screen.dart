import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/footer_attribution.dart';
import '../../core/widgets/app_bar_circle_action.dart';
import 'introduction_screen.dart';
import 'heritage_detail_screen.dart';
import 'models/heritage_section_model.dart';

class HeritageScreen extends ConsumerWidget {
  const HeritageScreen({super.key});

  static const accentColor = Color(0xFFB45309); // Amber / Terracotta

  List<Map<String, dynamic>> _getHeritageTopics(BuildContext context) {
    return [
      {
        'key': 'introduction',
        'title': 'heritage.introduction_title'.tr(),
        'desc': 'heritage.introduction_desc'.tr(),
        'badge': 'heritage_badges.introduction'.tr(),
        'icon': Icons.auto_stories_rounded,
        'color': const Color(0xFF1E40AF), // Royal Blue
        'screen': const IntroductionScreen(),
      },
      ...HeritageSection.values.map(
        (section) => {
          'key': section.category,
          'title': section.titleKey.tr(),
          'desc': section.descKey.tr(),
          'badge': section.badgeKey.tr(),
          'icon': section.icon,
          'color': section.accentColor,
          'screen': HeritageDetailScreen.section(section),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final topics = _getHeritageTopics(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Banner
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            leading: const AppBarCircleBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'heritage.title'.tr(),
                style: AppTheme.sliverAppBarTitleStyle(),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/heritage.webp',
                    cacheWidth: 1080,
                    fit: BoxFit.cover,
                  ),
                  // Gradient Overlay for readability
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 48,
                    left: 16,
                    right: 16,
                    child: Text(
                      'heritage.subtitle'.tr(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7 Heritage Topics List
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final topic = topics[index];
                final color = topic['color'] as Color;
                final targetScreen = topic['screen'] as Widget;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => targetScreen),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row with Icon, Badge, and Arrow
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  topic['icon'] as IconData,
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      topic['badge'] as String,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: color,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Topic Title
                          Text(
                            topic['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Description Text
                          Text(
                            topic['desc'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: topics.length),
            ),
          ),
          const SliverToBoxAdapter(child: FooterAttribution()),
        ],
      ),
    );
  }
}
