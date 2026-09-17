import 'dart:convert';
import 'package:http/http.dart' as http;
import 'wiki_config.dart';
import 'html_processor.dart';

/// Data class holding raw parsed result from Wikimedia Action API.
class WikiApiParseResult {
  final int pageId;
  final int revid;
  final String title;
  final String displayTitle;
  final String rawHtml;
  final ProcessedArticle processed;

  const WikiApiParseResult({
    required this.pageId,
    required this.revid,
    required this.title,
    required this.displayTitle,
    required this.rawHtml,
    required this.processed,
  });
}

/// Service for communicating with Wikimedia Action API across Wikipedia, Incubator, and Wiktionary.
class WikiApiService {
  final http.Client _client;
  final HtmlProcessor _processor;
  final Map<String, String> _mediaUrlCache = {};

  WikiApiService({
    http.Client? client,
    HtmlProcessor? processor,
  })  : _client = client ?? http.Client(),
        _processor = processor ?? const HtmlProcessor();

  /// Fetches and parses an article from Wikimedia by pageId or pageTitle.
  Future<WikiApiParseResult?> parseArticle({
    String host = WikiConfig.wikipediaHost,
    int? pageId,
    String? pageTitle,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    assert(pageId != null || pageTitle != null, 'Either pageId or pageTitle must be provided');

    final queryParams = <String, String>{
      'action': 'parse',
      'prop': 'text|images|revid|displaytitle',
      'mobileformat': '1',
      'redirects': '1',
    };

    if (pageId != null && pageId > 0) {
      queryParams['pageid'] = pageId.toString();
    } else if (pageTitle != null && pageTitle.isNotEmpty) {
      queryParams['page'] = pageTitle;
    }

    final uri = WikiConfig.actionApiUri(host, queryParams);

    final response = await _client.get(uri, headers: WikiConfig.headers).timeout(timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json.containsKey('error')) {
        final errorInfo = json['error']?['info'] ?? json['error'].toString();
        throw Exception('Wikimedia API error: $errorInfo');
      }

      final parseData = json['parse'] as Map<String, dynamic>?;
      if (parseData != null) {
        final onlinePageId = parseData['pageid'] as int? ?? pageId ?? 0;
        final onlineRevid = parseData['revid'] as int? ?? 0;
        final title = parseData['title'] as String? ?? pageTitle ?? '';
        final displayTitle = parseData['displaytitle'] as String? ?? title;
        final rawHtml = parseData['text']?['*'] as String? ?? '';

        final processed = _processor.process(
          rawContent: rawHtml,
          defaultTitle: displayTitle,
        );

        return WikiApiParseResult(
          pageId: onlinePageId,
          revid: onlineRevid,
          title: title,
          displayTitle: displayTitle,
          rawHtml: rawHtml,
          processed: processed,
        );
      }
    }

    return null;
  }

  /// Resolves the full or thumbnail URL for a MediaWiki File (e.g. "File:Example.jpg" or "File:Audio.ogg").
  Future<String?> resolveMediaUrl({
    required String fileName,
    String host = WikiConfig.wikipediaHost,
    int? thumbWidth,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final cleanName = fileName.startsWith('File:') ? fileName : 'File:$fileName';
    final cacheKey = '$host:$cleanName:${thumbWidth ?? 'orig'}';

    if (_mediaUrlCache.containsKey(cacheKey)) {
      return _mediaUrlCache[cacheKey];
    }

    final queryParams = <String, String>{
      'action': 'query',
      'titles': cleanName,
      'prop': 'imageinfo',
      'iiprop': 'url',
    };

    if (thumbWidth != null) {
      queryParams['iiurlwidth'] = thumbWidth.toString();
    }

    final uri = WikiConfig.actionApiUri(host, queryParams);
    final response = await _client.get(uri, headers: WikiConfig.headers).timeout(timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final pages = json['query']?['pages'] as Map<String, dynamic>?;
      if (pages != null && pages.isNotEmpty) {
        final firstPage = pages.values.first as Map<String, dynamic>?;
        final imageInfoList = firstPage?['imageinfo'] as List<dynamic>?;
        if (imageInfoList != null && imageInfoList.isNotEmpty) {
          final info = imageInfoList.first as Map<String, dynamic>;
          final url = thumbWidth != null ? (info['thumburl'] as String? ?? info['url'] as String?) : (info['url'] as String?);
          if (url != null && url.isNotEmpty) {
            _mediaUrlCache[cacheKey] = url;
            return url;
          }
        }
      }
    }

    return null;
  }

  /// Clears in-memory thumbnail and media URL cache.
  void clearCache() {
    _mediaUrlCache.clear();
  }
}
