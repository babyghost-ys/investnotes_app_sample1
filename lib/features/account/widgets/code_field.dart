import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// Six boxes for an emailed code. One hidden field takes the typing, the
/// paste and the code the keyboard offers from Mail; the boxes show it.
class CodeField extends StatefulWidget implements LocalisationConsumer {
  @override
  List<String> get namespaces => const [Locales.account];

  const CodeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onCompleted,
  });

  static const length = 6;

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCompleted;

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    // The step before still holds focus while it fades out, so `autofocus`
    // would lose to it; take focus once the switch has settled.
    Future<void>.delayed(const Duration(milliseconds: 320), () {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void didUpdateWidget(CodeField old) {
    super.didUpdateWidget(old);
    // A resent code clears what was typed.
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: widget,
    builder: (context, locale) => _build(context, locale[0] as AccountLocale),
  );

  Widget _build(BuildContext context, AccountLocale account) {
    final value = widget.value;
    final active = _focus.hasFocus
        ? value.length.clamp(0, CodeField.length - 1)
        : -1;
    final azure = KeelColors.azure.of(context);
    // The boxes draw the digits; the field underneath says them once.
    return Semantics(
      label: account.semantics.code,
      child: SizedBox(
        height: 60,
        child: Stack(
          children: [
            ExcludeSemantics(
              child: Row(
                children: [
                  for (var i = 0; i < CodeField.length; i++) ...[
                    if (i > 0) SizedBox(width: i == 3 ? 16 : 8),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: KeelColors.mist.of(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            width: 2,
                            color: i == active
                                ? azure
                                : const Color(0x00000000),
                          ),
                        ),
                        child: Text(
                          i < value.length ? value[i] : '',
                          style: TextStyle(
                            color: KeelColors.ink.of(context),
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned.fill(
              child: CupertinoTextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(CodeField.length),
                ],
                autocorrect: false,
                enableSuggestions: false,
                showCursor: false,
                enableInteractiveSelection: false,
                style: const TextStyle(color: Color(0x00000000)),
                decoration: null,
                onChanged: (text) {
                  widget.onChanged(text);
                  if (text.length == CodeField.length) {
                    widget.onCompleted?.call();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
