part of 'draft_bloc.dart';

sealed class DraftEvent<T> {
  const DraftEvent();
}

/// The draft took a new value.
final class DraftChanged<T> extends DraftEvent<T> {
  const DraftChanged(this.value);

  final T value;
}

/// The draft went back to its starting value.
final class DraftReset<T> extends DraftEvent<T> {
  const DraftReset();
}
