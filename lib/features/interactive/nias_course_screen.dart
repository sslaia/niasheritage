import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wiki_course_reader/wiki_course_reader.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bar_circle_action.dart';

class NiasCourseScreen extends StatelessWidget {
  const NiasCourseScreen({super.key});

  static const accentColor = Color(0xFFD97706); // Warm Amber

  @override
  Widget build(BuildContext context) {
    const config = CourseConfig(
      langCode: 'nia',
      project: 'wiktionary',
      pageTitle: 'Wikikamus:Sulu',
      userAgent: 'NiasHeritage/1.0 (https://github.com/sslaia/niasheritage)',
    );

    return Theme(
      data: appBarCircleBackTheme(context),
      child: CourseReaderScreen(
        config: config,
        title: 'interactive.course_title'.tr(),
        subtitle: 'Wikikamus:Sulu (nia.wiktionary.org)',
        primaryColor: accentColor,
        accentColor: accentColor,
        titleTextStyle: AppTheme.sliverAppBarTitleStyle(),
        fallbackHeroIcon: Icons.school_rounded,
      ),
    );
  }
}
