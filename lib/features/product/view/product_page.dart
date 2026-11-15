import 'package:flutter_native_widgets/flutter_native_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:keel_localisation/keel_localisation.dart';

import 'package:investnotes_app_sample1/core/l10n/terms.dart';
import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/app/keel_routes.dart';
import 'package:investnotes_app_sample1/core/theme/keel_colors.dart';
import 'package:investnotes_app_sample1/data/models/issued_note.dart';
import 'package:investnotes_app_sample1/data/models/note_enums.dart';
import 'package:investnotes_app_sample1/data/models/offering.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/features/product/bloc/product_load_bloc.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_loader.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_scope.dart';
import 'package:investnotes_app_sample1/features/offerings/bloc/offerings_bloc.dart';

/// Pushes an offering's page. Its type goes along, so the bar is titled
/// while the page loads.
Future<void> openOffering(BuildContext context, Offering offering) =>
    context.push<void>(KeelRoutes.offering(offering.id), extra: offering.type);

/// Pushes an issued note's page.
Future<void> openNote(BuildContext context, IssuedNote note) =>
    context.push<void>(KeelRoutes.note(note.id), extra: note.type);

/// Pushes a note's page, open or issued.
Future<void> openProduct(BuildContext context, Product product) =>
    context.push<void>(
      product.isOffering
          ? KeelRoutes.offering(product.id)
          : KeelRoutes.note(product.id),
      extra: product.type,
    );

/// A note's own page: its bar, with the bookmark for an offering, over its
/// content as it arrives.
class ProductPage extends StatelessWidget implements LocalisationConsumer {
  const ProductPage({
    super.key,
    required this.id,
    required this.isOffering,
    this.type,
  });

  final String id;
  final bool isOffering;

  /// Known from the row that opened the page; otherwise the bar waits for
  /// the note to arrive.
  final NoteType? type;

  @override
  List<String> get namespaces => const [Locales.product, Locales.general];

  @override
  Widget build(BuildContext context) => ProductScope(
    id: id,
    child: LocalisedBuilder(
      consumer: this,
      builder: (context, locale) => _build(
        context,
        locale[0] as ProductLocale,
        locale[1] as GeneralLocale,
      ),
    ),
  );

  Widget _build(
    BuildContext context,
    ProductLocale words,
    GeneralLocale general,
  ) {
    final type =
        this.type ??
        context.select<ProductLoadBloc, NoteType?>(
          (b) => b.state.product?.type,
        );
    final saved =
        isOffering &&
        context.select<OfferingsBloc, bool>((b) => b.state.saved.contains(id));
    return NativeScaffold(
      extendBody: true,
      backgroundColor: KeelColors.page.of(context),
      appBar: NativeAppBar(
        title: type?.code,
        semanticTitle: type?.title(general),
        actions: [
          if (isOffering)
            bookmarkAction(context, id, saved: saved, product: words),
        ],
      ),
      body: const ProductLoader(),
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
