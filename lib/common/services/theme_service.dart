import 'package:flutter/material.dart';
import 'package:BCG_Store/common/constants/constants.dart';
import 'package:BCG_Store/framework/preferences_service.dart';
import 'package:get/get.dart';
class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();
  
  final PreferencesUser _prefsUser = PreferencesUser();
  
  final primaryColor = Color(0xFF3F3F3F).obs;
  final buttonColor = Color(0xFFE53631).obs;
  final logoUrl = ''.obs;
  
  final hasCustomColors = false.obs;
  
  Future<ThemeService> init() async {
    try {
      await _prefsUser.initiPrefs();
      _loadThemeData();
    } catch (e) {
      print('Error inicializando ThemeService: $e');
    }
    return this;
  }
  
  void _loadThemeData() {
    try {
      _prefsUser.loadPrefs(
        type: int, 
        key: AppConstants.primaryColorKey
      ).then((primaryColorValue) {
        if (primaryColorValue != null) {
          primaryColor.value = Color(primaryColorValue);
        }
      });
      
      _prefsUser.loadPrefs(
        type: int, 
        key: AppConstants.buttonColorKey
      ).then((buttonColorValue) {
        if (buttonColorValue != null) {
          buttonColor.value = Color(buttonColorValue);
        }
      });
      
      _prefsUser.loadPrefs(
        type: String, 
        key: AppConstants.logoUrlKey
      ).then((savedLogoUrl) {
        if (savedLogoUrl != null && savedLogoUrl.isNotEmpty) {
          logoUrl.value = savedLogoUrl;
          print('Logo URL cargada de PreferencesUser: $savedLogoUrl');
        }
      });
      
      _prefsUser.loadPrefs(
        type: bool, 
        key: AppConstants.hasCustomColorsKey
      ).then((savedHasCustomColors) {
        if (savedHasCustomColors != null) {
          hasCustomColors.value = savedHasCustomColors;
        }
      });
      
      print('Tema cargado desde PreferencesUser');
    } catch (e) {
      print('Error cargando tema: $e');
      _resetToDefaultColors();
    }
  }
  
  void _saveThemeData() {
    try {
      _prefsUser.savePrefs(
        type: int,
        key: AppConstants.primaryColorKey,
        value: primaryColor.value.value
      );
      
      _prefsUser.savePrefs(
        type: int,
        key: AppConstants.buttonColorKey,
        value: buttonColor.value.value
      );
      
      _prefsUser.savePrefs(
        type: String,
        key: AppConstants.logoUrlKey,
        value: logoUrl.value
      );
      print('Logo URL guardada en PreferencesUser: ${logoUrl.value}');
      
      _prefsUser.savePrefs(
        type: bool,
        key: AppConstants.hasCustomColorsKey,
        value: hasCustomColors.value
      );
      
      print('Tema guardado en PreferencesUser');
    } catch (e) {
      print('Error guardando tema: $e');
    }
  }
  
  void updateColorsFromQR(Map<String, dynamic> qrData) {
    try {
      print('Datos completos del QR para el tema: $qrData');
      
      if (qrData.containsKey('code_color_page') && qrData['code_color_page'] != null) {
        final colorHex = qrData['code_color_page'].toString();
        print('Actualizando color primario: $colorHex');
        primaryColor.value = _hexToColor(colorHex);
      }
  
      if (qrData.containsKey('code_color_button') && qrData['code_color_button'] != null) {
        final colorHex = qrData['code_color_button'].toString();
        print('Actualizando color de botón: $colorHex');
        buttonColor.value = _hexToColor(colorHex);
      }
  
      if (qrData.containsKey('URL_Logo') && qrData['URL_Logo'] != null) {
        final url = qrData['URL_Logo'].toString();
        print('Actualizando URL del logo en ThemeService: $url');
        logoUrl.value = url;
      } else {
        print('El QR no contiene URL_Logo o es nula');
      }
      
      hasCustomColors.value = true;
  
      updateAppTheme();
      
      _saveThemeData();
      
      print('Colores actualizados desde QR: primaryColor=${primaryColor.value}, buttonColor=${buttonColor.value}, logoUrl=${logoUrl.value}');
    } catch (e) {
      print('Error al actualizar colores: $e');
    }
  }
  
  void _resetToDefaultColors() {
    primaryColor.value = Color(0xFF004D40);
    buttonColor.value = Color(0xFF004D40);
    logoUrl.value = '';
    hasCustomColors.value = false;
    _saveThemeData();
  }
  
  void resetToDefaultColors() {
    _resetToDefaultColors();
    updateAppTheme();
  }
  
  void updateAppTheme() {
    Get.changeTheme(_getThemeData());
    
    Get.forceAppUpdate();
    
    Get.put(MaterialApp.router);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
        Get.appUpdate();
      });
    });
    
    print('Tema actualizado: primaryColor=${primaryColor.value}, buttonColor=${buttonColor.value}');
  }
  
  ThemeData _getThemeData() {
    return ThemeData(
      primaryColor: primaryColor.value,
      scaffoldBackgroundColor: Colors.grey[50],
      colorScheme: ColorScheme.light(
        primary: primaryColor.value,
        secondary: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: primaryColor.value,
        onError: Colors.white,
        background: Colors.white,
        surface: Colors.white,
        onBackground: Colors.black,
        onSurface: Colors.black,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.value,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black54,
        indicatorColor: primaryColor.value,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor.value,
          foregroundColor: Colors.white,
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
        color: primaryColor.value,
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
          borderSide: BorderSide(color: primaryColor.value),
        ),
      ),
    );
  }
  
  Color _hexToColor(String hexString) {
    final hex = hexString.replaceAll('#', '');
    
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    } else {
      print('Formato de color hexadecimal inválido: $hexString');
      return Color(0xFF004D40);
    }
  }
}