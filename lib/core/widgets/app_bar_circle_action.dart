import 'package:flutter/material.dart';

/// A circular back button with a semi-transparent dark background,
/// designed for [AppBar] and [SliverAppBar] leading slots to ensure high contrast
/// and visibility against hero images or saturated background colors.
class AppBarCircleBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color iconColor;
  final EdgeInsetsGeometry padding;

  const AppBarCircleBackButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor = Colors.white,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

    // If there is no custom handler and the route cannot pop, don't show an unclickable back button
    if (!canPop && onPressed == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: CircleAvatar(
        backgroundColor: backgroundColor ?? Colors.black.withValues(alpha: 0.45),
        child: IconButton(
          icon: Icon(
            useCloseButton ? Icons.close : Icons.arrow_back,
            color: iconColor,
          ),
          tooltip: useCloseButton
              ? MaterialLocalizations.of(context).closeButtonTooltip
              : MaterialLocalizations.of(context).backButtonTooltip,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: onPressed ?? () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}

/// A circular action button wrapper or custom widget container (such as a progress indicator)
/// with a semi-transparent dark background, designed for [AppBar.actions]
/// and [SliverAppBar.actions] to guarantee high contrast against images and colors.
class AppBarCircleAction extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry margin;

  const AppBarCircleAction({
    super.key,
    required this.child,
    this.backgroundColor,
    this.margin = const EdgeInsets.only(right: 12.0),
  });

  /// Factory constructor to quickly build an icon button action with standard circular styling
  factory AppBarCircleAction.icon({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    Color? backgroundColor,
    Color iconColor = Colors.white,
    EdgeInsetsGeometry margin = const EdgeInsets.only(right: 12.0),
  }) {
    return AppBarCircleAction(
      key: key,
      backgroundColor: backgroundColor,
      margin: margin,
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: CircleAvatar(
        backgroundColor: backgroundColor ?? Colors.black.withValues(alpha: 0.45),
        child: child,
      ),
    );
  }
}

/// Creates a [ThemeData] that equips standard Flutter [BackButton]s with a circular backdrop,
/// useful for third-party module screens (like course reader, newsletter, and crosswords).
ThemeData appBarCircleBackTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    ),
  );
}

