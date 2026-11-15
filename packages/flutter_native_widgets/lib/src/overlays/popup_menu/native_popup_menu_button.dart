import '../../style/native_icon.dart';
import 'package:material_ui/material_ui.dart';
import '../../core/native_style.dart';
import '../action_sheet/native_action_sheet.dart';
import 'uikit_popup_menu_button.dart';

export 'uikit_popup_menu_button.dart'
    show
        NativePopupMenuItem,
        NativePopupMenuDivider,
        NativePopupMenuEntry,
        PopupButtonStyle;

/// A native popup menu button that renders platform-specific styles
class NativePopupMenuButton<T> {
  NativePopupMenuButton._();

  /// Creates a text-labeled popup menu button
  static Widget text<T>({
    Key? key,
    required String label,
    required List<NativePopupMenuEntry> items,
    required void Function(int index, NativePopupMenuItem<T> entry) onSelected,
    Color? tint,
    double height = 32.0,
    bool shrinkWrap = false,
    PopupButtonStyle buttonStyle = PopupButtonStyle.plain,
  }) {
    return Builder(
      key: key,
      builder: (context) => switch (NativeStyle.of(context)) {
        NativeStyle.native => UiKitPopupMenuButton<T>(
          buttonLabel: label,
          items: items,
          onSelected: onSelected,
          tint: tint,
          height: height,
          shrinkWrap: shrinkWrap,
          buttonStyle: buttonStyle,
        ),
        NativeStyle.material => _MaterialPopupMenuButton<T>(
          label: label,
          items: items,
          onSelected: onSelected,
          tint: tint,
          height: height,
        ),
      },
    );
  }

  /// Creates a popup menu button with a custom child widget
  static Widget widget<T>({
    Key? key,
    required List<NativePopupMenuEntry> items,
    required void Function(int index, NativePopupMenuItem<T> entry) onSelected,
    Color? tint,
    PopupButtonStyle buttonStyle = PopupButtonStyle.plain,
    bool triggerOnLongPress = false,
    VoidCallback? onTap,
    required Widget child,
  }) {
    assert(
      onTap == null || triggerOnLongPress,
      'onTap is only used with triggerOnLongPress: true (tap fires onTap, '
      'long-press opens the menu).',
    );
    return Builder(
      key: key,
      builder: (context) => switch (NativeStyle.of(context)) {
        NativeStyle.native => UiKitPopupMenuButton<T>.widget(
          items: items,
          onSelected: onSelected,
          tint: tint,
          buttonStyle: buttonStyle,
          triggerOnLongPress: triggerOnLongPress,
          onTap: onTap,
          child: child,
        ),
        NativeStyle.material => _MaterialPopupMenuButton<T>.widget(
          items: items,
          onSelected: onSelected,
          tint: tint,
          child: child,
        ),
      },
    );
  }

  /// Creates a round, icon-only popup menu button
  ///
  /// [icon] shows its SF Symbol on the native button and its Material icon
  /// on the Material one.
  /// [iconSize] is the glyph's point size on every platform; the button
  /// itself stays [size] wide and tall.
  static Widget icon<T>({
    Key? key,
    required NativeIcon icon,
    required List<NativePopupMenuEntry> items,
    required void Function(int index, NativePopupMenuItem<T> entry) onSelected,
    Color? tint,
    double size = 44.0,
    double? iconSize,
    PopupButtonStyle buttonStyle = PopupButtonStyle.glass,
  }) {
    return Builder(
      key: key,
      builder: (context) => switch (NativeStyle.of(context)) {
        NativeStyle.native => UiKitPopupMenuButton<T>.icon(
          buttonIcon: icon.sfSymbol ?? 'ellipsis.circle',
          items: items,
          onSelected: onSelected,
          tint: tint,
          size: size,
          iconSize: iconSize,
          buttonStyle: buttonStyle,
        ),
        NativeStyle.material => _MaterialPopupMenuButton<T>.icon(
          icon: icon,
          items: items,
          onSelected: onSelected,
          tint: tint,
          size: size,
          iconSize: iconSize,
        ),
      },
    );
  }

  /// Opens [items] for a button drawn elsewhere, such as an app bar action:
  /// an action sheet on iOS, a popup menu at [context]'s button otherwise.
  /// Buttons above the navigator pass the page's [navigator].
  static Future<void> show<T>(
    BuildContext context, {
    required List<NativePopupMenuEntry> items,
    required void Function(int index, NativePopupMenuItem<T> entry) onSelected,
    NavigatorState? navigator,
  }) async {
    final menuContext =
        (navigator ?? Navigator.maybeOf(context))?.overlay?.context;
    if (menuContext == null) return;
    if (NativeStyle.of(context) == NativeStyle.native) {
      return _showActionSheet<T>(menuContext, items, onSelected);
    }
    final button = context.findRenderObject() as RenderBox?;
    final overlay = menuContext.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;
    // Global coordinates, as the button may sit in a bar above the navigator
    final topLeft = overlay.globalToLocal(button.localToGlobal(Offset.zero));
    final selected = await showMenu<int>(
      context: menuContext,
      position: RelativeRect.fromRect(
        topLeft & button.size,
        Offset.zero & overlay.size,
      ),
      items: _materialMenuItems<T>(menuContext, items),
    );
    if (selected != null && items[selected] is NativePopupMenuItem<T>) {
      onSelected(selected, items[selected] as NativePopupMenuItem<T>);
    }
  }

