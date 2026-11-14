import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../core/native_style.dart';
import '../../style/sf_symbol.dart';
import 'uikit_button.dart';

/// A native button that renders platform-specific button styles
///
/// On iOS: Uses the running system’s native UIButton.
/// On Android: Uses Material Design button (ElevatedButton or TextButton)
///
/// Example:
/// ```dart
/// NativeButton(
///   onPressed: () {
///     print('Button pressed');
///   },
///   label: 'Click Me',
/// )
/// ```
class NativeButton extends StatelessWidget {
  /// Creates a native button with a text label
  const NativeButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.color,
    this.textColor,
    this.style = NativeButtonStyle.filled,
    this.size = NativeButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.enabled = true,
    this.useSmoothRectangleBorder = true,
  }) : child = null,
       icon = null,
       iconColor = null,
       sfSymbol = null;

  /// Creates a native button with a custom child widget
  const NativeButton.child({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.style = NativeButtonStyle.filled,
    this.size = NativeButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.enabled = true,
    this.useSmoothRectangleBorder = true,
  }) : label = null,
       textColor = null,
       icon = null,
       iconColor = null,
       sfSymbol = null;

  /// Creates a native button with an icon
  const NativeButton.icon({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.iconColor,
    this.style = NativeButtonStyle.filled,
    this.size = NativeButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.enabled = true,
    this.useSmoothRectangleBorder = true,
  }) : label = null,
       textColor = null,
       child = null,
       sfSymbol = null;

  /// Creates a native button with a native SF Symbol icon (iOS only)
  const NativeButton.sfSymbol({
    super.key,
    required this.onPressed,
    required this.sfSymbol,
    this.color,
    this.style = NativeButtonStyle.glass,
    this.size = NativeButtonSize.medium,
    this.padding,
    this.borderRadius,
    this.minSize,
    this.enabled = true,
    this.useSmoothRectangleBorder = true,
  }) : label = null,
       textColor = null,
       child = null,
       icon = null,
       iconColor = null;

  /// The callback that is called when the button is tapped
  final VoidCallback? onPressed;

  /// The text label of the button (used in default constructor)
  final String? label;

  /// The widget below this widget in the tree (used in .child constructor)
  final Widget? child;

  /// The icon to display (used in .icon constructor)
  final IconData? icon;

  /// The SF Symbol to display (used in .sfSymbol constructor)
  final SFSymbol? sfSymbol;

  /// The color of the button
  ///
  /// On iOS: Uses iOS system colors
  /// On Android: Uses Material theme colors
  final Color? color;

  /// The color of the button text (only for label mode)
  final Color? textColor;

  /// The color of the icon (only for icon mode)
  final Color? iconColor;

  /// The visual style of the button
  final NativeButtonStyle style;

  /// The size preset for the button
  final NativeButtonSize size;

  /// The amount of space to surround the child inside the button
  final EdgeInsetsGeometry? padding;

  /// The border radius of the button
  final BorderRadius? borderRadius;

  /// The minimum size of the button
  final Size? minSize;

  /// Whether the button is enabled
  final bool enabled;

  /// Whether to use smooth rectangle border (iOS 26+ only)
  /// When false, uses perfectly circular/capsule shape
  /// Default is true for smooth rectangle, set to false for circular
  final bool useSmoothRectangleBorder;

  @override
  Widget build(BuildContext context) {
    switch (NativeStyle.of(context)) {
      case NativeStyle.native:
        // UIKit chooses the appearance for the running iOS release.
        // Unset, UIKit would fall back to system blue whatever the app's accent.
        final tint =
            color ??
            CupertinoDynamicColor.resolve(
              CupertinoTheme.of(context).primaryColor,
              context,
            );
        // SF Symbol mode - use native SF Symbol rendering
        if (sfSymbol != null) {
          return _wrapIOSButton(
            UiKitButton.sfSymbol(
              onPressed: onPressed,
              sfSymbol: sfSymbol!,
              style: _mapToIOS26Style(style),
              size: _mapToIOS26Size(size),
              color: tint,
              enabled: enabled,
              padding: padding,
              borderRadius: borderRadius,
              minSize: minSize,
              useSmoothRectangleBorder: useSmoothRectangleBorder,
            ),
          );
        }

        // Child mode - overlay widget on native button
        if (child != null) {
          return _wrapIOSButton(
            UiKitButton.child(
              onPressed: onPressed,
              style: _mapToIOS26Style(style),
              size: _mapToIOS26Size(size),
              color: tint,
              enabled: enabled,
              padding: padding,
              borderRadius: borderRadius,
              minSize: minSize,
              useSmoothRectangleBorder: useSmoothRectangleBorder,
              child: child!,
            ),
          );
        }

        // Icon mode - use child mode with Icon widget
        if (icon != null) {
          return _wrapIOSButton(
            UiKitButton.child(
              onPressed: onPressed,
              style: _mapToIOS26Style(style),
              size: _mapToIOS26Size(size),
              color: tint,
              enabled: enabled,
              padding: padding,
              borderRadius: borderRadius,
              minSize: minSize,
              useSmoothRectangleBorder: useSmoothRectangleBorder,
              child: Icon(icon, color: iconColor, size: 24),
            ),
          );
        }

        // Label mode
        return _wrapIOSButton(
          UiKitButton(
            onPressed: onPressed,
            label: label!,
            textColor: textColor,
            style: _mapToIOS26Style(style),
            size: _mapToIOS26Size(size),
            color: tint,
            enabled: enabled,
            padding: padding,
            borderRadius: borderRadius,
            minSize: minSize,
            useSmoothRectangleBorder: useSmoothRectangleBorder,
          ),
        );
      case NativeStyle.material:
        // Android - Use Material Design button
        return _buildMaterialButton(context);
    }
  }

  // Wrap iOS buttons to prevent infinite width in Row/Flex
  Widget _wrapIOSButton(Widget button) {
    // Apply minSize constraint if provided
    if (minSize != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize!.width,
          minHeight: minSize!.height,
        ),
        child: button,
      );
    }

    // No wrapper - button sizes itself to content
    // User must wrap with Flexible in Row if needed
    return button;
  }

  Widget _buildMaterialButton(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;

    // Build child widget based on mode
    Widget buttonChild;
    if (sfSymbol != null) {
      // SF Symbol fallback - use Material Icons
      buttonChild = Icon(
        Icons.circle, // Default fallback icon
        color: sfSymbol!.color,
        size: sfSymbol!.size,
      );
    } else if (icon != null) {
      buttonChild = Icon(icon, color: iconColor);
    } else if (child != null) {
      buttonChild = child!;
    } else {
      buttonChild = Text(label ?? '');
    }

    switch (style) {
      case NativeButtonStyle.filled:
        // Use theme's ElevatedButton style and only override explicitly provided values
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // null = use theme
            foregroundColor: textColor, // null = use theme
            padding: padding, // null = use theme
            minimumSize: minSize, // null = use theme
            shape: borderRadius != null
                ? RoundedRectangleBorder(borderRadius: borderRadius!)
                : null, // null = use theme
          ),
          child: buttonChild,
        );

      case NativeButtonStyle.tinted:
        return FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color?.withValues(alpha: 0.15),
            foregroundColor: textColor ?? color,
            padding: padding,
            minimumSize: minSize,
            shape: borderRadius != null
                ? RoundedRectangleBorder(borderRadius: borderRadius!)
                : null,
          ),
          child: buttonChild,
        );

      case NativeButtonStyle.bordered:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? color,
            side: color != null ? BorderSide(color: color!) : null,
            padding: padding,
            minimumSize: minSize,
            shape: borderRadius != null
                ? RoundedRectangleBorder(borderRadius: borderRadius!)
                : null,
          ),
          child: buttonChild,
        );

      case NativeButtonStyle.plain:
        // Explicitly use primary color if no color is provided
        final effectiveColor =
            color ?? textColor ?? Theme.of(context).colorScheme.primary;
        return TextButton(
          onPressed: effectiveOnPressed,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(effectiveColor),
            padding: padding != null ? WidgetStateProperty.all(padding) : null,
            minimumSize: minSize != null
                ? WidgetStateProperty.all(minSize)
                : null,
            shape: borderRadius != null
                ? WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: borderRadius!),
                  )
                : null,
          ),
          child: buttonChild,
        );

      case NativeButtonStyle.gray:
        // Material doesn't have a direct "gray" style, use filled button with gray color
        // Use theme-aware gray colors
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: isDark
                ? Colors.grey.shade800
                : Colors.grey.shade300,
            foregroundColor: isDark
                ? Colors.grey.shade300
                : Colors.grey.shade800,
            padding: padding ?? _getDefaultPadding(),
            minimumSize: minSize ?? Size.zero,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8.0),
            ),
          ),
          child: buttonChild,
        );

      case NativeButtonStyle.glass:
      case NativeButtonStyle.prominentGlass:
        // Material doesn't have glass effects, fallback to tinted style
        return FilledButton.tonal(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: color?.withValues(alpha: 0.15),
            foregroundColor: textColor ?? color,
            padding: padding,
            minimumSize: minSize,
            shape: borderRadius != null
                ? RoundedRectangleBorder(borderRadius: borderRadius!)
                : null,
          ),
          child: buttonChild,
        );
    }
  }

  UiKitButtonStyle _mapToIOS26Style(NativeButtonStyle style) {
    switch (style) {
      case NativeButtonStyle.filled:
        return UiKitButtonStyle.filled;
      case NativeButtonStyle.tinted:
        return UiKitButtonStyle.tinted;
      case NativeButtonStyle.gray:
        return UiKitButtonStyle.gray;
      case NativeButtonStyle.bordered:
        return UiKitButtonStyle.bordered;
      case NativeButtonStyle.plain:
        return UiKitButtonStyle.plain;
      case NativeButtonStyle.glass:
        return UiKitButtonStyle.glass;
      case NativeButtonStyle.prominentGlass:
        return UiKitButtonStyle.prominentGlass;
    }
  }

  UiKitButtonSize _mapToIOS26Size(NativeButtonSize size) {
    switch (size) {
      case NativeButtonSize.small:
        return UiKitButtonSize.small;
      case NativeButtonSize.medium:
        return UiKitButtonSize.medium;
      case NativeButtonSize.large:
        return UiKitButtonSize.large;
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (size) {
      case NativeButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0);
      case NativeButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
      case NativeButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);
    }
  }
}

/// Button style variants that adapt to each platform
enum NativeButtonStyle {
  /// Solid filled button (primary action)
  filled,

  /// Tinted/tonal button with subtle background
  tinted,

  /// Gray button with neutral appearance
  gray,

  /// Outlined/bordered button
  bordered,

  /// Plain text button
  plain,

  /// Glass effect button (iOS 26+ only)
  glass,

  /// Prominent glass button (iOS 26+ only)
  prominentGlass,
}

/// Button size presets
enum NativeButtonSize {
  /// Small button (28pt height on iOS)
  small,

  /// Medium button (36pt height on iOS) - default
  medium,

  /// Large button (44pt height on iOS)
  large,
}
