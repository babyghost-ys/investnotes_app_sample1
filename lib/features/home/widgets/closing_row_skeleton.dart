import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:investnotes_app_sample1/features/home/widgets/closing_card_skeleton.dart';

/// Home's row of offerings about to close, while they load.
class ClosingRowSkeleton extends StatelessWidget {
  const ClosingRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        ClosingCardSkeleton(),
        SizedBox(width: 12),
        ClosingCardSkeleton(),
        SizedBox(width: 12),
        ClosingCardSkeleton(),
      ],
    ),
  );
}
