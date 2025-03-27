import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String serverBase = dotenv.env['API_BASE'].toString();

  
  static  String baseDatosKey = 'base_datos';
  static  String idClienteKey = 'id_cliente';
  static  String sessionKey = 'session_data';

  static String primaryColorKey = 'primary_color';
  static String buttonColorKey = 'button_color';
  static String logoUrlKey = 'logo_url';
  static String hasCustomColorsKey = 'has_custom_colors';
  
}