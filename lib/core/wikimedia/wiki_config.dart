/// Wikimedia configuration, user agent headers, and endpoint utilities.
class WikiConfig {
  /// Identifying User-Agent string as required by Wikimedia API policies:
  /// https://meta.wikimedia.org/wiki/User-Agent_policy
  static const String userAgent =
      'NiasHeritage/1.0.0 (https://sslaia.github.io/niasheritage; contact: slaia@yahoo.com) Dart/Flutter';

  /// Standard HTTP headers for Wikimedia requests.
  static Map<String, String> get headers => {
        'User-Agent': userAgent,
        'Accept': 'application/json',
      };

  /// Primary Wikimedia hosts.
  static const String wikipediaHost = 'nia.wikipedia.org';
  static const String incubatorHost = 'incubator.wikimedia.org';
  static const String wiktionaryHost = 'nia.wiktionary.org';
  static const String wikibooksIncubatorPrefix = 'Wb/nia/';

  /// Returns standard Action API URI for a given host and query parameters.
  static Uri actionApiUri(String host, Map<String, String> queryParams) {
    return Uri.https(host, '/w/api.php', {
      'format': 'json',
      ...queryParams,
    });
  }

  /// Normalizes page title for Incubator projects.
  /// If the page is on incubator and does not start with Wb/nia/, prepends it
  /// (except for special namespaces like Category:, Template:, Special:).
  static String normalizeIncubatorTitle(String title) {
    var clean = title.trim();
    if (clean.startsWith('Wb/nia/')) return clean;

    final colonIdx = clean.indexOf(':');
    if (colonIdx >= 0) {
      final ns = clean.substring(0, colonIdx);
      final rest = clean.substring(colonIdx + 1);
      final lowerNs = ns.toLowerCase();
      if (lowerNs == 'category' || lowerNs == 'kategori' || lowerNs == 'template' || lowerNs == 'special') {
        return '$ns:Wb/nia/$rest';
      }
    }
    return 'Wb/nia/$clean';
  }
}
