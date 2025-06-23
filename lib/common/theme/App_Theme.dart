import 'package:flutter/material.dart';
import 'package:BCG_Store/common/services/theme_service.dart';

class AppTheme {
  // Propiedades de color que ahora acceden al servicio
  static Color get primaryColor => ThemeService.to.primaryColor.value;
  static Color get buttonColor => ThemeService.to.buttonColor.value;
  static const Color secondaryColor = Colors.white;
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color successColor = Color(0xFF4CAF50);

  // URL del logo (directamente del ThemeService)
  static String get logoUrl => ThemeService.to.logoUrl.value;
  
  // Método para verificar si tenemos un logo personalizado
  static bool get hasCustomLogo => ThemeService.to.logoUrl.value.isNotEmpty;

  // Imagen por defecto
  static const String defaultLogoAsset = 'https://sgp-web.nyc3.cdn.digitaloceanspaces.com/sgp-web/Logotipos/bcg-rewards.png';

  static const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.05);
  static const Color dividerColor = Colors.black12;
  static const Color textTertiaryColor = Colors.black87;

  static const Color pointsColor = Colors.red;
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Colors.black54;
  static final Color backgroundGrey = Colors.grey[50]!;
  static final Color backgroundGreyDark = Colors.grey[200]!;
  static final Color iconGrey = Colors.grey[400]!;
  static final Color textGrey = Colors.grey[600]!;
  static const Color Loading = Colors.white;
  static const Color addPaymen = Colors.orange;
  static const Color ViewPaymen = Colors.teal;

  static TextStyle get editButtonStyle => TextStyle(
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get fieldLabelStyle => const TextStyle(
    fontSize: 14,
    color: textTertiaryColor,
  );
  
  static TextStyle get fieldValueStyle => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );
  static ThemeData get theme => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundGrey,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      onPrimary: secondaryColor,
      onSecondary: primaryColor,
      onError: secondaryColor,
      background: backgroundColor,
      surface: secondaryColor,
      onBackground: textPrimaryColor,
      onSurface: textPrimaryColor,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: secondaryColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(
        color: secondaryColor,
      ),
    ),

    textTheme: TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      headlineMedium: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textGrey,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        color: textPrimaryColor,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: textPrimaryColor,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: secondaryColor,
      ),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: secondaryColor,
      unselectedLabelColor: textSecondaryColor,
      indicatorColor: primaryColor,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: secondaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    ),

    iconTheme: IconThemeData(
      color: primaryColor,
      size: 24,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
  );
  
static void updateColorsFromQR(Map<String, dynamic> qrData) {
  print('Actualizando colores en AppTheme...');
  print('URL del logo antes: $logoUrl');
  
  ThemeService.to.updateColorsFromQR(qrData);
  
  ThemeService.to.updateAppTheme();
  
  print('URL del logo después: $logoUrl');
  print('Color primario: ${primaryColor.toString()}');
  print('Color de botón: ${buttonColor.toString()}');
}
  
  static void resetColors() {
    ThemeService.to.resetToDefaultColors();
  }
}