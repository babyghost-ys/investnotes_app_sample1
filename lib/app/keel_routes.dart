/// Every place in Keel that has an address.
abstract final class KeelRoutes {
  static const home = '/';
  static const search = '/search';
  static const saved = '/saved';

  /// Opening an account straight from Home, outside sign-in.
  static const register = '/register';
  static const finderResults = '/finder/results';
  static const biometricSettings = '/settings/biometric';

  /// Sign-in on Android; on iOS it rises as a native sheet instead.
  static const signIn = '/sign-in';

  /// The welcome back for an account that signs in with Face ID or Touch
  /// ID, on Android; on iOS it opens the native sign-in sheet instead.
  static const biometricSignIn = '/sign-in-biometric';

  static String offering(String id) => '/offering/$id';
  static String note(String id) => '/note/$id';
  static String article(String id) => '/article/$id';
  static String finderStep(int step) => '/finder/step/$step';
}
