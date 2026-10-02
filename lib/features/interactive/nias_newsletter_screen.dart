import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wiki_newsletter_reader/wiki_newsletter_reader.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bar_circle_action.dart';

class NiasNewsletterScreen extends StatelessWidget {
  const NiasNewsletterScreen({super.key});

  static const accentColor = Color(0xFF0891B2); // Cyan

  @override
  Widget build(BuildContext context) {
    const config = NewsletterConfig(
      langCode: 'nia',
      project: 'wikipedia',
      pageTitle: 'Wikipedia:Turia',
      userAgent: 'NiasHeritage/1.0 (https://github.com/sslaia/niasheritage)',
    );

    return Theme(
      data: appBarCircleBackTheme(context),
      child: NewsletterReaderScreen(
        config: config,
        title: 'interactive.newsletter_title'.tr(),
        subtitle: 'Wikipedia:Turia (nia.wikipedia.org)',
        primaryColor: accentColor,
        accentColor: accentColor,
        titleTextStyle: AppTheme.sliverAppBarTitleStyle(),
        h2Style: AppTheme.subheadingStyle(color: accentColor),
        h3Style: AppTheme.subSubheadingStyle(color: accentColor),
        tocLabel: 'heritage.toc'.tr(),
        closeLabel: 'common.close'.tr(),
        refreshLabel: 'common.refresh'.tr(),
        shareLabel: 'common.share'.tr(),
        refreshingLabel: 'interactive.newsletter_refreshing'.tr(),
        retryLabel: 'common.retry'.tr(),
        fallbackHeroIcon: Icons.newspaper_rounded,
      ),
    );
  }
}

