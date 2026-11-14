import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';

/// A page pushed inside the sign-in sheet: Keel's tide bar with back and
/// the title, an optional [header] beneath it, then the content.
class FlowPage extends StatelessWidget {
  const FlowPage({
    super.key,
    required this.title,
    required this.child,
    this.header,
    this.onBack,
  });

  final String title;
  final Widget child;
  final Widget? header;

  /// Takes back one step within the page; null when back leaves the page.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack?.call();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Material(
          type: MaterialType.transparency,
          child: ColoredBox(
            color: KeelColors.raised.of(context),
            child: Column(
              children: [
                Container(
                  color: KeelColors.tide.of(context),
                  padding: EdgeInsets.only(top: top),
                  height: top + 52,
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      RoundIconButton(
                        icon: CupertinoIcons.chevron_back,
                        label: 'Back',
                        foreground: CupertinoColors.white,
                        iconSize: 22,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                ),
                ?header,
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
