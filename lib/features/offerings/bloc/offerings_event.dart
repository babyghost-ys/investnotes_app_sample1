part of 'offerings_bloc.dart';

sealed class OfferingsEvent extends Equatable {
  const OfferingsEvent();

  @override
  List<Object?> get props => [];
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
