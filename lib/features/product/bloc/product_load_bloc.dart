import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:investnotes_app_sample1/core/loading/loadable.dart';
import 'package:investnotes_app_sample1/domain/models/loading_phase.dart';
import 'package:investnotes_app_sample1/domain/models/product.dart';
import 'package:investnotes_app_sample1/domain/repositories/notes_repository.dart';

part 'product_load_event.dart';
part 'product_load_state.dart';

/// One note's page, open or issued, fetched by its id.
class ProductLoadBloc extends Bloc<ProductLoadEvent, ProductLoadState> {
  /// A note already fetched in this session starts loaded.
  ProductLoadBloc(this._repository, this.id)
    : super(_fetched(_repository.fetchedProduct(id))) {
    on<ProductLoadRequested>(transformer: droppable(), (event, emit) async {
      emit(ProductLoadState(product: state.product));
      try {
        final product = await _repository.fetchProduct(id);
        emit(ProductLoadState(product: product, phase: LoadingPhase.loaded));
      } on NotesUnavailable {
        emit(
          ProductLoadState(product: state.product, phase: LoadingPhase.failed),
        );
      }
    });
  }

  final NotesRepository _repository;
  final String id;

  static ProductLoadState _fetched(Product? product) => product == null
      ? const ProductLoadState()
      : ProductLoadState(product: product, phase: LoadingPhase.loaded);
}
