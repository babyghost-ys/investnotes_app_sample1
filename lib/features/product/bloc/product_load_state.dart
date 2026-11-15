part of 'product_load_bloc.dart';

final class ProductLoadState extends Equatable implements Loadable {
  const ProductLoadState({this.product, this.phase = LoadingPhase.loading});

  /// Null until the first fetch arrives.
  final Product? product;
  @override
  final LoadingPhase phase;

  @override
  List<Object?> get props => [product, phase];
}
