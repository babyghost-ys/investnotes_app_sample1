import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart' show CircularProgressIndicator;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/filter_icon_button.dart';
import 'package:investnotes_app_sample1/core/widgets/round_icon_button.dart';
import 'package:investnotes_app_sample1/data/models/load_status.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering_filter.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offerings_filter_sheet.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/load_failure_notice.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row.dart';

class OfferingsPage extends StatelessWidget {
  const OfferingsPage({super.key});

  Future<void> _filter(BuildContext context, OfferingsState state) async {
    final bloc = context.read<OfferingsBloc>();
    final result = await showOfferingsFilter(
      context,
      current: state.filter,
      type: state.type,
      offerings: state.all,
    );
    if (result != null) bloc.add(OfferingsFilterChanged(result));
  }

  @override
  Widget build(BuildContext context) => LoadFailureNotice(
    child: BlocBuilder<OfferingsBloc, OfferingsState>(
      builder: (context, state) {
        final insets = MediaQuery.paddingOf(context);
        final visible = state.visible;
        return ColoredBox(
          color: KeelColors.page.of(context),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView(
              key: const PageStorageKey('offerings'),
              padding: EdgeInsets.fromLTRB(
                20,
                insets.top + 16,
                20,
                insets.bottom + 32,
              ),
              children: [
                NativeSegmentedControl(
                  labels: [for (final t in NoteType.values) t.code],
                  selectedIndex: state.type.index,
                  onValueChanged: (i) => context.read<OfferingsBloc>().add(
                    OfferingsTypeSelected(NoteType.values[i]),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.type.title,
                        style: TextStyle(
                          color: KeelColors.ink.of(context),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    FilterIconButton(
                      activeCount: state.filter.activeCount,
                      onPressed: () => _filter(context, state),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                for (final o in visible)
                  OfferingRow(
                    offering: o,
                    onTap: () => openOffering(context, o),
                  ),
                if (state.status == LoadStatus.loading && state.all.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 72),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (state.status == LoadStatus.failed && state.all.isEmpty)
                  EmptyState(
                    icon: CupertinoIcons.exclamationmark_circle,
                    action: RoundIconButton(
                      icon: CupertinoIcons.arrow_clockwise,
                      label: 'Try again',
                      foreground: KeelColors.azure.of(context),
                      background: KeelColors.mist.of(context),
                      onPressed: () => context.read<OfferingsBloc>().add(
                        const OfferingsRequested(),
                      ),
                    ),
                  )
                else if (visible.isEmpty)
                  EmptyState(
                    icon: CupertinoIcons.line_horizontal_3_decrease,
                    text: 'No matches',
                    action: RoundIconButton(
                      icon: CupertinoIcons.arrow_counterclockwise,
                      label: 'Clear filters',
                      foreground: KeelColors.azure.of(context),
                      background: KeelColors.mist.of(context),
                      onPressed: () => context.read<OfferingsBloc>().add(
                        const OfferingsFilterChanged(OfferingFilter()),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
