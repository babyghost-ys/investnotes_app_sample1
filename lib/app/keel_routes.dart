/// Every place in Keel that has an address.
abstract final class KeelRoutes {
  static const home = '/';
  static const search = '/search';
  static const saved = '/saved';
  static const finderResults = '/finder/results';
  static const signIn = '/sign-in';
  static const register = '/sign-in/register';
  static const findUsername = '/sign-in/find-username';

  static String offering(String id) => '/offering/$id';
  static String article(String id) => '/article/$id';
  static String finderStep(int step) => '/finder/step/$step';

  /// [username] is what was already typed on sign-in.
  static String resetPassword(String username) => Uri(
    path: '/sign-in/reset-password',
    queryParameters: username.isEmpty ? null : {'username': username},
  ).toString();
}
