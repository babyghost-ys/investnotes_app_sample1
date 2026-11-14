import 'package:flutter/foundation.dart';

/// Native iPhone search-tab behavior for NativeBottomNavigationBar.
///
/// Add one destination with isSearch: true and supply its results as the
/// scaffold body when selected. iOS 26+ owns the search transition, keyboard,
/// and return to the previous tab when cancelled.
class NativeTabSearch {
  const NativeTabSearch({
    required this.onChanged,
    this.placeholder = 'Search',
    this.onSubmitted,
  });

  final String placeholder;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
}
