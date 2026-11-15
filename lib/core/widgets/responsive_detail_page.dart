import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/widgets/responsive_master_detail.dart';

/// A pushed page that a [ResponsiveMasterDetail] would show in its detail
/// pane in a wider window. When the window becomes wide enough to split
/// (the Duo unfolds) while this page is in front, it closes itself and the
/// item carries on beside its list.
class ResponsiveDetailPage extends StatefulWidget {
  const ResponsiveDetailPage({super.key, required this.child});

  final Widget child;

  @override
  State<ResponsiveDetailPage> createState() => _ResponsiveDetailPageState();
}

class _ResponsiveDetailPageState extends State<ResponsiveDetailPage> {
  bool _closing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_closing || !ResponsiveMasterDetail.isSplit(context)) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !route.isCurrent) {
        _closing = false;
        return;
      }
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
