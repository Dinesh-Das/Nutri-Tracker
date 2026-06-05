import 'package:flutter/material.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await NotificationService.instance.init();

  runApp(const ProviderScope(child: MyApp()));
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
    currentTheme.addListener(() {
      setState(() {});
    });
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
