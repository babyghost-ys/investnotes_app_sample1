import 'package:cupertino_ui/cupertino_ui.dart';

/// A short line of text that opens somewhere else, with a full-size target.
class TextLink extends StatelessWidget {
  const TextLink({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.weight = FontWeight.w500,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    minimumSize: const Size(44, 44),
    onPressed: onPressed,
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 15, fontWeight: weight),
    ),
  );
}
