import 'package:investnotes_app_sample1/domain/models/loading_phase.dart';

/// A bloc state whose page waits on a fetch: [PageLoader] shows the page's
/// skeleton, its content or a way to try again from [phase].
abstract interface class Loadable {
  LoadingPhase get phase;
}
