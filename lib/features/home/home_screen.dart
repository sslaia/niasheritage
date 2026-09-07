import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const accentColor = Color(0xFF996515); // Nias Warm Gold / Ochre

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Banner Header
          SliverAppBar(
            expandedHeight: 280.0,
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
                'app_title'.tr(),
                style: AppTheme.sliverAppBarTitleStyle(),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/home.webp',
                    cacheWidth: 1080,
                    fit: BoxFit.cover,
                  ),
                  // Dark gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Top badge overlay
                  Positioned(
                    top: 48,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.museum_rounded,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "NIAS HERITAGE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Welcome Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.handshake_outlined,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'home.greeting'.tr(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'home.welcome'.tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Purpose Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.surfaceContainerHigh,
                          theme.colorScheme.surfaceContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'home.purpose_title'.tr(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'home.purpose_desc'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Heritage & Culture Card (clickable -> navigates to Heritage screen)
                  _buildNavCard(
                    theme: theme,
                    icon: Icons.museum_rounded,
                    title: 'home.heritage_title'.tr(),
                    subtitle: 'home.heritage_subtitle'.tr(),
                    // sections: 'home.heritage_sections'.tr(),
                    onTap: () {
                      ref.read(activeTabProvider.notifier).state = 1;
                    },
                  ),

                  const SizedBox(height: 16),

                  // 3. Library & Literature Card (clickable -> navigates to Library screen)
                  _buildNavCard(
                    theme: theme,
                    icon: Icons.collections_bookmark_rounded,
                    title: 'home.library_title'.tr(),
                    subtitle: 'home.library_subtitle'.tr(),
                    // sections: 'home.library_sections'.tr(),
                    onTap: () {
                      ref.read(activeTabProvider.notifier).state = 2;
                    },
                  ),

                  const SizedBox(height: 16),

                  // 4. Entertainment & Communication Card (clickable -> navigates to Interactive screen)
                  _buildNavCard(
                    theme: theme,
                    icon: Icons.interests_rounded,
                    title: 'home.interactive_title'.tr(),
                    subtitle: 'home.interactive_subtitle'.tr(),
                    // sections: 'home.interactive_sections'.tr(),
                    onTap: () {
                      ref.read(activeTabProvider.notifier).state = 3;
                    },
                  ),

                  // Nias Ornament Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Image.asset(
                        'assets/images/ni\'owewemagai.webp',
                        cacheHeight: 120,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Footer Attribution / Disclaimer / Privacy Policy
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Attribution with clickable Wikimedia Commons link
                        _buildAttributionText(context, theme),
                        const SizedBox(height: 8),

                        // In-App Browser Links to Disclaimer & Privacy Policy
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12.0,
                          runSpacing: 8.0,
                          children: [
                            TextButton(
                              onPressed: () => _launchInAppBrowser(
                                'https://sslaia.github.io/niasheritage/disclaimer.html',
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'footer.disclaimer'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              '•',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _launchInAppBrowser(
                                'https://sslaia.github.io/niasheritage/privacy-policy.html',
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'footer.privacy_policy'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    // required String sections,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  // Text(
                  //   sections,
                  //   style: theme.textTheme.bodySmall?.copyWith(
                  //     color: theme.colorScheme.onSurface,
                  //     fontWeight: FontWeight.bold,
                  //     fontSize: 12,
                  //     letterSpacing: 0.3,
                  //     height: 1.4,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchInAppBrowser(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {}
  }

  Widget _buildAttributionText(BuildContext context, ThemeData theme) {
    final fullText = 'footer.attribution'.tr();
    const linkWord = 'Wikimedia Commons';
    final parts = fullText.split(linkWord);

    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 11,
      color: theme.colorScheme.outline,
      height: 1.4,
    );

    final linkStyle = baseStyle?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );

    if (parts.length == 2) {
      return Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: parts[0]),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showImagesAttributionSheet(context),
                  child: Text(linkWord, style: linkStyle),
                ),
              ),
            ),
            TextSpan(text: parts[1]),
          ],
        ),
        textAlign: TextAlign.center,
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showImagesAttributionSheet(context),
        child: Text(
          fullText,
          style: linkStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showImagesAttributionSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Hero Images (Wikimedia Commons)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: 'common.close'.tr(),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: DefaultAssetBundle.of(context).loadString('assets/images/images.md'),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Unable to load images list.',
                                style: TextStyle(color: theme.colorScheme.error),
                              ),
                            ),
                          );
                        }
                        return Markdown(
                          controller: scrollController,
                          data: snapshot.data!,
                          selectable: true,
                          onTapLink: (text, href, title) {
                            if (href != null && href.startsWith('http')) {
                              _launchInAppBrowser(href);
                            }
                          },
                          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                            a: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                            h1: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            h2: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            p: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
