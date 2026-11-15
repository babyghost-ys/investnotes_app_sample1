import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:keel_localisation/src/localisation_bloc.dart';

/// Tells the [LocalisationBloc] above it when the device's languages
/// change, so an app that follows the device follows it live.
class SystemLocaleListener extends StatefulWidget {
  const SystemLocaleListener({super.key, required this.child});

  final Widget child;

  @override
  State<SystemLocaleListener> createState() => _SystemLocaleListenerState();
}

class _SystemLocaleListenerState extends State<SystemLocaleListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    context.read<LocalisationBloc>().add(
      LocalisationSystemLocalesChanged(locales ?? const []),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
