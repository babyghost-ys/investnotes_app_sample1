import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/features/my_notes/bloc/my_notes_bloc.dart';
import 'package:investnotes_app_sample1/features/my_notes/widgets/holding_row.dart';
import 'package:investnotes_app_sample1/features/my_notes/widgets/holdings_total.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';

/// The signed-in investor's own notes: their worth today, how it splits,
/// and each note, opening to its page.
class MyNotesPage extends StatelessWidget implements LocalisationConsumer {
  const MyNotesPage({super.key});

  @override
  List<String> get namespaces => const [Locales.myNotes];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) => _build(context, locale[0] as MyNotesLocale),
  );

  Widget _build(BuildContext context, MyNotesLocale myNotes) {
    final state = context.watch<MyNotesBloc>().state;
    final insets = MediaQuery.paddingOf(context);
    final holdings = state.holdings;
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            insets.top + 20,
            20,
            insets.bottom + 40,
          ),
          children: [
            if (holdings.isEmpty)
              EmptyState(
                icon: CupertinoIcons.briefcase,
                semanticLabel: myNotes.semantics.noNotes,
              )
            else ...[
              HoldingsTotal(
                holdings: holdings,
                value: state.value,
                change: state.change,
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < holdings.length; i++)
                HoldingRow(
                  holding: holdings[i],
                  shade: HoldingsTotal.shade(context, i),
                  onTap: () => openNote(context, holdings[i].note),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
