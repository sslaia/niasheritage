import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage and check offline cached content for interactive and wiki reader modules.
class WikiContentCacheService {
  static const String courseCachePrefix = 'wiki_course_cache_';
  static const String newsletterCachePrefix = 'wiki_newsletter_cache_';

  final SharedPreferences _prefs;

  WikiContentCacheService(this._prefs);

  static Future<WikiContentCacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return WikiContentCacheService(prefs);
  }

  /// Checks whether a course cache exists for the given domain and page title.
  bool hasCachedCourse(String domain, String pageTitle) {
    final key = '$courseCachePrefix${domain}_$pageTitle';
    return _prefs.containsKey(key);
  }

  /// Checks whether a newsletter cache exists for the given domain and page title.
  bool hasCachedNewsletter(String domain, String pageTitle) {
    final key = '$newsletterCachePrefix${domain}_$pageTitle';
    return _prefs.containsKey(key);
  }

  /// Clears cache for course or newsletter
  Future<bool> clearKey(String key) => _prefs.remove(key);

  /// Clears all interactive wiki cache entries
  Future<void> clearAllWikiCaches() async {
    final keys = _prefs.getKeys().where(
          (k) => k.startsWith(courseCachePrefix) || k.startsWith(newsletterCachePrefix),
        );
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
