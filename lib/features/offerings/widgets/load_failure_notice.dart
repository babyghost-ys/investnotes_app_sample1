import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/widgets/error_snack_bar.dart';
import 'package:investnotes_app_sample1/data/models/load_status.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';

/// Says so with an [ErrorSnackBar] when the offerings fail to load, while
/// this tab is on screen: when it comes into view while they are failing,
/// and on each failed attempt the person asked for. Quiet retries say
/// nothing; a load that succeeds puts the snack bar away.
class LoadFailureNotice extends StatefulWidget {
  const LoadFailureNotice({super.key, required this.child});

  final Widget child;

  @override
  State<LoadFailureNotice> createState() => _LoadFailureNoticeState();
}

class _LoadFailureNoticeState extends State<LoadFailureNotice> {
  static const _message = 'Offerings didn’t load';

  /// Whether this tab was on screen at the last check.
  bool _onScreen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Tab containers hide a page with tickers off, or keep its tickers and
    // hide it with Visibility; either means it is not on screen.
    final onScreen =
        TickerMode.valuesOf(context).enabled && Visibility.of(context);
    if (onScreen && !_onScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_onScreen) return;
        if (context.read<OfferingsBloc>().state.status == LoadStatus.failed) {
          ErrorSnackBar.show(context, _message);
        }
      });
    }
    _onScreen = onScreen;
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<OfferingsBloc, OfferingsState>(
        listenWhen: (before, now) => before.status != now.status,
        listener: (context, state) => switch (state.status) {
          LoadStatus.failed when _onScreen => ErrorSnackBar.show(
            context,
            _message,
          ),
          LoadStatus.ready => ErrorSnackBar.hide(),
          _ => null,
        },
        child: widget.child,
      );
}
