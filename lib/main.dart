import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/router.dart';
import 'config/theme.dart';

// Import this if you have run 'flutterfire configure'
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Note: To use real Firebase, you must run 'flutterfire configure'
    // and provide DefaultFirebaseOptions.currentPlatform here.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint(
        'Please ensure you have configured Firebase using "flutterfire configure"');
  }

  runApp(const ProviderScope(
    overrides: [],
    child: FoodStackApp(),
  ));
}

class FoodStackApp extends ConsumerWidget {
  const FoodStackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Food Stack',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
