import 'package:flutter/material.dart';

/// Parses inline HTML tags (<b>, <strong>, <i>, <em>) and markdown (**bold**, *italic*)
/// into a structured List of [InlineSpan] maintaining the base [TextStyle].
List<InlineSpan> parseInlineFormattingSpans(
  String text, {
  required TextStyle baseStyle,
  Color? boldColor,
}) {
  if (text.isEmpty) return const [];

  final spans = <InlineSpan>[];

  // Regex matches <b>, <strong>, <i>, <em>, **, and *
  final regex = RegExp(
    r'(<b>|<strong>)(.*?)(<\/b>|<\/strong>)|' // 1: open, 2: content, 3: close (bold)
    r'(<i>|<em>)(.*?)(<\/i>|<\/em>)|'         // 4: open, 5: content, 6: close (italic)
    r'\*\*(.*?)\*\*|'                         // 7: content (**bold**)
    r'\*(.*?)\*',                             // 8: content (*italic*)
    dotAll: true,
    caseSensitive: false,
  );

  int currentIndex = 0;

  for (final match in regex.allMatches(text)) {
    // Add text preceding the match
    if (match.start > currentIndex) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start),
        style: baseStyle,
      ));
    }

    final boldHtmlContent = match.group(2);
    final italicHtmlContent = match.group(5);
    final boldMdContent = match.group(7);
    final italicMdContent = match.group(8);

    if (boldHtmlContent != null) {
      spans.add(TextSpan(
        text: boldHtmlContent,
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: boldColor ?? baseStyle.color,
        ),
      ));
    } else if (italicHtmlContent != null) {
      spans.add(TextSpan(
        text: italicHtmlContent,
        style: baseStyle.copyWith(fontStyle: FontStyle.italic),
      ));
    } else if (boldMdContent != null) {
      spans.add(TextSpan(
        text: boldMdContent,
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: boldColor ?? baseStyle.color,
        ),
      ));
    } else if (italicMdContent != null) {
      spans.add(TextSpan(
        text: italicMdContent,
        style: baseStyle.copyWith(fontStyle: FontStyle.italic),
      ));
    }

    currentIndex = match.end;
  }

  // Trailing text after the last match
  if (currentIndex < text.length) {
    spans.add(TextSpan(
      text: text.substring(currentIndex),
      style: baseStyle,
    ));
  }

  return spans;
}
