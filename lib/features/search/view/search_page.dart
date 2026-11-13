import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/empty_state.dart';
import 'package:investnotes_app_sample1/core/widgets/keel_field.dart';
import 'package:investnotes_app_sample1/data/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/issued/bloc/issued_bloc.dart';
import 'package:investnotes_app_sample1/features/issued/widgets/issued_row.dart';
import 'package:investnotes_app_sample1/features/offerings/view/offering_detail_page.dart';
import 'package:investnotes_app_sample1/features/offerings/widgets/offering_row.dart';
import 'package:investnotes_app_sample1/features/search/bloc/search_bloc.dart';

/// Searches every offering and issued note as you type.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => SearchBloc(context.read<NotesRepository>()),
    child: BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final insets = MediaQuery.paddingOf(context);
        final issued = context.watch<IssuedBloc>().state;
        return ColoredBox(
          color: KeelColors.page.of(context),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                20,
                insets.top + 16,
                20,
                insets.bottom + 40,
              ),
              children: [
                KeelField(
                  icon: CupertinoIcons.search,
                  placeholder: 'Name, index, region',
                  autofocus: true,
                  action: TextInputAction.search,
                  onChanged: (q) =>
                      context.read<SearchBloc>().add(SearchQueryChanged(q)),
                ),
                const SizedBox(height: 8),
                for (final o in state.offerings)
                  OfferingRow(
                    offering: o,
                    onTap: () => openOffering(context, o),
                  ),
                for (final n in state.issued)
                  IssuedRow(
                    note: n,
                    expanded: issued.expanded.contains(n.id),
                    onToggle: () =>
                        context.read<IssuedBloc>().add(IssuedRowToggled(n.id)),
                  ),
                if (state.query.trim().isNotEmpty && state.empty)
                  const EmptyState(
                    icon: CupertinoIcons.search,
                    text: 'Nothing found',
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
