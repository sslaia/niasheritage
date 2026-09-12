import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wiki_crosswords/wiki_crosswords.dart';
import '../../core/theme/app_theme.dart';

class NiasCrosswordScreen extends StatelessWidget {
  final CrosswordDataSource? dataSource;

  const NiasCrosswordScreen({super.key, this.dataSource});

  void _showDefinitionSheet(BuildContext context, String word, String pageTitle) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Wikikamus',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'nia.wiktionary.org',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                word,
                style: GoogleFonts.newsreader(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'interactive.crossword_wiktionary_page'.tr(args: [pageTitle]),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('common.close'.tr()),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final encoded = Uri.encodeComponent(pageTitle);
                      final url = Uri.parse('https://nia.wiktionary.org/wiki/$encoded');
                      try {
                        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text('interactive.crossword_open_wiktionary'.tr()),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final isNias = langCode == 'nia';
    final isId = langCode == 'id';

    String trOr(String key, String fallback) {
      final val = key.tr();
      return val == key ? fallback : val;
    }

    final customLabels = {
      'crossword_title': 'interactive.crosswords_title'.tr(),
      'crosswords': 'interactive.crosswords'.tr(),
      'crossword_daily': 'interactive.crossword_daily'.tr(),
      'crossword_favorites': 'interactive.crossword_favorites'.tr(),
      'crossword_scoreboard': 'interactive.crossword_scoreboard'.tr(),
      'crossword_score': 'interactive.crossword_score'.tr(),
      'crossword_score_earned': 'interactive.crossword_score_earned'.tr(),
      'crossword_weekly': 'interactive.crossword_weekly'.tr(),
      'crossword_monthly': 'interactive.crossword_monthly'.tr(),
      'crossword_yearly': 'interactive.crossword_yearly'.tr(),
      'crossword_no_favorite': 'interactive.crossword_no_favorite'.tr(),
      'crossword_open': 'interactive.crossword_open'.tr(),
      'crossword_play': 'interactive.crossword_play'.tr(),
      'crossword_share': 'interactive.crossword_share'.tr(),
      'crossword_share_1': 'interactive.crossword_share_1'.tr(),
      'crossword_share_2': 'interactive.crossword_share_2'.tr(),
      'crossword_notes': 'interactive.crossword_notes'.tr(),
      'crossword_notes_1': 'interactive.crossword_notes_1'.tr(),
      'crossword_notes_2': 'interactive.crossword_notes_2'.tr(),
      'crossword_check_words': 'interactive.crossword_check_words'.tr(),
      'crossword_hide_words': 'interactive.crossword_hide_words'.tr(),
      'crossword_bonus': 'interactive.crossword_bonus'.tr(),
      'crossword_wiktionary_ref': 'interactive.crossword_wiktionary_ref'.tr(),
      'crossword_open_wiktionary': 'interactive.crossword_open_wiktionary'.tr(),
      'crossword_no': 'interactive.crossword_no'.tr(),
      'across': trOr('interactive.crossword_across', isNias ? 'Misa' : (isId ? 'Mendatar' : 'Across')),
      'down': trOr('interactive.crossword_down', isNias ? 'Mitou' : (isId ? 'Menurun' : 'Down')),
      'words': trOr('interactive.crossword_words', isNias ? 'wehede' : (isId ? 'kata' : 'words')),
      'retry': trOr('interactive.crossword_retry', isNias ? 'Fuli lau' : (isId ? 'Coba lagi' : 'Retry')),
      'reference': trOr('interactive.crossword_reference', isNias ? 'Khai-khai' : (isId ? 'Referensi' : 'Reference')),
    };

    const primaryColor = Color(0xFFD97706); // Amber Heritage Gold
    const accentColor = Color(0xFFB45309);

    return CrosswordScreen(
      title: 'interactive.crosswords_title'.tr(),
      titleStyle: AppTheme.appBarTitleStyle(context),
      dataSource: dataSource ?? const AssetCrosswordDataSource('assets/data/nia_crosswords.json'),
      languageCode: 'nia',
      customLabels: customLabels,
      primaryColor: primaryColor,
      accentColor: accentColor,
      centerTitle: false,
      onWordDefinitionTap: (word, pageTitle) {
        _showDefinitionSheet(context, word, pageTitle);
      },
    );
  }
}
