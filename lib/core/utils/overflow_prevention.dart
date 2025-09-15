import 'package:flutter/material.dart';

/// Utility class for preventing overflow issues throughout the app
class OverflowPrevention {
  /// Wraps text to prevent overflow with ellipsis
  static Widget safeText(
    String text, {
    TextStyle? style,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
    );
  }

  /// Creates a flexible row that prevents overflow
  static Widget safeRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.map((child) {
        // Wrap each child in Flexible to prevent overflow
        if (child is Expanded || child is Flexible) {
          return child; // Already flexible
        }
        return Flexible(child: child);
      }).toList(),
    );
  }

  /// Creates a column that handles overflow gracefully
  static Widget safeColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Creates a container with safe padding that adapts to screen size
  static EdgeInsets safePadding(
    BuildContext context, {
    double horizontal = 16.0,
    double vertical = 8.0,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // Reduce padding on smaller screens
    final adjustedHorizontal =
        screenWidth < 360 ? horizontal * 0.75 : horizontal;

    return EdgeInsets.symmetric(
      horizontal: adjustedHorizontal,
      vertical: vertical,
    );
  }

  /// Responsive grid count based on screen width
  static int responsiveGridCount(
    BuildContext context, {
    int baseCount = 2,
    double minItemWidth = 160.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 32; // Account for padding

    return (availableWidth / minItemWidth).floor().clamp(1, 4);
  }

  /// Creates a responsive container that adapts to screen size
  static Widget responsiveContainer({
    required Widget child,
    required BuildContext context,
    double? maxWidth,
    EdgeInsets? padding,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Container(
      width: maxWidth != null
          ? (screenWidth > maxWidth ? maxWidth : double.infinity)
          : double.infinity,
      padding: padding ?? OverflowPrevention.safePadding(context),
      child: child,
    );
  }

  /// Wraps a widget to prevent bottom overflow during keyboard appearance
  static Widget keyboardSafe({
    required Widget child,
    bool resizeToAvoidBottomInset = true,
  }) {
    return Builder(
      builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          body: child,
        );
      },
    );
  }

  /// Creates a safe list tile that handles long text gracefully
  static Widget safeListTile({
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    int titleMaxLines = 2,
    int subtitleMaxLines = 1,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        maxLines: titleMaxLines,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              maxLines: subtitleMaxLines,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// Creates a chip that handles overflow gracefully
  static Widget safeChip({
    required String label,
    VoidCallback? onDeleted,
    Widget? deleteIcon,
    Color? backgroundColor,
    BorderSide? side,
    double maxWidth = 200.0,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Chip(
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        deleteIcon: deleteIcon,
        onDeleted: onDeleted,
        backgroundColor: backgroundColor,
        side: side,
      ),
    );
  }

  /// Creates a button with overflow protection
  static Widget safeButton({
    required String text,
    required VoidCallback? onPressed,
    Widget? icon,
    double? maxWidth,
    bool isElevated = true,
  }) {
    final button = isElevated
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon ?? const SizedBox.shrink(),
            label: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon ?? const SizedBox.shrink(),
            label: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );

    return maxWidth != null
        ? ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: button,
          )
        : button;
  }
}
