import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/url_launcher_utils.dart';
import 'package:wiki_crosswords/wiki_crosswords.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bar_circle_action.dart';

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
                      await openInAppBrowser(url);
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
      'crossword_title': trOr('interactive.crosswords_title', isNias ? 'Dahö-Dahö Li Niha' : (isId ? 'Teka-Teki Silang' : 'Crosswords & Puzzles')),
      'crosswords': trOr('interactive.crosswords', isNias ? 'Dahö-Dahö' : (isId ? 'Teka-Teki Silang' : 'Crosswords')),
      'crossword_daily': trOr('interactive.crossword_daily', isNias ? 'Dahö-Dahö Ma\'ökhö' : (isId ? 'TTS Harian' : 'Daily Crossword')),
      'crossword_favorites': trOr('interactive.crossword_favorites', isNias ? 'Dahö-dahö Somasido' : (isId ? 'TTS Favorit' : 'Favorites')),
      'crossword_scoreboard': trOr('interactive.crossword_scoreboard', isNias ? 'Fangerai Bua' : (isId ? 'Papan Skor' : 'Scoreboard')),
      'crossword_score': trOr('interactive.crossword_score', isNias ? 'Bua' : (isId ? 'Skor' : 'Score')),
      'crossword_score_earned': trOr('interactive.crossword_score_earned', isNias ? 'Bua nisöndra' : (isId ? 'Skor diperoleh' : 'Scores earned')),
      'crossword_weekly': trOr('interactive.crossword_weekly', isNias ? 'Si\'ero Migu' : (isId ? 'Mingguan' : 'Weekly')),
      'crossword_monthly': trOr('interactive.crossword_monthly', isNias ? 'Si\'ero Waŵa' : (isId ? 'Bulanan' : 'Monthly')),
      'crossword_yearly': trOr('interactive.crossword_yearly', isNias ? 'Si\'ero Röfi' : (isId ? 'Tahunan' : 'Yearly')),
      'crossword_no_favorite': trOr('interactive.crossword_no_favorite', isNias ? 'Lö nasa so dahö-dahö omasi\'ö' : (isId ? 'Belum ada TTS favorit' : 'No favorited crosswords yet')),
      'crossword_open': trOr('interactive.crossword_open', isNias ? 'Bokai' : (isId ? 'Buka' : 'Open')),
      'crossword_play': trOr('interactive.crossword_play', isNias ? 'Fo\'ösi Dahö-Dahö Ma\'ökhö' : (isId ? 'Mainkan TTS Hari Ini' : 'Play Today\'s Puzzle')),
      'crossword_share': trOr('interactive.crossword_share', isNias ? 'Fa\'ohe\'ö' : (isId ? 'Bagikan' : 'Share')),
      'crossword_share_1': trOr('interactive.crossword_share_1', isNias ? 'No ufo\'ösi dahö-dahö ma\'ökhö! Bua nisöndragu ba migu andre:' : (isId ? 'Saya telah menyelesaikan TTS Nias Heritage hari ini. Skor saya minggu ini:' : 'I completed the Nias Heritage crossword for today. My score this week:')),
      'crossword_share_2': trOr('interactive.crossword_share_2', isNias ? 'Ae ba aplikasi Nias Heritage ba wamo\'ösi dahö-dahö.' : (isId ? 'Mau ikut main? Unduh aplikasi Nias Heritage.' : 'Want to play too? Download Nias Heritage App.')),
      'crossword_notes': trOr('interactive.crossword_notes', isNias ? 'Nitöngöni' : (isId ? 'Catatan' : 'Note')),
      'crossword_notes_1': trOr('interactive.crossword_notes_1', isNias ? '1. Ha hurufo fo\'ösi. Talu\'i dandra wamabali (-) ba tandra wamadö\'ö (\'). Duma-dumania: riŵi-riŵi tobali riwiriwi ba abo\'a tobali aboa.' : (isId ? '1. Hanya huruf biasa. Jangan gunakan tanda hubung (-) atau apostrof (\').' : '1. Only letters. Don\'t include hyphen (-) or apostrophe (\')')),
      'crossword_notes_2': trOr('interactive.crossword_notes_2', isNias ? '2. Fuli\'ö ba da\'a dania ba zibongi. Tefa\'ele\'ö nösi sindruhu dahö-dahö aefa bözi 8!' : (isId ? '2. Jawaban resmi akan diumumkan pukul 20.00 WIB!' : '2. Come back this evening. The correct answers will be revealed at 8pm!')),
      'crossword_check_words': trOr('interactive.crossword_check_words', isNias ? 'Oroma\'ö Nösi Sindruhu' : (isId ? 'Buka Kunci Kata' : 'Check Words')),
      'crossword_hide_words': trOr('interactive.crossword_hide_words', isNias ? 'Bini\'ö Nösi Sindruhu' : (isId ? 'Sembunyikan Kunci' : 'Hide Words')),
      'crossword_bonus': trOr('interactive.crossword_bonus', isNias ? 'Buala' : (isId ? 'Bonus' : 'Bonus')),
      'crossword_wiktionary_ref': trOr('interactive.crossword_wiktionary_ref', isNias ? 'Khai-khai ba Wikikamus' : (isId ? 'Referensi Wikikamus' : 'Wiktionary Reference')),
      'crossword_open_wiktionary': trOr('interactive.crossword_open_wiktionary', isNias ? 'Bokai ba Wikikamus' : (isId ? 'Buka di Wikikamus' : 'Open in Wiktionary')),
      'crossword_no': trOr('interactive.crossword_no', isNias ? 'Lö tesöndra dahö-dahö' : (isId ? 'TTS tidak tersedia' : 'No crossword puzzle available')),
      'across': trOr('interactive.crossword_across', isNias ? 'Misa' : (isId ? 'Mendatar' : 'Across')),
      'down': trOr('interactive.crossword_down', isNias ? 'Mitou' : (isId ? 'Menurun' : 'Down')),
      'words': trOr('interactive.crossword_words', isNias ? 'fehede' : (isId ? 'kata' : 'words')),
      'retry': trOr('interactive.crossword_retry', isNias ? 'Fuli lau' : (isId ? 'Coba lagi' : 'Retry')),
      'reference': trOr('interactive.crossword_reference', isNias ? 'Khai-khai' : (isId ? 'Referensi' : 'Reference')),
    };

    const primaryColor = Color(0xFFD97706); // Amber Heritage Gold
    const accentColor = Color(0xFFB45309);

    return Theme(
      data: appBarCircleBackTheme(context),
      child: CrosswordScreen(
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
      ),
    );
  }
}
