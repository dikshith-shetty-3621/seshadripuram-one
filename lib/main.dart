import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() async {
  // Ensure widget binding is initialized before anything else
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize environment config, crashlytics, local DB, etc.
  
  runApp(
    const ProviderScope(
      child: SeshadripuramOneApp(),
    ),
  );
}
