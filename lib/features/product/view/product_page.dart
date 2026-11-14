import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Icons;

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/data/models/product_section.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';
import 'package:investnotes_app_sample1/features/probe/widgets/payoff_probe.dart';
import 'package:investnotes_app_sample1/features/product/bloc/product_bloc.dart';
import 'package:investnotes_app_sample1/features/product/widgets/events_section.dart';
import 'package:investnotes_app_sample1/features/product/widgets/history_section.dart';
import 'package:investnotes_app_sample1/features/product/widgets/overview_section.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_header.dart';
import 'package:investnotes_app_sample1/features/product/widgets/scenarios_section.dart';
import 'package:investnotes_app_sample1/features/product/widgets/section_strip.dart';
import 'package:investnotes_app_sample1/features/product/widgets/value_section.dart';

/// Pushes an offering's page.
Future<void> openOffering(BuildContext context, Offering offering) =>
    context.push<void>(KeelRoutes.offering(offering.id));

/// Pushes a note's page, open or issued.
Future<void> openProduct(BuildContext context, Product product) =>
    context.push<void>(
      product.isOffering
          ? KeelRoutes.offering(product.id)
          : KeelRoutes.note(product.id),
    );

/// A note's page: its name, then a strip of sections that stays in reach
/// as the page scrolls, then the chosen section.
class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ProductBloc(),
    child: _ProductView(product: product),
  );
}

class _ProductView extends StatefulWidget {
  const _ProductView({required this.product});

  final Product product;

  @override
  State<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<_ProductView> {
  final _scroll = ScrollController();
  final _headerKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// A new section starts at its top: when the strip is pinned, the page
  /// goes back to where the strip first pins.
  void _select(ProductSection section) {
    final header = _headerKey.currentContext?.size?.height;
    if (header != null && _scroll.hasClients && _scroll.offset > header) {
      _scroll.jumpTo(header);
    }
    context.read<ProductBloc>().add(ProductSectionSelected(section));
  }

  Widget _section(ProductSection section) {
    final p = widget.product;
    return switch (section) {
      ProductSection.overview => OverviewSection(product: p),
      ProductSection.payoff => PayoffProbe(payoff: p.payoff),
      ProductSection.scenarios => ScenariosSection(payoff: p.payoff),
      ProductSection.history => HistorySection(product: p),
      ProductSection.value => ValueSection(product: p),
      ProductSection.events => EventsSection(events: p.events),
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final saved =
        p.isOffering &&
        context.select<OfferingsBloc, bool>(
          (b) => b.state.saved.contains(p.id),
        );
    return AdaptiveScaffold(
      extendBody: true,
      backgroundColor: KeelColors.page.of(context),
      appBar: AdaptiveAppBar(
        title: p.type.code,
        actions: [
          if (p.isOffering)
            AdaptiveAppBarAction(
              icon: AdaptiveIcon(
                sfSymbol: saved ? 'bookmark.fill' : 'bookmark',
                icon: saved ? Icons.bookmark : Icons.bookmark_border,
              ),
              label: saved ? 'Remove from saved' : 'Save',
              onPressed: () =>
                  context.read<OfferingsBloc>().add(OfferingSaveToggled(p.id)),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          final section = context.select<ProductBloc, ProductSection>(
            (b) => b.state.section,
          );
          // The scroll view starts under the bar, so the strip pins there;
          // what scrolls past still shows through behind the bar.
          return Padding(
            padding: EdgeInsets.only(top: insets.top),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: CustomScrollView(
                controller: _scroll,
                clipBehavior: Clip.none,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      key: _headerKey,
                      padding: EdgeInsets.fromLTRB(
                        20 + insets.left,
                        20,
                        20 + insets.right,
                        8,
                      ),
                      child: ProductHeader(product: p),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StripDelegate(
                      sections: p.sections,
                      selected: section,
                      onSelected: _select,
                      inset: EdgeInsets.only(
                        left: insets.left,
                        right: insets.right,
                      ),
                      background: KeelColors.page.of(context),
                      hairline: KeelColors.hairline.of(context),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      20 + insets.left,
                      18,
                      20 + insets.right,
                      insets.bottom + 48,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.topCenter,
                          children: [...previous, ?current],
                        ),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.02),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(section),
                          child: _section(section),
                        ),
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
}

class _StripDelegate extends SliverPersistentHeaderDelegate {
  _StripDelegate({
    required this.sections,
    required this.selected,
    required this.onSelected,
    required this.inset,
    required this.background,
    required this.hairline,
  });

  final List<ProductSection> sections;
  final ProductSection selected;
  final ValueChanged<ProductSection> onSelected;
  final EdgeInsets inset;
  final Color background;
  final Color hairline;

  @override
  double get minExtent => SectionStrip.height;

  @override
  double get maxExtent => SectionStrip.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border(
            bottom: BorderSide(color: overlaps ? hairline : background),
          ),
        ),
        child: SectionStrip(
          sections: sections,
          selected: selected,
          onSelected: onSelected,
          inset: inset,
        ),
      );

  @override
  bool shouldRebuild(_StripDelegate old) =>
      old.selected != selected ||
      old.sections != sections ||
      old.background != background ||
      old.inset != inset;
}
