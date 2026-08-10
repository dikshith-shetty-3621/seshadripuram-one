import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Seshadripuram One';
  
  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.seshadripuram.edu/prod';
    }
    return 'https://api.seshadripuram.edu/dev';
  }
}
