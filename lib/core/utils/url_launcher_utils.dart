import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Standard app-wide utility for opening web links in an in-app browser.
///
/// On mobile platforms, this opens Chrome Custom Tabs (Android) or
/// SFSafariViewController (iOS), ensuring users stay inside the app
/// and have an explicit close/back button ('X' or 'Done') to return
/// directly to their place in the app.
///
/// If [LaunchMode.inAppBrowserView] is unsupported or fails, it falls back
/// to [LaunchMode.inAppWebView], and finally to [LaunchMode.platformDefault].
Future<bool> openInAppBrowser(Uri uri) async {
  try {
    // 1. Primary: In-App Browser View (Chrome Custom Tabs on Android / SFSafariViewController on iOS)
    final launchedBrowserView = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    );
    if (launchedBrowserView) return true;
  } catch (e) {
    debugPrint('LaunchMode.inAppBrowserView failed for $uri: $e');
  }

  try {
    // 2. Secondary fallback: In-App WebView
    final launchedWebView = await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    );
    if (launchedWebView) return true;
  } catch (e) {
    debugPrint('LaunchMode.inAppWebView failed for $uri: $e');
  }

  try {
    // 3. Last-resort platform default (e.g. on Desktop platforms where mobile in-app views are unavailable)
    return await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (e) {
    debugPrint('LaunchMode.platformDefault failed for $uri: $e');
    return false;
  }
}

/// Convenience overload that parses and launches a string URL in the in-app browser.
Future<bool> openInAppBrowserUrl(String urlString) async {
  final trimmed = urlString.trim();
  if (trimmed.isEmpty) return false;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return false;
  return openInAppBrowser(uri);
}
