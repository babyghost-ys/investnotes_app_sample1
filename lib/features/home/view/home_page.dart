import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/features/finder/view/finder_page.dart';
import 'package:investnotes_app_sample1/features/home/widgets/closing_card.dart';
import 'package:investnotes_app_sample1/features/home/widgets/finder_banner.dart';
import 'package:investnotes_app_sample1/features/home/widgets/floor_hero.dart';
import 'package:investnotes_app_sample1/features/home/widgets/type_tile.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/product/view/product_page.dart';
import 'package:investnotes_app_sample1/features/shell/bloc/shell_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final offerings = context.watch<OfferingsBloc>().state;
    final closing = [...offerings.all]
      ..sort((a, b) => a.closes.compareTo(b.closes));
    final insets = MediaQuery.paddingOf(context);
    // The top half sits behind the hero, so pulling down past it shows
    // more band instead of the page colour.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.5, 0.5],
          colors: [KeelColors.tide.of(context), KeelColors.page.of(context)],
        ),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FloorHero(topInset: insets.top),
            ColoredBox(
              color: KeelColors.page.of(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      children: [
                        for (final pair in const [
                          [NoteType.mld, NoteType.ppn],
                          [NoteType.par, NoteType.auto],
                        ]) ...[
                          if (pair.first != NoteType.mld)
                            const SizedBox(height: 12),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final type in pair) ...[
                                  if (type != pair.first)
                                    const SizedBox(width: 12),
                                  Expanded(
                                    child: TypeTile(
                                      type: type,
                                      onTap: () {
                                        context.read<OfferingsBloc>().add(
                                          OfferingsTypeSelected(type),
                                        );
                                        context.read<ShellBloc>().add(
                                          const ShellTabSelected(
                                            ShellTab.offerings,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < 5; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            ClosingCard(
                              offering: closing[i],
                              onTap: () => openOffering(context, closing[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FinderBanner(onTap: () => startFinder(context)),
                  ),
                  SizedBox(height: insets.bottom + 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
