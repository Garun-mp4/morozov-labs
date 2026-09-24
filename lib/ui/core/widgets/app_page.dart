import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.child,
    super.key,
    this.title,
    this.actions,
    this.showAppBar = true,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 28),
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showAppBar;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: title == null ? null : Text(title!),
              actions: actions,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        top: !showAppBar,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
