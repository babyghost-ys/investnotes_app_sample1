import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// An icon and at most a few words, for a list with nothing in it.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    this.text,
    this.action,
    this.semanticLabel,
  });

  final IconData icon;
  final String? text;
  final Widget? action;

  /// What assistive technologies say for the icon when there is no [text],
  /// such as "Nothing saved". Never drawn.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final muted = KeelColors.muted.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          // Announced as it appears, after a filter or a search.
          Semantics(
            liveRegion: true,
            label: text ?? semanticLabel,
            excludeSemantics: true,
            child: Column(
              children: [
                Icon(icon, size: 44, color: muted.withValues(alpha: 0.6)),
                if (text != null) ...[
                  const SizedBox(height: 12),
                  Text(text!, style: TextStyle(color: muted, fontSize: 16)),
                ],
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
