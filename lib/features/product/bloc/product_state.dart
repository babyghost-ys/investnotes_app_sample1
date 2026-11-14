part of 'product_bloc.dart';

final class ProductState extends Equatable {
  const ProductState({this.section = ProductSection.overview});

  final ProductSection section;

  @override
  List<Object?> get props => [section];
}
