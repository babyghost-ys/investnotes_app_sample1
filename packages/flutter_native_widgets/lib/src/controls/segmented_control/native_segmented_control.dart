import '../../style/native_icon.dart';
import 'package:material_ui/material_ui.dart';
import '../../core/native_style.dart';
import 'uikit_segmented_control.dart';

/// A native segmented control that renders platform-specific styles
///
/// On iOS: Uses the running system’s native UISegmentedControl.
/// On Android: Uses Material SegmentedButton
class NativeSegmentedControl extends StatelessWidget {
  /// Creates a native segmented control
  const NativeSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onValueChanged,
    this.enabled = true,
    this.color,
    this.height = 36.0,
    this.shrinkWrap = false,
    this.icons,
    this.iconSize,
    this.iconColor,
    this.textColor,
    this.selectedTextColor,
    this.semanticLabels,
  });

  /// Segment labels to display, in order
  final List<String> labels;

  /// The index of the selected segment, or -1 for none
  final int selectedIndex;

  /// Called when the user selects a segment
  final ValueChanged<int> onValueChanged;

  /// Whether the control is interactive
  final bool enabled;

  /// Tint color for the selected segment
  final Color? color;

  /// Height of the control
  final double height;

  /// Whether the control should shrink to fit content
  final bool shrinkWrap;

  /// Optional icons shown instead of [labels]: their SF Symbols on the
  /// native control, their Material icons on the Material one.
  final List<NativeIcon>? icons;

  /// Icon size
  final double? iconSize;

  /// Icon color
  final Color? iconColor;

  /// Optional text color for unselected segments.
  final Color? textColor;

  /// Optional text color for the selected segment.
  final Color? selectedTextColor;

  /// What assistive technologies say for each segment, in order, in place
  /// of its visible label or icon: "System" for a segment that shows
  /// "SYS". Never drawn. Ignored unless it has one entry per segment.
  final List<String>? semanticLabels;

  @override
  Widget build(BuildContext context) {
    return switch (NativeStyle.of(context)) {
      NativeStyle.native => UiKitSegmentedControl(
        labels: labels,
        selectedIndex: selectedIndex,
        onValueChanged: onValueChanged,
        enabled: enabled,
        color: color,
        height: height,
        shrinkWrap: shrinkWrap,
        icons: icons?.map((icon) => icon.sfSymbol ?? '').toList(),
        iconSize: iconSize,
        iconColor: iconColor,
        textColor: textColor,
        selectedTextColor: selectedTextColor,
        semanticLabels: semanticLabels,
      ),
      NativeStyle.material => _buildMaterialSegmentedButton(context),
    };
  }

  Widget _buildMaterialSegmentedButton(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;
    final effectiveSelectedTextColor =
        selectedTextColor ??
        (color != null ? Colors.white : effectiveTextColor);
    final segments = <ButtonSegment<int>>[];

    // Check if using icons
    final icons = this.icons;
    final useIcons = icons != null && icons.isNotEmpty;
    final itemCount = useIcons ? icons.length : labels.length;
    final spoken = semanticLabels?.length == itemCount ? semanticLabels : null;

    for (int i = 0; i < itemCount; i++) {
      if (useIcons) {
        // Icon mode
        segments.add(
          ButtonSegment<int>(
            value: i,
            icon: Icon(
              icons[i].iconData,
              size: iconSize ?? 20,
              color: iconColor,
              semanticLabel: spoken?[i],
            ),
          ),
        );
      } else {
        // Text mode
        segments.add(
          ButtonSegment<int>(
            value: i,
            label: Text(
              labels[i],
              semanticsLabel: spoken?[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selectedIndex == i
                    ? effectiveSelectedTextColor
                    : effectiveTextColor,
              ),
            ),
          ),
        );
      }
    }

    final buttonStyle = SegmentedButton.styleFrom(
      minimumSize: Size.fromHeight(height),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      selectedBackgroundColor: color,
      selectedForegroundColor: selectedTextColor,
      foregroundColor: textColor,
    );

    Widget control = SegmentedButton<int>(
      segments: segments,
      selected: {if (selectedIndex >= 0) selectedIndex},
      emptySelectionAllowed: true,
      // The fill already marks the selection; a checkmark beside the label
      // pushes longer labels onto several lines in narrow segments.
      showSelectedIcon: false,
      onSelectionChanged: enabled
          ? (Set<int> newSelection) {
              if (newSelection.isNotEmpty) {
                onValueChanged(newSelection.first);
              }
            }
          : null,
      style: buttonStyle,
    );

    if (shrinkWrap) {
      control = Center(child: IntrinsicWidth(child: control));
    }

    return control;
  }
}
