import 'package:material_ui/material_ui.dart';
import '../../core/native_style.dart';
import 'uikit_switch.dart';

/// A native switch that renders platform-specific switch styles
///
/// On iOS: Uses the running system’s native UISwitch.
/// On Android: Uses Material Design Switch
///
/// Example:
/// ```dart
/// bool _value = false;
///
/// NativeSwitch(
///   value: _value,
///   onChanged: (bool newValue) {
///     setState(() {
///       _value = newValue;
///     });
///   },
/// )
/// ```
class NativeSwitch extends StatelessWidget {
  /// Creates a native switch
  const NativeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.thumbColor,
  });

  /// Whether this switch is on or off
  final bool value;

  /// Called when the user toggles the switch on or off
  ///
  /// The switch passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the switch with the new
  /// value.
  ///
  /// If null, the switch will be displayed as disabled.
  final ValueChanged<bool>? onChanged;

  /// The color to use when this switch is on
  ///
  /// On iOS: Uses the color for the track when on
  /// On Android: Uses the color for the track
  final Color? activeColor;

  /// The color of the thumb (handle)
  ///
  /// On iOS: The color of the circular knob
  /// On Android: The color of the circular knob
  final Color? thumbColor;

  @override
  Widget build(BuildContext context) {
    switch (NativeStyle.of(context)) {
      case NativeStyle.native:
        // iOS 26+ - Use native iOS 26 switch
        return UiKitSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
          thumbColor: thumbColor,
        );
      case NativeStyle.material:
        // Android - Use Material Design Switch
        return Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: thumbColor != null
              ? WidgetStateProperty.all(thumbColor)
              : null,
          trackColor: activeColor != null
              ? WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return activeColor;
                  }
                  return null;
                })
              : null,
        );
    }
  }
}
