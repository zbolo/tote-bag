import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'config/router.dart';
import 'services/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Log.info('App', 'Tote Bag starting');

  runApp(
    const ProviderScope(
      child: ToteBagApp(),
    ),
  );
}

class ToteBagApp extends ConsumerWidget {
  const ToteBagApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Tote Bag',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
