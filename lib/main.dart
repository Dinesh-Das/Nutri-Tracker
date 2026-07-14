import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutri_tracker/dark_theme/custom_theme.dart';
import 'package:nutri_tracker/firebase_options.dart';
import 'package:nutri_tracker/router/app_router.dart';
import 'package:nutri_tracker/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dynamic_color/dynamic_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Hive.initFlutter();
    if (!kIsWeb) {
      await NotificationService.instance.init();
    }
    runApp(const ProviderScope(child: MyApp()));
  } catch (error, stackTrace) {
    debugPrint('NutriTrack initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(BootstrapErrorApp(error: error));
  }
}

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final setupMessage = error is UnsupportedError
        ? error.toString().replaceFirst('Unsupported operation: ', '')
        : 'NutriTrack could not start. Check the platform configuration and '
            'try again.';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriTrack setup required',
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_suggest_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'NutriTrack setup required',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SelectableText(setupMessage, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(_themeChanged);
  }

  void _themeChanged() => setState(() {});

  @override
  void dispose() {
    currentTheme.removeListener(_themeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'NutriTrack India',
          theme: CustomTheme.lightTheme.copyWith(
            colorScheme: lightDynamic ?? CustomTheme.lightTheme.colorScheme,
          ),
          darkTheme: CustomTheme.darkTheme.copyWith(
            colorScheme: darkDynamic ?? CustomTheme.darkTheme.colorScheme,
          ),
          themeMode: currentTheme.currentTheme,
          routerConfig: router,
        );
      },
    );
  }
}
