import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// The page behind a skeleton: the page's colour and the same padding as
/// the list it stands in for, held still while it loads.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    required this.padding,
    required this.children,
  });

  /// Padding below the bars; the bars' own height is added on top.
  final EdgeInsets padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: padding.copyWith(
            top: padding.top + insets.top,
            bottom: padding.bottom + insets.bottom,
          ),
          children: children,
        ),
      ),
    );
  }
}
