import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A text field: a leading icon, the text, an optional trailing control.
///
/// Without a [controller] it keeps its own, starting from [initialValue], so
/// a step that comes back shows what was typed before.
class KeelField extends StatefulWidget {
  const KeelField({
    super.key,
    required this.icon,
    required this.placeholder,
    required this.onChanged,
    this.obscure = false,
    this.autofocus = false,
    this.action = TextInputAction.next,
    this.autofill,
    this.onSubmitted,
    this.trailing,
    this.controller,
    this.focusNode,
    this.keyboard,
    this.initialValue = '',
  });

  final IconData icon;
  final String placeholder;
  final ValueChanged<String> onChanged;
  final bool obscure;
  final bool autofocus;
  final TextInputAction action;
  final String? autofill;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboard;
  final String initialValue;

  @override
  State<KeelField> createState() => _KeelFieldState();
}

class _KeelFieldState extends State<KeelField> {
  TextEditingController? _own;

  TextEditingController get _controller =>
      widget.controller ??
      (_own ??= TextEditingController(text: widget.initialValue));

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = KeelColors.muted.of(context);
    final trailing = widget.trailing;
    // The placeholder names the field; it stays its name once typed in.
    return MergeSemantics(
      child: Semantics(
        label: widget.placeholder,
        child: CupertinoTextField(
          controller: _controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboard,
          placeholder: widget.placeholder,
          obscureText: widget.obscure,
          autofocus: widget.autofocus,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: widget.action,
          autofillHints: widget.autofill == null ? null : [widget.autofill!],
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          cursorColor: KeelColors.azure.of(context),
          style: TextStyle(color: KeelColors.ink.of(context), fontSize: 17),
          placeholderStyle: TextStyle(color: muted, fontSize: 17),
          padding: const EdgeInsets.symmetric(vertical: 17),
          prefix: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: ExcludeSemantics(
              child: Icon(widget.icon, size: 20, color: muted),
            ),
          ),
          suffix: trailing == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: trailing,
                ),
          decoration: BoxDecoration(
            color: KeelColors.mist.of(context),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
