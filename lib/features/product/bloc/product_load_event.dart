part of 'product_load_bloc.dart';

sealed class ProductLoadEvent extends Equatable {
  const ProductLoadEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches the note's page: on opening it, and on trying again.
final class ProductLoadRequested extends ProductLoadEvent {
  const ProductLoadRequested();
}
