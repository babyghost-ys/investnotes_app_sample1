import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row.dart';

/// Offerings bookmarked from their pages, soonest to close first.
class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<OfferingsBloc>().state.savedOfferings;
    final insets = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: KeelColors.page.of(context),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            insets.top + 8,
            20,
            insets.bottom + 40,
          ),
          children: [
            for (final o in saved)
              OfferingRow(offering: o, onTap: () => openOffering(context, o)),
            if (saved.isEmpty) const EmptyState(icon: CupertinoIcons.bookmark),
          ],
        ),
      ),
    );
  }
}
