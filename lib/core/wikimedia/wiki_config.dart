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

  /// Returns standard Action API URI for a given host and query parameters.
  static Uri actionApiUri(String host, Map<String, String> queryParams) {
    return Uri.https(host, '/w/api.php', {
      'format': 'json',
      ...queryParams,
    });
  }
}
