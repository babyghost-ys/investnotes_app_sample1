import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/features/finder/bloc/finder_bloc.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offering_detail_page.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row.dart';

/// The offerings the answers lead to. When nothing fits every answer, the
/// closest ones, each marked with how much fits.
class FinderResultsPage extends StatelessWidget {
  const FinderResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final matches = context.select<FinderBloc, List<FinderMatch>>(
      (b) => b.state.matches,
    );
    final exact = matches.isNotEmpty && matches.first.exact;
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            insets.top + 18,
            20,
            insets.bottom + 40,
          ),
          children: [
            Row(
              children: [
                Icon(
                  exact
                      ? CupertinoIcons.checkmark_seal_fill
                      : CupertinoIcons.scope,
                  color: KeelColors.azure.of(context),
                  size: 30,
                ),
                const SizedBox(width: 12),
                Text(
                  exact ? '${matches.length} fit' : 'Closest',
                  style: TextStyle(
                    color: KeelColors.ink.of(context),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final m in matches)
              OfferingRow(
                offering: m.offering,
                badge: m.exact ? null : '${m.hits}/${m.of}',
                onTap: () => openOffering(context, m.offering),
              ),
          ],
        ),
      ),
    );
  }
}
