/// Every place in Keel that has an address.
abstract final class KeelRoutes {
  static const home = '/';
  static const search = '/search';
  static const saved = '/saved';
  static const finderResults = '/finder/results';

  /// Sign-in on Android; on iOS it rises as a native sheet instead.
  static const signIn = '/sign-in';

  static String offering(String id) => '/offering/$id';
  static String article(String id) => '/article/$id';
  static String finderStep(int step) => '/finder/step/$step';
}
