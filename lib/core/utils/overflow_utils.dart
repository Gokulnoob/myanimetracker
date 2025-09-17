import 'package:flutter/material.dart';

/// Utility class for preventing overflow issues throughout the app
class OverflowUtils {
  /// Creates a safe text widget that prevents overflow
  static Widget safeText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: true,
    );
  }

  /// Creates a safe row that handles overflow gracefully
  static Widget safeRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: children,
        ),
      ),
    );
  }

  /// Creates a flexible row that wraps content when needed
  static Widget flexibleRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    double spacing = 8.0,
    double runSpacing = 4.0,
  }) {
    return Wrap(
      alignment: wrapAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }

  /// Creates a constrained container that prevents overflow
  static Widget constrainedContainer({
    required Widget child,
    double? maxWidth,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BoxDecoration? decoration,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }

  /// Creates a safe column that handles keyboard overflow
  static Widget safeColumn({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    bool scrollable = true,
  }) {
    if (scrollable) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }
  }

  /// Creates a responsive grid count based on screen width
  static int getResponsiveGridCount(
    BuildContext context, {
    double itemWidth = 160.0,
    int minCount = 2,
    int maxCount = 6,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 32.0; // Account for horizontal padding
    final availableWidth = screenWidth - padding;
    final count = (availableWidth / itemWidth).floor();
    return count.clamp(minCount, maxCount);
  }

  /// Creates a safe scaffold that handles overflow
  static Widget safeScaffold({
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    bool resizeToAvoidBottomInset = true,
  }) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: body ?? const SizedBox.shrink(),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Extension on String for safe text rendering
extension SafeString on String {
  /// Creates a safe text widget from this string
  Widget toSafeText({
    TextStyle? style,
    int? maxLines,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
  }) {
    return OverflowUtils.safeText(
      this,
      style: style,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}

/// Extension on List\<Widget\> for safe layouts
extension SafeWidgetList on List<Widget> {
  /// Creates a safe row from this list of widgets
  Widget toSafeRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return OverflowUtils.safeRow(
      children: this,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  /// Creates a flexible row from this list of widgets
  Widget toFlexibleRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    double spacing = 8.0,
  }) {
    return OverflowUtils.flexibleRow(
      children: this,
      mainAxisAlignment: mainAxisAlignment,
      wrapAlignment: wrapAlignment,
      spacing: spacing,
    );
  }

  /// Creates a safe column from this list of widgets
  Widget toSafeColumn({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    bool scrollable = true,
  }) {
    return OverflowUtils.safeColumn(
      children: this,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      scrollable: scrollable,
    );
  }
}
