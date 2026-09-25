import 'wiki_config.dart';

/// Sealed class hierarchy representing typed user interaction intents when clicking
/// links inside Wikimedia and Heritage articles.
sealed class WikiLinkIntent {
  const WikiLinkIntent();
}

/// Intent to open an interactive reference / footnote bottom sheet.
class ShowReferenceIntent extends WikiLinkIntent {
  final String referenceId;
  final int index;
  final String? fallbackText;

  const ShowReferenceIntent({
    required this.referenceId,
    required this.index,
    this.fallbackText,
  });

  @override
  String toString() => 'ShowReferenceIntent(id: $referenceId, index: $index)';
}

/// Intent to stream an audio file (e.g. Wiktionary pronunciation .ogg/.mp3).
class PlayAudioIntent extends WikiLinkIntent {
  final String audioUrl;

  const PlayAudioIntent({required this.audioUrl});

  @override
  String toString() => 'PlayAudioIntent(url: $audioUrl)';
}

/// Intent to navigate to another wiki or heritage article.
class NavigateToArticleIntent extends WikiLinkIntent {
  final String title;
  final bool isRedLink;
  final String? wikiHost;

  const NavigateToArticleIntent({
    required this.title,
    this.isRedLink = false,
    this.wikiHost,
  });

  @override
  String toString() => 'NavigateToArticleIntent(title: $title, isRedLink: $isRedLink, host: $wikiHost)';
}

/// Intent to launch an external web URL outside the wiki domain.
class OpenExternalUrlIntent extends WikiLinkIntent {
  final String url;

  const OpenExternalUrlIntent({required this.url});

  @override
  String toString() => 'OpenExternalUrlIntent(url: $url)';
}

/// Intent to ignore the link tap (e.g. non-actionable anchors, edit section links, or empty links).
class IgnoreLinkIntent extends WikiLinkIntent {
  const IgnoreLinkIntent();

  @override
  String toString() => 'IgnoreLinkIntent()';
}

/// Resolves interwiki prefixes (e.g. `w:nia:`, `w:`, `wikipedia:`, `wikt:`, `incubator:`)
/// returning a record of `(cleanedTitle, targetWikiHost)`.
(String cleanTitle, String? wikiHost) resolveInterwikiTitle(String rawTitle, [String? currentHost]) {
  var title = rawTitle.trim();
  String? host = currentHost;

  // Normalize leading colons: e.g. :w:nia:Title -> w:nia:Title
  if (title.startsWith(':')) {
    title = title.substring(1).trim();
  }

  final lower = title.toLowerCase();
  if (lower.startsWith('w:nia:')) {
    title = title.substring(6).trim();
    host = WikiConfig.wikipediaHost;
  } else if (lower.startsWith('w:id:') || lower.startsWith('wikipedia:id:')) {
    title = title.substring(title.indexOf('id:') + 3).trim();
    host = 'id.wikipedia.org';
  } else if (lower.startsWith('w:en:') || lower.startsWith('wikipedia:en:')) {
    title = title.substring(title.indexOf('en:') + 3).trim();
    host = 'en.wikipedia.org';
  } else if (lower.startsWith('w:') || lower.startsWith('wikipedia:')) {
    title = title.substring(title.indexOf(':') + 1).trim();
    host = WikiConfig.wikipediaHost;
  } else if (lower.startsWith('wikt:nia:') || lower.startsWith('wiktionary:nia:')) {
    title = title.substring(title.indexOf('nia:') + 4).trim();
    host = WikiConfig.wiktionaryHost;
  } else if (lower.startsWith('wikt:') || lower.startsWith('wiktionary:')) {
    title = title.substring(title.indexOf(':') + 1).trim();
    host = WikiConfig.wiktionaryHost;
  } else if (lower.startsWith('incubator:')) {
    title = title.substring(10).trim();
    host = WikiConfig.incubatorHost;
  }

  return (title, host);
}

