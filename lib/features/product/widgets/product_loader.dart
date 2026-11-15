import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/core/widgets/page_loader.dart';
import 'package:investnotes_app_sample1/data/models/product.dart';
import 'package:investnotes_app_sample1/features/product/bloc/product_load_bloc.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_body.dart';
import 'package:investnotes_app_sample1/features/product/widgets/product_skeleton.dart';

/// A note's content as the [ProductLoadBloc] above fetches it: its
/// skeleton, then its body, or a way to try again.
class ProductLoader extends StatelessWidget {
  const ProductLoader({super.key});

  @override
  Widget build(BuildContext context) =>
      PageLoader<ProductLoadBloc, ProductLoadState>(
        skeleton: const ProductSkeleton(),
        load: (bloc) => bloc.add(const ProductLoadRequested()),
        child: BlocSelector<ProductLoadBloc, ProductLoadState, Product?>(
          selector: (state) => state.product,
          builder: (context, product) => product == null
              ? const SizedBox.shrink()
              : ProductBody(product: product),
        ),
      );
}
