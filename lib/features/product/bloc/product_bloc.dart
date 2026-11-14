import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/data/models/product_section.dart';

part 'product_event.dart';
part 'product_state.dart';

/// Which part of a note's page is showing.
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(const ProductState()) {
    on<ProductSectionSelected>(
      (event, emit) => emit(ProductState(section: event.section)),
    );
  }
}
