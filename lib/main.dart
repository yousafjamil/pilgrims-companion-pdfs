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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/risala_service.dart'; // ✅ Import RisalaService

const List<String> rtlLanguages = ['ar', 'ur', 'fa'];

// List of locales that Flutter actually supports with MaterialLocalizations
const List<String> flutterSupportedLocales = [
  'en', 'ar', 'ur', 'tr', 'id', 'fr', 'bn', 'ru', 'fa', 
  'hi', 'so', 'zh', 'es', 'ms', 'sw', 'ps', 'uz', 'az', 
  'tg', 'ky', 'ta', 'te', 'ml', 'kn', 'gu', 'ne', 'si', 
  'am', 'yo', 'bs', 'sr', 'ro', 'pl', 'cs', 'hu', 'lt', 
  'da', 'vi', 'tl', 'km', 'ku'
];

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
          
          // Check if current locale is supported by Flutter
          final isLocaleSupported = flutterSupportedLocales.contains(languageCode);
          final effectiveLocale = isLocaleSupported ? languageCode : 'en';

          return MaterialApp(
            title: 'Pilgrim\'s Companion',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: Locale(effectiveLocale),
            localeResolutionCallback: (locale, supportedLocales) {
              // If locale is supported by Flutter's MaterialLocalizations, use it
              if (locale != null && flutterSupportedLocales.contains(locale.languageCode)) {
                for (final supported in supportedLocales) {
                  if (supported.languageCode == locale.languageCode) {
                    return supported;
                  }
                }
              }
              // Fallback to English for unsupported locales
              return const Locale('en');
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), Locale('ar'), Locale('ur'),
              Locale('tr'), Locale('id'), Locale('fr'),
              Locale('bn'), Locale('ru'), Locale('fa'),
              Locale('hi'), Locale('so'), Locale('zh'),
              Locale('es'), Locale('ms'), Locale('sw'),
              Locale('ps'), Locale('uz'), Locale('az'),
              Locale('tg'), Locale('ky'), Locale('ta'),
              Locale('te'), Locale('ml'), Locale('kn'),
              Locale('gu'), Locale('ne'), Locale('si'),
              Locale('am'), Locale('yo'), Locale('bs'),
              Locale('sr'), Locale('ro'), Locale('pl'),
              Locale('cs'), Locale('hu'), Locale('lt'),
              Locale('da'), Locale('vi'), Locale('tl'),
              Locale('km'), Locale('ku'),
            ],
            onGenerateRoute: AppRouter.generateRoute,
            home: const SplashScreen(),
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
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'app/app_theme.dart';
// import 'app/app_router.dart';
// import 'core/services/storage_service.dart';
// import 'core/cubit/settings_cubit/settings_cubit.dart';
// import 'core/cubit/settings_cubit/settings_state.dart';
// import 'core/services/download_service.dart';
// import 'core/utils/error_handler.dart';
// import 'core/utils/app_review_service.dart';
// import 'presentation/screens/splash_screen.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// const List<String> rtlLanguages = ['ar', 'ur', 'fa'];

// void main() async {
//   // Ensure Flutter initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize error handler
//   ErrorHandler.initialize();

//   // Initialize storage
//   await StorageService.getInstance();

//   // Track app launches
//   await AppReviewService.incrementLaunchCount();

//   // Set system UI
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarColor: Colors.transparent,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );

//   // Set orientations
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//   ]);

//   runApp(const PilgrimsCompanionApp());
// }

// class PilgrimsCompanionApp extends StatelessWidget {
//   const PilgrimsCompanionApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<SettingsCubit>(
//           create: (_) => SettingsCubit(
//             storageService: StorageService.instance,
//             downloadService: DownloadService(),
//           ),
//         ),
//       ],
//       child: BlocBuilder<SettingsCubit, SettingsState>(
//         builder: (context, state) {
//           ThemeMode themeMode = ThemeMode.light;
//           if (state is SettingsLoaded) {
//             themeMode = state.themeMode == 'dark'
//                 ? ThemeMode.dark
//                 : ThemeMode.light;
//           }

//          // Get current language for RTL
//           final languageCode =
//               StorageService.instance.getLanguage() ?? 'en';
//           final isRTL = rtlLanguages.contains(languageCode);

//           return MaterialApp(
//             title: 'Pilgrim\'s Companion',
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.lightTheme,
//             darkTheme: AppTheme.darkTheme,
//             themeMode: themeMode,
             
//              locale: Locale(languageCode),
// localeResolutionCallback: (locale, supportedLocales) {
//   // If locale is supported, use it; otherwise fall back to English
//   for (final supported in supportedLocales) {
//     if (supported.languageCode == locale?.languageCode) {
//       return supported;
//     }
//   }
//   return const Locale('en'); // fallback
// },
//   localizationsDelegates: const [
//     GlobalMaterialLocalizations.delegate,
//     GlobalWidgetsLocalizations.delegate,
//     GlobalCupertinoLocalizations.delegate,
//   ],
//   supportedLocales: const [
//     Locale('en'), Locale('ar'), Locale('ur'),
//     Locale('tr'), Locale('id'), Locale('fr'),
//     Locale('bn'), Locale('ru'), Locale('fa'),
//     Locale('hi'), Locale('ha'), Locale('so'),
//     Locale('zh'), Locale('es'), Locale('ms'),
//     Locale('sw'), Locale('ps'), Locale('uz'),
//     Locale('az'), Locale('tg'), Locale('ky'),
//     Locale('ta'), Locale('te'), Locale('ml'),
//     Locale('kn'), Locale('gu'), Locale('ne'),
//     Locale('si'), Locale('am'), Locale('yo'),
//     Locale('bs'), Locale('sr'), Locale('ro'),
//     Locale('pl'), Locale('cs'), Locale('hu'),
//     Locale('lt'), Locale('da'), Locale('vi'),
//     Locale('tl'), Locale('km'), Locale('ku'),
//   ],
//             onGenerateRoute: AppRouter.generateRoute,
//             home: const SplashScreen(),

    
       
//             builder: (context, child) {
//               return Directionality(
//                 textDirection: isRTL
//                     ? TextDirection.rtl
//                     : TextDirection.ltr,
//                 child: MediaQuery(
//                   data: MediaQuery.of(context).copyWith(
//                     textScaler: TextScaler.linear(
//                       MediaQuery.of(context)
//                           .textScaleFactor
//                           .clamp(0.8, 1.3),
//                     ),
//                   ),
//                   child: child!,
//                 ),
//               );
//             },
//           );
      
//         },
//       ),
//     );
//   }
// }