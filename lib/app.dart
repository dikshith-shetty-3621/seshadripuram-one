import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class SeshadripuramOneApp extends ConsumerWidget {
  const SeshadripuramOneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Seshadripuram One',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}
