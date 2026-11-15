import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:investnotes_app_sample1/domain/repositories/notes_repository.dart';
import 'package:investnotes_app_sample1/features/product/bloc/product_load_bloc.dart';

/// Provides the [ProductLoadBloc] that fetches note [id], for [child] and
/// for [ProductLoader] below it.
class ProductScope extends StatelessWidget {
  const ProductScope({super.key, required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider(
    key: ValueKey(id),
    create: (context) => ProductLoadBloc(context.read<NotesRepository>(), id),
    child: child,
  );
}
