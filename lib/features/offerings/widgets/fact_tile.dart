import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';

/// One term of a note: an icon and its value.
class FactTile extends StatelessWidget {
  const FactTile({
    super.key,
    required this.icon,
    required this.value,
    required this.semantics,
  });

  final IconData icon;
  final String value;

  /// Read aloud in place of the bare value.
  final String semantics;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semantics,
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: KeelColors.azure.of(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              style: TextStyle(
                color: KeelColors.ink.of(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
