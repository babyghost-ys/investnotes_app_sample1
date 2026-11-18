import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_native_widgets/flutter_native_widgets.dart';

import 'package:investnotes_app_sample1/core/widgets/responsive_master_detail.dart';

/// A note's page pushed from a list that splits in a wide window, while the
/// window was a single pane (a folded Duo).
///
/// When the window widens enough to split (the Duo unfolds) while this page
/// is in front, the page hands over to the split, as UIKit's split view does
/// when it expands: [onSplit] chooses its note in the list, so the split
/// already shows it beside the list, and the page leaves the stack in place,
/// with no slide, under the unfold itself.
class SplitDetailPage extends StatefulWidget {
  const SplitDetailPage({
    super.key,
    required this.onSplit,
    required this.child,
  });

  /// Chooses this page's note in its list.
  final VoidCallback onSplit;

  final Widget child;

  @override
  State<SplitDetailPage> createState() => _SplitDetailPageState();
}

class _SplitDetailPageState extends State<SplitDetailPage> {
  bool _handingOver = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handingOver || !ResponsiveMasterDetail.isSplit(context)) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _handingOver = true;
    widget.onSplit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !ResponsiveMasterDetail.isSplit(context) ||
          ModalRoute.of(context)?.isCurrent != true) {
        _handingOver = false;
        return;
      }
      NativeNavigator.popInPlace(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
