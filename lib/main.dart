import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app_theme.dart';
import 'app/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/cubit/settings_cubit/settings_cubit.dart';
import 'core/cubit/settings_cubit/settings_state.dart';
import 'core/services/download_service.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/app_review_service.dart';
import 'presentation/screens/splash_screen.dart';
const List<String> rtlLanguages = ['ar', 'ur', 'fa'];

void main() async {
  // Ensure Flutter initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handler
  ErrorHandler.initialize();

  // Initialize storage
  await StorageService.getInstance();

  // Track app launches
  await AppReviewService.incrementLaunchCount();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set orientations
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
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(
            storageService: StorageService.instance,
            downloadService: DownloadService(),
          ),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          ThemeMode themeMode = ThemeMode.light;
          if (state is SettingsLoaded) {
            themeMode = state.themeMode == 'dark'
                ? ThemeMode.dark
                : ThemeMode.light;
          }

         // Get current language for RTL
          final languageCode =
              StorageService.instance.getLanguage() ?? 'en';
          final isRTL = rtlLanguages.contains(languageCode);

          return MaterialApp(
            title: 'Pilgrim\'s Companion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            onGenerateRoute: AppRouter.generateRoute,
            home: const SplashScreen(),

            // RTL Support
            locale: Locale(languageCode),
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
              Locale('ur'),
              Locale('tr'),
              Locale('id'),
              Locale('fr'),
              Locale('bn'),
              Locale('ru'),
              Locale('fa'),
              Locale('hi'),
              Locale('ha'),
              Locale('so'),
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      MediaQuery.of(context)
                          .textScaleFactor
                          .clamp(0.8, 1.3),
                    ),
                  ),
                  child: child!,
                ),
              );
            },
          );
      
        },
      ),
    );
  }
}