  static List<PopupMenuEntry<int>> _materialMenuItems<T>(
    BuildContext context,
    List<NativePopupMenuEntry> items,
  ) {
    final menuItems = <PopupMenuEntry<int>>[];

    for (var i = 0; i < items.length; i++) {
      if (items[i] is NativePopupMenuDivider) {
        menuItems.addAll(_materialDivider(context, items[i], i));
      } else if (items[i] is NativePopupMenuItem<T>) {
        final item = items[i] as NativePopupMenuItem<T>;
        final labelStyle = item.isDestructive
            ? TextStyle(color: Theme.of(context).colorScheme.error)
            : null;
        final hasSubtitle = item.subtitle != null && item.subtitle!.isNotEmpty;
        menuItems.add(
          PopupMenuItem<int>(
            value: i,
            enabled: item.enabled,
            child: Row(
              children: [
                if (item.imageBytes != null) ...[
                  ClipOval(
                    child: Image.memory(
                      item.imageBytes!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (item.icon != null) ...[
                  Icon(
                    item.icon!.iconData,
                    size: 20,
                    color: item.isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: hasSubtitle
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.label, style: labelStyle),
                            Text(
                              item.subtitle!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        )
                      : Text(item.label, style: labelStyle),
                ),
                if (item.selected) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.check,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }
    return menuItems;
  }

  /// The menu as the running system's action sheet.
  static Future<void> _showActionSheet<T>(
    BuildContext context,
    List<NativePopupMenuEntry> items,
    void Function(int index, NativePopupMenuItem<T> entry) onSelected,
  ) async {
    final entries = <int>[
      for (var i = 0; i < items.length; i++)
        if (items[i] is NativePopupMenuItem<T> &&
            (items[i] as NativePopupMenuItem<T>).enabled)
          i,
    ];
    final selected = await NativeActionSheet.show(
      anchorContext: context,
      actions: [
        for (final i in entries)
          NativeSheetAction(
            (items[i] as NativePopupMenuItem<T>).label,
            destructive: (items[i] as NativePopupMenuItem<T>).isDestructive,
          ),
      ],
    );
    if (selected != null) {
      final index = entries[selected];
      onSelected(index, items[index] as NativePopupMenuItem<T>);
    }
  }

  static List<PopupMenuEntry<int>> _materialDivider(
    BuildContext context,
    NativePopupMenuEntry entry,
    int index,
  ) {
    final title = entry is NativePopupMenuDivider ? entry.title : null;
    return [
      if (index > 0) const PopupMenuDivider(),
      if (title != null && title.isNotEmpty)
        PopupMenuItem<int>(
          enabled: false,
          height: 32,
          child: Text(title, style: Theme.of(context).textTheme.labelMedium),
        ),
    ];
  }
}

/// Material implementation of popup menu button for Android
class _MaterialPopupMenuButton<T> extends StatefulWidget {
  const _MaterialPopupMenuButton({
    required this.label,
    required this.items,
    required this.onSelected,
    this.tint,
    this.height = 32.0,
  }) : icon = null,
       size = null,
       iconSize = null,
       child = null;

  const _MaterialPopupMenuButton.icon({
    required this.icon,
    required this.items,
    required this.onSelected,
    this.tint,
    this.size = 44.0,
    this.iconSize,
  }) : label = null,
       height = null,
       child = null;

  const _MaterialPopupMenuButton.widget({
    required this.items,
    required this.onSelected,
    this.tint,
    required this.child,
  }) : label = null,
       icon = null,
       height = null,
       size = null,
       iconSize = null;

  final String? label;
  final NativeIcon? icon;
  final Widget? child;
  final List<NativePopupMenuEntry> items;
  final void Function(int index, NativePopupMenuItem<T> entry) onSelected;
  final Color? tint;
  final double? height;
  final double? size;
  final double? iconSize;

  bool get isIconButton => icon != null;
  bool get isCustomWidget => child != null;

  @override
  State<_MaterialPopupMenuButton<T>> createState() =>
      _MaterialPopupMenuButtonState<T>();
}

class _MaterialPopupMenuButtonState<T>
    extends State<_MaterialPopupMenuButton<T>> {
  @override
  Widget build(BuildContext context) {
    final menuItems = NativePopupMenuButton._materialMenuItems<T>(
      context,
      widget.items,
    );

    // Custom widget case
    if (widget.isCustomWidget) {
      return PopupMenuButton<int>(
        child: widget.child!,
        itemBuilder: (context) => menuItems,
        onSelected: (index) {
          final selectedEntry = widget.items[index];
          if (selectedEntry is NativePopupMenuItem<T>) {
            widget.onSelected(index, selectedEntry);
          }
        },
      );
    }

    if (widget.isIconButton) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: PopupMenuButton<int>(
          icon: Icon(
            widget.icon?.icon ?? Icons.more_vert,
            color: widget.tint,
            size: widget.iconSize,
          ),
          itemBuilder: (context) => menuItems,
          onSelected: (index) {
            final selectedEntry = widget.items[index];
            if (selectedEntry is NativePopupMenuItem<T>) {
              widget.onSelected(index, selectedEntry);
            }
          },
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: TextButton(
        onPressed: () {},
        child: PopupMenuButton<int>(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label ?? ''),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
          itemBuilder: (context) => menuItems,
          onSelected: (index) {
            final selectedEntry = widget.items[index];
            if (selectedEntry is NativePopupMenuItem<T>) {
              widget.onSelected(index, selectedEntry);
            }
          },
        ),
      ),
    );
  }
}
