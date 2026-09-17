/// Configuration rules for cleaning, filtering, and sanitizing MediaWiki HTML content.
class DynamicHtmlRules {
  /// Selectors for elements that must be completely removed from the DOM before rendering.
  static const List<String> defaultRemoveSelectors = [
    // MediaWiki edit links & buttons
    '.mw-editsection',
    '.mw-editsection-bracket',
    '.mw-editsection-divider',
    '.mw-editsection-visualeditor',
    'a[href*="action=edit"]',
    'a[href*="veaction=edit"]',

    // Clutter, banners, and non-mobile components
    '.mw-empty-elt',
    '.mw-jump-link',
    '.nomobile',
    '.ambox',
    '.navbox',
    '.sistersitebox',
    '#toc',
    '.toc',
    'nav',
    'script',
    'style',

    // Citation backlink arrows (e.g. "↑")
    '.mw-cite-backlink',
  ];

  /// Selectors for elements that should remain accessible for data extraction
  /// (such as citations / footnotes) but hidden visually in the main prose.
  static const List<String> defaultHideSelectors = [
    '.reflist',
    '.references',
    '.mw-references-wrap',
    '#references',
  ];

  /// Section heading keywords indicating the end of readable prose / start of appendices
  /// (case-insensitive).
  static const List<String> defaultReferenceKeywords = [
    'famotokhi ba gahe',
    'famotokhi',
    'footnotes',
    'umbu',
    'rujukan',
    'sumber',
    'catatan kaki',
    'referensi',
    'references',
    'pranala luar',
    'lihat pula',
    'bale zato',
    'fabaliŵa lala',
    'fabaliwa lala',
  ];

  final List<String> removeSelectors;
  final List<String> hideSelectors;
  final List<String> referenceKeywords;

  const DynamicHtmlRules({
    this.removeSelectors = defaultRemoveSelectors,
    this.hideSelectors = defaultHideSelectors,
    this.referenceKeywords = defaultReferenceKeywords,
  });

  /// Check if a section title matches any appendix/reference keyword.
  bool isReferenceHeading(String headingTitle) {
    final lower = headingTitle.toLowerCase().trim();
    for (final kw in referenceKeywords) {
      if (lower == kw || lower.startsWith('$kw ') || lower.startsWith('$kw:')) {
        return true;
      }
    }
    return false;
  }
}
