import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors ───────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF2D5F3F);
  static const Color lightGreen = Color(0xFF5E9B76);
  static const Color darkGreen = Color(0xFF1A3D28);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFE8C547);
  static const Color creamBackground = Color(0xFFF8F6F0);
  static const Color darkBackground = Color(0xFF111111);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);

  // ── Light Theme ────────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: creamBackground,

    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: goldAccent,
      surface: Colors.white,
      background: creamBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Cards
   cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: primaryGreen, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryGreen,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryGreen,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryGreen,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.black45,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEEEE),
      thickness: 1,
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryGreen,
      linearTrackColor: Color(0xFFEEEEEE),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // ── Dark Theme ─────────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: lightGreen,
    scaffoldBackgroundColor: darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: lightGreen,
      secondary: goldAccent,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Cards
    cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        elevation: 2,
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightGreen,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: lightGreen, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white60,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: Colors.white38,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFF333333),
      thickness: 1,
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF444444)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF444444)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightGreen, width: 2),
      ),
      filled: true,
      fillColor: darkCard,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: lightGreen,
      linearTrackColor: Color(0xFF333333),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
// import 'package:flutter/material.dart';

// class AppTheme {
//   // Colors
//   static const Color primaryGreen = Color(0xFF2D5F3F);
//   static const Color lightGreen = Color(0xFF5E9B76);
//   static const Color goldAccent = Color(0xFFD4AF37);
//   static const Color creamBackground = Color(0xFFF5F5DC);
//   static const Color darkBackground = Color(0xFF1A1A1A);
  
//   // Light Theme
//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
//     primaryColor: primaryGreen,
//     scaffoldBackgroundColor: creamBackground,
    
//     colorScheme: const ColorScheme.light(
//       primary: primaryGreen,
//       secondary: goldAccent,
//       surface: Colors.white,
//       background: creamBackground,
//     ),
    
//     appBarTheme: const AppBarTheme(
//       backgroundColor: primaryGreen,
//       foregroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     ),
    
//     cardTheme: CardThemeData(
//     color: Colors.white,
//     elevation: 2,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(16),
//     ),
//   ),

//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: primaryGreen,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         textStyle: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
    
//     textTheme: const TextTheme(
//       displayLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: primaryGreen,
//       ),
//       displayMedium: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.w600,
//         color: primaryGreen,
//       ),
//       bodyLarge: TextStyle(
//         fontSize: 16,
//         color: Colors.black87,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 14,
//         color: Colors.black54,
//       ),
//     ),
//   );
  
//   // Dark Theme
//   static ThemeData darkTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.dark,
//     primaryColor: lightGreen,
//     scaffoldBackgroundColor: darkBackground,
    
//     colorScheme: const ColorScheme.dark(
//       primary: lightGreen,
//       secondary: goldAccent,
//       surface: Color(0xFF2A2A2A),
//       background: darkBackground,
//     ),
    
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Color(0xFF2A2A2A),
//       foregroundColor: Colors.white,
//       elevation: 0,
//       centerTitle: true,
//       titleTextStyle: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//     ),
    
//     cardTheme: CardThemeData(
//   color: const Color(0xFF2A2A2A),
//   elevation: 2,
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(16),
//   ),
// ),
    
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: lightGreen,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         textStyle: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     ),
    
//     textTheme: const TextTheme(
//       displayLarge: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//       displayMedium: TextStyle(
//         fontSize: 24,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       ),
//       bodyLarge: TextStyle(
//         fontSize: 16,
//         color: Colors.white70,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 14,
//         color: Colors.white60,
//       ),
//     ),
//   );
// }