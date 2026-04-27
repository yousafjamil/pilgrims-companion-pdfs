import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app_theme.dart';
import 'app/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/cubit/settings_cubit/settings_cubit.dart';
import 'core/cubit/settings_cubit/settings_state.dart';
import 'core/services/download_service.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service
  await StorageService.getInstance();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Allow all orientations (tablet support)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const PilgrimsCompanionApp());
}

class PilgrimsCompanionApp extends StatelessWidget {
  const PilgrimsCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global Settings Cubit (theme management)
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(
            storageService: StorageService.instance,
            downloadService: DownloadService(),
          ),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          // Determine theme mode
          ThemeMode themeMode = ThemeMode.light;
          if (state is SettingsLoaded) {
            themeMode = state.themeMode == 'dark'
                ? ThemeMode.dark
                : ThemeMode.light;
          }

          return MaterialApp(
            // App Info
            title: 'Pilgrim\'s Companion',
            debugShowCheckedModeBanner: false,

            // Themes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            // Router
            onGenerateRoute: AppRouter.generateRoute,

            // Home
            home: const SplashScreen(),

            // Builder for global configurations
            builder: (context, child) {
              return MediaQuery(
                // Prevent text scaling from breaking UI
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context)
                        .textScaleFactor
                        .clamp(0.8, 1.3),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}