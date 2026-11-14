part of 'product_bloc.dart';

sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

final class ProductSectionSelected extends ProductEvent {
  const ProductSectionSelected(this.section);

  final ProductSection section;

  @override
  List<Object?> get props => [section];
}
