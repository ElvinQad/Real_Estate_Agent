class Routes {
  static const String home = '/';
  static const String clients = '/clients';
  static const String settings = '/settings';
  static const String properties = '/properties';
  static const String profile = '/profile';
}

class ApiConstants {
  static const int pollInterval = 10;
  static const String prodEndpoint = 'https://api.clever-realtor.com/graphql';
  static const Duration timeoutDuration = Duration(seconds: 30);
}
