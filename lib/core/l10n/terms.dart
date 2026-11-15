import 'package:investnotes_app_sample1/core/l10n/generated/locales.dart';
import 'package:investnotes_app_sample1/domain/models/issued_filter.dart';
import 'package:investnotes_app_sample1/domain/models/note_enums.dart';
import 'package:investnotes_app_sample1/domain/models/note_event.dart';
import 'package:investnotes_app_sample1/domain/models/product_section.dart';

/// What each value of the notes' enums is called, in a namespace's language.
/// The enums stay plain data; their words live in the JSON.
extension NoteTypeTerms on NoteType {
  String title(GeneralLocale general) => switch (this) {
    NoteType.mld => general.labels.typeMld,
    NoteType.ppn => general.labels.typePpn,
    NoteType.par => general.labels.typePar,
    NoteType.auto => general.labels.typeAuto,
  };
}

extension RegionTerms on Region {
  String title(GeneralLocale general) => switch (this) {
    Region.global => general.labels.regionGlobal,
    Region.americas => general.labels.regionAmericas,
    Region.europe => general.labels.regionEurope,
    Region.asiaPacific => general.labels.regionAsiaPacific,
  };
}

extension AssetClassTerms on AssetClass {
  String title(GeneralLocale general) => switch (this) {
    AssetClass.equity => general.labels.assetEquity,
    AssetClass.commodity => general.labels.assetCommodity,
    AssetClass.rates => general.labels.assetRates,
    AssetClass.multiAsset => general.labels.assetMultiAsset,
  };
}

extension IssuedStatusTerms on IssuedStatus {
  String title(GeneralLocale general) => switch (this) {
    IssuedStatus.active => general.labels.statusActive,
    IssuedStatus.called => general.labels.statusCalled,
    IssuedStatus.matured => general.labels.statusMatured,
  };
}

extension ShareClassTerms on ShareClass {
  String title(GeneralLocale general) => switch (this) {
    ShareClass.a => general.labels.shareClassA,
    ShareClass.f => general.labels.shareClassF,
  };
}

extension NoteGoalTerms on NoteGoal {
  String title(GeneralLocale general) => switch (this) {
    NoteGoal.income => general.labels.goalIncome,
    NoteGoal.growth => general.labels.goalGrowth,
    NoteGoal.both => general.labels.goalBoth,
  };
}

extension TermBandTerms on TermBand {
  String title(GeneralLocale general) => switch (this) {
    TermBand.short => general.labels.termShort,
    TermBand.medium => general.labels.termMedium,
    TermBand.long => general.labels.termLong,
  };
}

extension PayoutTerms on Payout {
  String title(GeneralLocale general) => switch (this) {
    Payout.maturity => general.labels.payoutMaturity,
    Payout.annual => general.labels.payoutAnnual,
    Payout.quarterly => general.labels.payoutQuarterly,
  };
}

extension NoteEventKindTerms on NoteEventKind {
  String title(GeneralLocale general) => switch (this) {
    NoteEventKind.closes => general.labels.eventCloses,
    NoteEventKind.issued => general.labels.eventIssued,
    NoteEventKind.callCheck => general.labels.eventCallCheck,
    NoteEventKind.called => general.labels.eventCalled,
    NoteEventKind.matures => general.labels.eventMatures,
  };
}

extension ProductSectionTerms on ProductSection {
  String title(ProductLocale product) => switch (this) {
    ProductSection.overview => product.labels.overview,
    ProductSection.payoff => product.labels.payoff,
    ProductSection.scenarios => product.labels.scenarios,
    ProductSection.history => product.labels.history,
    ProductSection.value => product.labels.value,
    ProductSection.events => product.labels.events,
  };
}

extension IssuedPeriodTerms on IssuedPeriod {
  String label(IssuedLocale issued) => switch (this) {
    IssuedPeriod.all => issued.labels.periodAll,
    IssuedPeriod.year => issued.labels.periodYear,
    IssuedPeriod.threeYears => issued.labels.periodThreeYears,
    IssuedPeriod.fiveYears => issued.labels.periodFiveYears,
    IssuedPeriod.custom => issued.labels.periodCustom,
  };

  String spoken(IssuedLocale issued) => switch (this) {
    IssuedPeriod.all => issued.semantics.periodAll,
    IssuedPeriod.year => issued.semantics.periodYear,
    IssuedPeriod.threeYears => issued.semantics.periodThreeYears,
    IssuedPeriod.fiveYears => issued.semantics.periodFiveYears,
    IssuedPeriod.custom => issued.semantics.periodCustom,
  };
}