/// Parses a raw link URL from rendered HTML into a strongly typed [WikiLinkIntent].
WikiLinkIntent parseWikiLink(String rawUrl, {String defaultWikiHost = WikiConfig.wikipediaHost}) {
  var url = rawUrl.trim().replaceAll('&#95;', '_');
  if (url.isEmpty) {
    return const IgnoreLinkIntent();
  }

  // 1. Check for audio media files (.ogg, .mp3, .wav)
  final lowerUrl = url.toLowerCase();
  if (lowerUrl.endsWith('.ogg') ||
      lowerUrl.endsWith('.mp3') ||
      lowerUrl.endsWith('.wav') ||
      lowerUrl.contains('.ogg?') ||
      lowerUrl.contains('.mp3?') ||
      lowerUrl.contains('.wav?')) {
    final cleanAudioUrl = url.startsWith('//') ? 'https:$url' : url;
    return PlayAudioIntent(audioUrl: cleanAudioUrl);
  }

  // Normalize protocol-relative URLs (e.g. //nia.wikipedia.org/wiki/...)
  if (url.startsWith('//')) {
    url = 'https:$url';
  }

  // 2. Check for footnote / citation anchors (#cite_note, #fn-, #footnote, #cite_ref)
  final hashIndex = url.indexOf('#');
  final isFootnote = url.startsWith('#') ||
      url.contains('cite_note') ||
      url.contains('cite_ref') ||
      url.contains('footnote') ||
      url.contains('fn-');

  if (isFootnote) {
    final target = hashIndex >= 0 ? url.substring(hashIndex + 1) : url;
    final cleanId = target.replaceFirst(RegExp(r'^(footnote-|cite_note-|fn-|cite_ref-)'), '');
    final digitMatch = RegExp(r'\d+').firstMatch(cleanId);
    final index = digitMatch != null ? (int.tryParse(digitMatch.group(0)!) ?? 1) : 1;

    return ShowReferenceIntent(
      referenceId: target,
      index: index,
    );
  }

  // 3. Red links vs Edit section links
  final isRedLink = lowerUrl.contains('redlink=1');
  if (!isRedLink && (lowerUrl.contains('action=edit') || lowerUrl.contains('veaction=edit'))) {
    return const IgnoreLinkIntent();
  }

  // If it's a red link via index.php?title=XYZ&action=edit&redlink=1 or /wiki/XYZ?action=edit&redlink=1
  if (isRedLink) {
    String rawTitle = '';
    final uri = Uri.tryParse(url);
    if (uri != null && uri.queryParameters.containsKey('title')) {
      rawTitle = uri.queryParameters['title']!;
    } else if (url.contains('/wiki/')) {
      final afterWiki = url.substring(url.indexOf('/wiki/') + 6);
      rawTitle = afterWiki.split('?').first;
    }
    try {
      rawTitle = Uri.decodeComponent(rawTitle);
    } catch (_) {}
    final decodedTitle = rawTitle.replaceAll('_', ' ').trim();
    if (decodedTitle.isNotEmpty) {
      final (cleanTitle, host) = resolveInterwikiTitle(
        decodedTitle,
        (uri != null && uri.host.isNotEmpty) ? uri.host : defaultWikiHost,
      );
      return NavigateToArticleIntent(
        title: cleanTitle,
        isRedLink: true,
        wikiHost: host ?? defaultWikiHost,
      );
    }
  }

  // 4. Internal wiki links: /wiki/<Title> or ./<Title> or ../<Title>
  if (url.startsWith('/wiki/') || url.startsWith('./') || url.startsWith('../')) {
    var rawTitle = url;
    if (url.startsWith('/wiki/')) {
      rawTitle = url.substring(6);
    } else if (url.startsWith('./')) {
      rawTitle = url.substring(2);
    } else if (url.startsWith('../')) {
      rawTitle = url.substring(3);
    }

    // Strip anchor if present in internal link: /wiki/Title#Section -> Title
    final anchorIdx = rawTitle.indexOf('#');
    if (anchorIdx >= 0) {
      rawTitle = rawTitle.substring(0, anchorIdx);
    }

    try {
      rawTitle = Uri.decodeComponent(rawTitle);
    } catch (_) {}

    final decodedTitle = rawTitle.replaceAll('_', ' ').trim();
    if (decodedTitle.isNotEmpty) {
      final isRedLink = url.contains('redlink=1');
      var (cleanTitle, host) = resolveInterwikiTitle(decodedTitle, null);
      host ??= RegExp(r'^W[bptqysvn]\/', caseSensitive: false).hasMatch(cleanTitle)
          ? WikiConfig.incubatorHost
          : defaultWikiHost;
      return NavigateToArticleIntent(
        title: cleanTitle,
        isRedLink: isRedLink,
        wikiHost: host,
      );
    }
  }

  // 5. External HTTP / HTTPS links
  if (url.startsWith('http://') || url.startsWith('https://')) {
    final uri = Uri.tryParse(url);
    // If it's a link to a MediaWiki project, check if it points to an article
    if (uri != null &&
        (uri.host.endsWith('.wikipedia.org') ||
            uri.host.endsWith('.wiktionary.org') ||
            uri.host.endsWith('.wikibooks.org') ||
            uri.host == WikiConfig.incubatorHost)) {
      String? rawPageTitle;
      if (uri.path.startsWith('/wiki/')) {
        rawPageTitle = uri.path.substring(6);
      } else if (uri.queryParameters.containsKey('title')) {
        rawPageTitle = uri.queryParameters['title'];
      }
      if (rawPageTitle != null && rawPageTitle.isNotEmpty) {
        var pageTitle = rawPageTitle;
        final hashIdx = pageTitle.indexOf('#');
        if (hashIdx >= 0) {
          pageTitle = pageTitle.substring(0, hashIdx);
        }
        try {
          pageTitle = Uri.decodeComponent(pageTitle);
        } catch (_) {}
        final decodedTitle = pageTitle.replaceAll('_', ' ').trim();
        if (decodedTitle.isNotEmpty) {
          final isRedLink = uri.queryParameters['action'] == 'edit' || uri.queryParameters['redlink'] == '1';
          final (cleanTitle, host) = resolveInterwikiTitle(decodedTitle, uri.host);
          return NavigateToArticleIntent(
            title: cleanTitle,
            isRedLink: isRedLink,
            wikiHost: host ?? uri.host,
          );
        }
      }
    }
    return OpenExternalUrlIntent(url: url);
  }

  return const IgnoreLinkIntent();
}
