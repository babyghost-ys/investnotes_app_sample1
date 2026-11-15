/// Every place in Keel that has an address.
abstract final class KeelRoutes {
  static const home = '/';
  static const search = '/search';
  static const saved = '/saved';

  /// Articles kept on the device to read offline.
  static const downloads = '/downloads';

  /// Opening an account straight from Home, outside sign-in.
  static const register = '/register';
  static const finderResults = '/finder/results';
  static const settings = '/settings';

  /// Education's search: the finder's way in, then open notes by type.
  static const educationSearch = '/education/search';
  static const biometricSettings = '/settings/biometric';

  /// Sign-in on Android; on iOS it rises as a native sheet instead.
  static const signIn = '/sign-in';

  /// The welcome back for an account that signs in with Face ID or Touch
  /// ID, on Android; on iOS it opens the native sign-in sheet instead.
  static const biometricSignIn = '/sign-in-biometric';

  static String offering(String id) => '/offering/$id';

  /// An offering opened from the Offerings list on a single pane. In a
  /// split window it shows beside the list instead, and this page steps
  /// back to the split when the window widens.
  static String offeringsItem(String id) => '/offerings/$id';
  static String note(String id) => '/note/$id';
  static String article(String id) => '/article/$id';
  static String explainer(String id) => '/explainer/$id';
  static String finderStep(int step) => '/finder/step/$step';
}
