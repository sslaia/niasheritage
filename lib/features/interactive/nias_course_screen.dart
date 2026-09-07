import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wiki_course_reader/wiki_course_reader.dart';
import '../../core/theme/app_theme.dart';

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

    return CourseReaderScreen(
      config: config,
      title: 'interactive.course_title'.tr(),
      subtitle: 'Wikikamus:Sulu (nia.wiktionary.org)',
      primaryColor: accentColor,
      accentColor: accentColor,
      titleTextStyle: AppTheme.sliverAppBarTitleStyle(),
      fallbackHeroIcon: Icons.school_rounded,
    );
  }
}
