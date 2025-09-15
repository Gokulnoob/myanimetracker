import 'package:flutter/material.dart';

/// A scaffold wrapper that properly handles keyboard interactions
/// and prevents overflow issues across the app
class KeyboardAwareScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final bool dismissKeyboardOnTap;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  const KeyboardAwareScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    this.dismissKeyboardOnTap = true,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    Widget scaffoldBody = body;

    // Wrap with gesture detector for keyboard dismissal
    if (dismissKeyboardOnTap) {
      scaffoldBody = GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: scaffoldBody,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: SafeArea(child: scaffoldBody),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// A custom scroll view that handles keyboard interactions properly
class KeyboardAwareScrollView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool reverse;
  final Axis scrollDirection;
  final bool primary;

  const KeyboardAwareScrollView({
    super.key,
    required this.children,
    this.padding,
    this.controller,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      reverse: reverse,
      scrollDirection: scrollDirection,
      primary: primary,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        ),
      ],
    );
  }
}

/// A widget that adapts its content based on available space
/// Perfect for forms and content that needs to work with keyboards
class AdaptiveContent extends StatelessWidget {
  final Widget child;
  final Widget? compactChild;
  final double compactThreshold;

  const AdaptiveContent({
    super.key,
    required this.child,
    this.compactChild,
    this.compactThreshold = 400,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < compactThreshold;
        
        if (isCompact && compactChild != null) {
          return compactChild!;
        }
        
        return child;
      },
    );
  }
}

/// Extension for easy keyboard dismissal
extension KeyboardUtils on BuildContext {
  void dismissKeyboard() {
    FocusScope.of(this).unfocus();
  }
  
  bool get isKeyboardVisible {
    return MediaQuery.of(this).viewInsets.bottom > 0;
  }
  
  double get keyboardHeight {
    return MediaQuery.of(this).viewInsets.bottom;
  }
}