import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available font size scale options for user preference.
enum FontSizeScale {
  small(1.0, 'small'),
  standard(1.15, 'standard'),
  large(1.30, 'large'),
  extraLarge(1.45, 'xlarge');

  final double scaleFactor;
  final String key;

  const FontSizeScale(this.scaleFactor, this.key);

  static FontSizeScale fromKey(String? key) {
    if (key == null) return FontSizeScale.standard;
    return FontSizeScale.values.firstWhere(
      (e) => e.key == key,
      orElse: () => FontSizeScale.standard,
    );
  }
}

/// State notifier managing persisted font size scale setting.
class FontSizeNotifier extends StateNotifier<FontSizeScale> {
  static const _prefKey = 'app_font_size_scale';
  SharedPreferences? _prefs;

  FontSizeNotifier() : super(FontSizeScale.standard) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final savedKey = _prefs?.getString(_prefKey);
    if (savedKey != null) {
      state = FontSizeScale.fromKey(savedKey);
    }
  }

  Future<void> setFontSize(FontSizeScale size) async {
    state = size;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(_prefKey, size.key);
  }
}

/// Provider for the active [FontSizeScale].
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, FontSizeScale>(
  (ref) {
    return FontSizeNotifier();
  },
);

/// Provider for the numeric scale factor (e.g. 0.85, 1.0, 1.15, 1.30).
final fontSizeScaleProvider = Provider<double>((ref) {
  return ref.watch(fontSizeProvider).scaleFactor;
});
