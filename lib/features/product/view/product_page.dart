import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_body.dart';
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
class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
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
        actions: [
          if (p.isOffering) bookmarkAction(context, p.id, saved: saved),
        ],
      ),
      body: ProductBody(product: p),
    );
  }
}

/// The bar button that saves an offering, or takes it out of saved.
NativeAppBarAction bookmarkAction(
  BuildContext context,
  String id, {
  required bool saved,
}) => NativeAppBarAction(
  icon: NativeIcon(
    sfSymbol: saved ? 'bookmark.fill' : 'bookmark',
    icon: saved ? Icons.bookmark : Icons.bookmark_border,
  ),
  label: saved ? 'Remove from saved' : 'Save',
  onPressed: () => context.read<OfferingsBloc>().add(OfferingSaveToggled(id)),
);
