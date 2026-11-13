import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// A text field: a leading icon, the text, an optional trailing control.
class KeelField extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final muted = KeelColors.muted.of(context);
    return CupertinoTextField(
      placeholder: placeholder,
      obscureText: obscure,
      autofocus: autofocus,
      autocorrect: false,
      textInputAction: action,
      autofillHints: autofill == null ? null : [autofill!],
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      cursorColor: KeelColors.azure.of(context),
      style: TextStyle(color: KeelColors.ink.of(context), fontSize: 17),
      placeholderStyle: TextStyle(color: muted, fontSize: 17),
      padding: const EdgeInsets.symmetric(vertical: 17),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: Icon(icon, size: 20, color: muted),
      ),
      suffix: trailing == null
          ? null
          : Padding(padding: const EdgeInsets.only(right: 4), child: trailing),
      decoration: BoxDecoration(
        color: KeelColors.mist.of(context),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
