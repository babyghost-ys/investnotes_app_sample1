import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/bar_strip.dart';

/// The body of a sign-in flow page, under the page's own bar: an optional
/// [header] such as the step tabs, then the content. On a wide screen, such
/// as an unfolded iPhone Duo, the form keeps a phone's measure, centred.
class FlowPage extends StatelessWidget {
  const FlowPage({super.key, required this.child, this.header});

  /// The widest a form in these flows grows.
  static const measure = 520.0;

  final Widget child;
  final Widget? header;

  @override
  Widget build(BuildContext context) => BarStrip(child: _body(context));

  Widget _body(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: ColoredBox(
      color: KeelColors.raised.of(context),
      // Clear of a side strip, such as the iPhone Duo's camera and status
      // cluster, which nothing else keeps the form out of inside a sheet.
      child: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: measure),
            child: Column(
              children: [
                // The body runs under the bar; start below it.
                SizedBox(height: MediaQuery.paddingOf(context).top),
                ?header,
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
