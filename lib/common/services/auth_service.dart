import 'dart:convert';
import 'package:BCG_Store/common/constants/constants.dart';
import 'package:BCG_Store/features/users/data/models/login_response.dart';
import 'package:BCG_Store/framework/preferences_service.dart';
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final PreferencesUser _prefsUser = PreferencesUser();
  
  LoginResponse? _cachedSession;

  factory AuthService() => _instance;

  AuthService._internal();

  Future<LoginResponse?> getSession() async {
    if (_cachedSession != null) {
      return _cachedSession;
    }

    try {
      final sessionJson = await _prefsUser.loadPrefs(
        type: String, 
        key: AppConstants.sessionKey
      );
      
      if (sessionJson != null && sessionJson.isNotEmpty) {
        final Map<String, dynamic> sessionMap = jsonDecode(sessionJson);
        _cachedSession = LoginResponse.fromJson(sessionMap);
        return _cachedSession;
      }
      
      return null;
    } catch (e) {
      print('❌ Error al obtener datos de sesión: $e');
      return null;
    }
  }

  Future<bool> saveLoginResponse(LoginResponse response) async {
    try {
      _cachedSession = response;
      
      final sessionData = {
        'message': response.message,
        'user': {
          'id': response.user.id,
          'email': response.user.email,
          'first_name': response.user.firstName,
          'last_name': response.user.lastName,
          'id_cliente': response.user.id_cliente
        },
        'token': {
          'refresh': response.token.refresh,
          'access': response.token.access
        },
        'tienda_activa': response.tienda_activa
      };
      
      _prefsUser.savePrefs(
        type: String,
        key: AppConstants.sessionKey,
        value: jsonEncode(sessionData)
      );
      
      print('✅ Datos de sesión guardados correctamente');
      return true;
    } catch (e) {
      print('❌ Error al guardar datos de sesión: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      _cachedSession = null;
      
      await _prefsUser.clearOnePreference(key: AppConstants.sessionKey);
      
      print('✅ Sesión cerrada correctamente');
      return true;
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null && session.token.access.isNotEmpty;
  }
}