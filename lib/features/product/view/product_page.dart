import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/core/widgets/page_loader.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_body.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_skeleton.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';

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

/// A note's own page: its bar, with the bookmark for an offering, over its
/// content.
class ProductPage extends StatelessWidget implements LocalisationConsumer {
  const ProductPage({super.key, required this.product});

  final Product product;

  @override
  List<String> get namespaces => const [Locales.product, Locales.general];

  @override
  Widget build(BuildContext context) => LocalisedBuilder(
    consumer: this,
    builder: (context, locale) =>
        _build(context, locale[0] as ProductLocale, locale[1] as GeneralLocale),
  );

  Widget _build(
    BuildContext context,
    ProductLocale words,
    GeneralLocale general,
  ) {
    final p = product;
    final saved =
        p.isOffering &&
        context.select<OfferingsBloc, bool>(
          (b) => b.state.saved.contains(p.id),
        );
    return NativeScaffold(
      extendBody: true,
      backgroundColor: KeelColors.page.of(context),
      appBar: NativeAppBar(
        title: p.type.code,
        semanticTitle: p.type.title(general),
        actions: [
          if (p.isOffering)
            bookmarkAction(context, p.id, saved: saved, product: words),
        ],
      ),
      body: PageLoader(
        skeleton: const ProductSkeleton(),
        child: ProductBody(product: p),
      ),
    );
  }
}

/// The bar button that saves an offering, or takes it out of saved.
NativeAppBarAction bookmarkAction(
  BuildContext context,
  String id, {
  required bool saved,
  required ProductLocale product,
}) => NativeAppBarAction(
  icon: NativeIcon(
    sfSymbol: saved ? 'bookmark.fill' : 'bookmark',
    icon: saved ? Icons.bookmark : Icons.bookmark_border,
  ),
  label: saved ? product.semantics.unsave : product.semantics.save,
  onPressed: () => context.read<OfferingsBloc>().add(OfferingSaveToggled(id)),
);
