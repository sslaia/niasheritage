import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:easy_localization/easy_localization.dart';
import 'package:wiki_media_gallery/wiki_media_gallery.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_bar_circle_action.dart';

class NiasGalleryScreen extends StatefulWidget {
  const NiasGalleryScreen({super.key});

  @override
  State<NiasGalleryScreen> createState() => _NiasGalleryScreenState();
}

class _NiasGalleryScreenState extends State<NiasGalleryScreen> {
  List<GalleryItem> _items = [];
  bool _isLoading = true;
  String? _error;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadGallery();
    }
  }

  Future<void> _loadGallery() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final langCode = context.locale.languageCode;
      final jsonStr = await rootBundle.loadString('assets/data/gallery.json');
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      // As this app concerns only Nias related contents, prioritize 'nia' contents
      final langData =
          data['nia'] ?? data[langCode] ?? data['id'] ?? data['en'];

      final List<GalleryItem> loaded = [];
      if (langData is Map<String, dynamic>) {
        langData.forEach((categoryKey, itemsList) {
          if (itemsList is List) {
            for (final item in itemsList) {
              if (item is Map<String, dynamic>) {
                final rawFileName = item['fileName']?.toString() ?? '';
                final cleanName = _sanitizeFileName(rawFileName);
                final encoded = Uri.encodeComponent(cleanName);

                // Small historic photos on Wikimedia Commons limit thumbs to 300px; standard photos use 500px
                final isSmallHistoricPhoto =
                    cleanName.contains('Studioportret_van_een_man') ||
                    cleanName.contains(
                      'Een_man_springt_over_een_stenen_muur',
                    ) ||
                    cleanName.contains('Hoofdenfamilie_in_Noord-Nias');
                final thumbWidth = isSmallHistoricPhoto ? 300 : 500;

                final thumbUrl =
                    'https://commons.wikimedia.org/wiki/Special:FilePath/$encoded?width=$thumbWidth';
                final highResUrl = isSmallHistoricPhoto
                    ? 'https://commons.wikimedia.org/wiki/Special:FilePath/$encoded?width=500'
                    : 'https://commons.wikimedia.org/wiki/Special:FilePath/$encoded?width=1200';

                loaded.add(
                  GalleryItem.fromJson({
                    ...item,
                    'category': categoryKey,
                    'imageUrl': item['imageUrl'] ?? highResUrl,
                    'thumbnailUrl': item['thumbnailUrl'] ?? thumbUrl,
                  }),
                );
              }
            }
          }
        });
      }

      setState(() {
        _items = loaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String _sanitizeFileName(String raw) {
    var s = raw.trim();
    if (s.startsWith('File:')) {
      s = s.substring(5);
    }
    try {
      s = Uri.decodeFull(s);
    } catch (_) {}
    return s;
  }

  Map<String, String> _getCategoryLabels(String langCode) {
    switch (langCode) {
      case 'nia':
        return const {
          'arts': 'Sora-Sora',
          'architecture': 'Fangotomosa',
          'dance': 'Fanari',
          'others': 'Bö\'önia',
        };
      case 'id':
        return const {
          'arts': 'Seni',
          'architecture': 'Arsitektur',
          'dance': 'Tarian',
          'others': 'Lainnya',
        };
      default:
        return const {
          'arts': 'Arts',
          'architecture': 'Architecture',
          'dance': 'Dance',
          'others': 'Others',
        };
    }
  }

  String _getAllLabel(String langCode) {
    switch (langCode) {
      case 'nia':
        return 'Fefu';
      case 'id':
        return 'Semua';
      default:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final langCode = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        leading: const AppBarCircleBackButton(),
        title: Text(
          'interactive.gallery_title'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.sliverAppBarTitleStyle(fontSize: 20),
        ),
        actions: [
          AppBarCircleAction.icon(
            icon: Icons.refresh_rounded,
            tooltip: 'common.refresh'.tr(),
            onPressed: _loadGallery,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: _loadGallery,
                      child: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              )
            : MediaGalleryCarousel(
                items: _items,
                initialCategory: 'arts',
                categoryLabels: _getCategoryLabels(langCode),
                allLabel: _getAllLabel(langCode),
                primaryColor: theme.colorScheme.primary,
                accentColor: theme.colorScheme.secondary,
                onShareItem: (item) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.title} (Wikimedia Commons)'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
