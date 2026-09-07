import 'package:flutter/material.dart';

/// A wrapper widget that constrains content to a maximum width on large viewports
/// (desktop/tablet) while allowing full horizontal expansion on smaller viewports (mobile).
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = 960.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: content,
      );
    }

    return content;
  }
}
