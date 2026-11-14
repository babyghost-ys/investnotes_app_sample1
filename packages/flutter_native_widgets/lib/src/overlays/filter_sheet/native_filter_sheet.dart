import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../../core/native_style.dart';
import '../../style/native_icon.dart';
import 'material_filter_sheet.dart';

/// How a group of options is laid out in an [NativeFilterSheet].
enum NativeFilterLayout {
  /// A native segmented control. Single choice only.
  segmented,

  /// A grid of square-cornered blocks, an icon over a word.
  blocks,

  /// Tall full-width bands, one above another, the chosen one ticked.
  stack,

  /// Wrapping pill chips.
  chips,

  /// One horizontally scrolling line of pill chips.
  strip,

  /// Wrapping coloured discs labelled with the option title.
  swatches,
}

/// How tall a filter sheet rests.
enum NativeFilterDetents {
  /// Half height, draggable to full height.
  halfAndFull,

  /// Full height only.
  full,

  /// A short sheet that fits a single control.
  short,

  /// Follows the height of its content, up to full height when the content is
  /// taller, and cannot be dragged taller than that. Only
  /// [NativeSheet] measures content; elsewhere it rests at half
  /// height.
  fit,
}

/// One choice in an [NativeFilterChoices].
class NativeFilterOption {
  const NativeFilterOption(this.id, this.title, {this.icon, this.tint});
  final String id;
  final String title;

  /// Drawn as an SF Symbol on iOS and a Material icon elsewhere.
  final NativeIcon? icon;

  /// Colour of the chosen state. Defaults to the sheet's tint.
  final Color? tint;
}

/// A control in an [NativeFilterSheet]. Its value is keyed by [id] in the
/// sheet's values: a `List<String>` of chosen option ids for
/// [NativeFilterChoices], a `double` for [NativeFilterSlider].
sealed class NativeFilterControl {
  const NativeFilterControl(this.id, {this.icon});
  final String id;

  /// Icon that names the control.
  final NativeIcon? icon;

  Map<String, Object?> _encode();
}

class NativeFilterChoices extends NativeFilterControl {
  const NativeFilterChoices(
    super.id,
    this.options, {
    super.icon,
    this.layout = NativeFilterLayout.chips,
    this.multiple = false,
    this.columns = 3,
  });
  final List<NativeFilterOption> options;
  final NativeFilterLayout layout;
  final bool multiple;

  /// Columns of an [NativeFilterLayout.blocks] grid.
  final int columns;

  @override
  Map<String, Object?> _encode() => {
    'type': 'choices',
    'id': id,
    'symbol': icon?.sfSymbol,
    'layout': layout.name,
    'multiple': multiple,
    'columns': columns,
    'options': [
      for (final o in options)
        {
          'id': o.id,
          'title': o.title,
          'symbol': o.icon?.sfSymbol,
          'tint': o.tint?.toARGB32(),
        },
    ],
  };
}

class NativeFilterSlider extends NativeFilterControl {
  const NativeFilterSlider(
    super.id, {
    super.icon,
    required this.min,
    required this.max,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.anyLabel,
    this.anyAtMin = true,
  });
  final double min, max;

  /// Text around the number in the live readout.
  final String prefix, suffix;
  final int decimals;

  /// Readout shown instead of a number when the slider rests at its
  /// unrestricted end, [min] when [anyAtMin], otherwise [max].
  final String? anyLabel;
  final bool anyAtMin;

  @override
  Map<String, Object?> _encode() => {
    'type': 'slider',
    'id': id,
    'symbol': icon?.sfSymbol,
    'min': min,
    'max': max,
    'prefix': prefix,
    'suffix': suffix,
    'decimals': decimals,
    'anyLabel': anyLabel,
    'anyAtMin': anyAtMin,
  };
}

/// A real UIKit sheet (`UISheetPresentationController`) of filter controls.
///
/// It floats above the whole window, so it covers native navigation and tab
/// bars. The caller describes the controls; UIKit draws them, and the sheet
/// asks [count] after every change so its apply button shows how many
/// results the current choices give.
///
/// Where [NativeStyle] is material the same controls draw in a Material
/// bottom sheet that rests at the same heights.
class NativeFilterSheet {
  NativeFilterSheet._();
  static const _channel = MethodChannel('flutter_native_widgets/filter_sheet');

  /// Whether the sheet is a native UIKit sheet for [context]. Elsewhere it is
  /// a Material bottom sheet with the same controls.
  static bool isNative(BuildContext context) =>
      NativeStyle.of(context) == NativeStyle.native;

  /// Shows the sheet and returns the chosen values, or null when it is
  /// dismissed without applying.
  ///
  /// [values] and [cleared] map each control id to its value: the current
  /// choice, and what the reset button restores.
  static Future<Map<String, Object>?> show({
    required BuildContext context,
    required List<NativeFilterControl> controls,
    required Map<String, Object> values,
    required Map<String, Object> cleared,
    required int Function(Map<String, Object> values) count,
    String title = '',
    Color? tint,
    NativeFilterDetents detents = NativeFilterDetents.halfAndFull,
  }) async {
    if (!isNative(context)) {
      return showMaterialFilterSheet(
        context: context,
        title: title,
        tint: tint,
        detents: detents,
        controls: controls,
        values: values,
        cleared: cleared,
        count: count,
      );
    }
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'changed') return null;
      return count(_decode(call.arguments));
    });
    try {
      final result = await _channel.invokeMapMethod<String, Object?>('show', {
        'title': title,
        'tint': tint?.toARGB32(),
        'detents': detents.name,
        'controls': [for (final c in controls) c._encode()],
        'values': values,
        'cleared': cleared,
        'count': count(values),
      });
      return result == null ? null : _decode(result);
    } on PlatformException {
      return null;
    } finally {
      _channel.setMethodCallHandler(null);
    }
  }

  static Map<String, Object> _decode(Object? raw) => {
    for (final entry in (raw as Map).entries)
      entry.key as String: switch (entry.value) {
        final List<Object?> list => [for (final v in list) v as String],
        final num number => number.toDouble(),
        _ => entry.value!,
      },
  };
}
