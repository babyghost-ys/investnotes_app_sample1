import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../core/native_style.dart';

/// An action in a source-anchored native action sheet.
class NativeSheetAction {
  const NativeSheetAction(this.title, {this.destructive = false});
  final String title;
  final bool destructive;
}

/// UIKit owns the material, source animation and dismissal on iOS.
class NativeActionSheet {
  NativeActionSheet._();
  static const _channel = MethodChannel('flutter_native_widgets/action_sheet');

  /// Pass the context of the actual button/row, typically from a [Builder].
  /// Returns the selected action index, or null when dismissed.
  static Future<int?> show({
    required BuildContext anchorContext,
    String? title,
    String? message,
    required List<NativeSheetAction> actions,
  }) async {
    if (actions.isEmpty) return null;
    switch (NativeStyle.of(anchorContext)) {
      case NativeStyle.native:
        final box = anchorContext.findRenderObject();
        if (box is! RenderBox || !box.attached || !box.hasSize) return null;
        final rect = box.localToGlobal(Offset.zero) & box.size;
        final view = View.of(anchorContext);
        final size = view.physicalSize / view.devicePixelRatio;
        try {
          return await _channel.invokeMethod<int>('show', {
            'title': title,
            'message': message,
            'actions': [
              for (final action in actions)
                {'title': action.title, 'destructive': action.destructive},
            ],
            'x': rect.left / size.width,
            'y': rect.top / size.height,
            'width': rect.width / size.width,
            'height': rect.height / size.height,
          });
        } on PlatformException {
          // Another sheet is already open, or there is no visible view to
          // anchor to. Report it like a dismissal rather than throwing.
          return null;
        }
      case NativeStyle.material:
        return showModalBottomSheet<int>(
          context: anchorContext,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ListTile(title: Text(title)),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(message),
                  ),
                for (var index = 0; index < actions.length; index++)
                  ListTile(
                    title: Text(
                      actions[index].title,
                      style: TextStyle(
                        color: actions[index].destructive
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, index),
                  ),
              ],
            ),
          ),
        );
    }
  }
}
