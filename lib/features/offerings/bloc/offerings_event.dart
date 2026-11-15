part of 'offerings_bloc.dart';

sealed class OfferingsEvent extends Equatable {
  const OfferingsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the offerings. [quiet] is a retry after a failure, which leaves
/// the failure showing until it succeeds.
final class OfferingsRequested extends OfferingsEvent {
  const OfferingsRequested({this.quiet = false});

  final bool quiet;

  @override
  List<Object?> get props => [quiet];
}

final class OfferingsTypeSelected extends OfferingsEvent {
  const OfferingsTypeSelected(this.type);

  final NoteType type;

  @override
  List<Object?> get props => [type];
}

final class OfferingsFilterChanged extends OfferingsEvent {
  const OfferingsFilterChanged(this.filter);

  final OfferingFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class OfferingSaveToggled extends OfferingsEvent {
  const OfferingSaveToggled(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
