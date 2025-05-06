import 'dart:convert';

import 'package:BCG_Store/common/constants/constants.dart';
import 'package:BCG_Store/common/errors/api_errors.dart';
import 'package:BCG_Store/features/users/data/models/change_passeord_model.dart';
import 'package:BCG_Store/features/users/data/models/login_response.dart';
import 'package:BCG_Store/features/users/data/models/register_model.dart';
import 'package:BCG_Store/features/users/domain/entities/change_password_entitie.dart';
import 'package:BCG_Store/features/users/domain/entities/register_entitie.dart';
import 'package:http/http.dart' as http;

abstract class UserLocalDataSources {
  Future<void> registerUser(RegisterEntitie registerEntitie);
  Future<LoginResponse> loginUser(String username, String password, [String? base_datos]);
  Future<void> changePassword(ChangePasswordEntitie change_password_entiti, String token);
  Future<void> recoveryPassword(String email);
  Future<void> updatetoken( String token, String? token_device);
  Future<void> deactivateaccount(String token,String password );

  
}

class UserLocalDataSourcesImp implements UserLocalDataSources {
  String defaultApiServer = AppConstants.serverBase;

@override
Future<void> changePassword(ChangePasswordEntitie change_password_entitie, String token) async {
  try {
    final registerModel = ChangePasseordModel.fromEntity(change_password_entitie);
    final Map<String, dynamic> registerData = registerModel.toJson();
    
    print('Enviando datos para cambio de contraseña: ${jsonEncode(registerData)}');

    var response = await http.put(
      Uri.parse('$defaultApiServer/users/change-password/'),
      headers: {
        
        'Content-Type': 'application/json ',
        'Authorization': 'Bearer $token',
        
      },
      body: jsonEncode(registerData),
    );

    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        print('changePassword Error decodificando JSON: $e');
        body = {"message": "Error en formato de respuesta"};
      }
    } else {
      body = {"message": "Sin respuesta del servidor"};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      String message = body != null && body['message'] != null 
          ? body['message'].toString() 
          : "Cambio de contraseña exitoso";
      print('Cambio de contraseña exitoso: $message');
    } else {
      final camposError = ['current_password', 'new_password', 'confirm_password', 'message'];
      String errorMessage = "Error en el cambio de contraseña";
      
      if (body is Map) {
        for (String campo in camposError) {
          if (body.containsKey(campo)) {
            errorMessage = body[campo].toString();
            break;
          }
        }
      } else if (body != null) {
        errorMessage = body.toString();
      }
      
      print('Error en cambio de contraseña: $errorMessage');
      throw errorMessage;
    }
  } catch (e) {
    print('Excepción en cambio de contraseña: $e');
    if (e is String) {
      throw e;
    } else {
      throw e.toString().replaceAll("Exception: ", "");
    }
  }
}
@override
Future<LoginResponse> loginUser(String username, String password, [String? base_datos]) async {
  try {
    final response = await http.post(
      Uri.parse('$defaultApiServer/users/login/'), 
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': username,  
        'password': password,
        'base_datos': base_datos, 
      }),
    );

    print('login: $defaultApiServer/users/login/');
  
    print('login Response status: ${response.statusCode}');
    print('login Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(responseData);
      
      
      
      print('Login exitoso: ${loginResponse.message}');
      return loginResponse;
    } else {
      if (response.statusCode == 401) {
        throw Exception('login Credenciales inválidas');
      } else if (response.statusCode == 400) {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final String errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Datos de solicitud incorrectos';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('login Datos de solicitud incorrectos');
        }
      } else {
        throw Exception('login Error en el login: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error detallado: $e');
    throw Exception('$e');
  }
}


 

  @override
  Future<void> registerUser(RegisterEntitie registerEntitie) async {
    try {
      final registerModel = RegisterModel.fromEntity(registerEntitie);
      final Map<String, dynamic> registerData = registerModel.toJson();
      
      print('Enviando datos de registro: $registerData');
      print('URL: $defaultApiServer/users/register/');

      var response = await http.post(
        Uri.parse('$defaultApiServer/users/register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(registerData),
      );

      print('Código de respuesta registro: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      dynamic body;
      if (response.body.isNotEmpty) {
        try {
          body = jsonDecode(response.body);
        } catch (e) {
          print('Error decodificando JSON: $e');
          body = {"message": "Error en formato de respuesta"};
        }
      } else {
        body = {"message": "Sin respuesta del servidor"};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        String message = body != null && body['message'] != null 
            ? body['message'].toString() 
            : "Registro exitoso";
        print('Registro exitoso: $message');
      } else {
        String message = body != null && body['message'] != null 
            ? body['message'].toString() 
            : "Error en el registro (código ${response.statusCode})";
        print('Error en registro: $message');
        throw Exception(message);
      }
    } catch (e) {
      print('Excepción en registro: $e');
      throw Exception('Error en el registro: $e');
    }
  }
  
 @override
Future<void> recoveryPassword(String email) async {
  try {
    final response = await http.post(
      Uri.parse('$defaultApiServer/users/recover-password/'), 
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    print('recovery password Response status: ${response.statusCode}');
    print('recovery password Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Solicitud de recuperación enviada exitosamente');
    } else {
      if (response.statusCode == 404) {
        throw Exception('El correo electrónico no está registrado');
      } else if (response.statusCode == 400) {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final String errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Datos de solicitud incorrectos';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Datos de solicitud incorrectos');
        }
      } else {
        throw Exception('Error en la recuperación de contraseña: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error detallado: $e');
    throw Exception('$e');
  }
}

  @override
  Future<void> updatetoken(String token, String? token_device) async {
    try {
      final response = await http.put(
        Uri.parse('$defaultApiServer/users/update-token-device/'), 
        headers: {
          'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',

        },
        body: jsonEncode({
          'token_device': token_device, 
        }),
      );

      if (response.statusCode == 200) {
        print('Token de dispositivo actualizado exitosamente');
      } else {
        ApiExceptionCustom exception = ApiExceptionCustom(
          response: response,
        );
        exception.validateMesage();
        throw exception;
      }
    } catch (e) {
      String errorMessage = convertMessageException(error: e);
      print('Error detallado: $errorMessage');
      throw ApiExceptionCustom(message: errorMessage);
    }
  }
  @override
Future<void> deactivateaccount(String token, String password) async {
  try {
    final url = Uri.parse('${defaultApiServer}/users/deactivate-account/');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'password': password,
      }),
    );

    final dynamic jsonData = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {
      print('Cuenta desactivada exitosamente');
    } else if (response.statusCode == 400) {
      throw Exception(jsonData['password'] ?? 'Error al desactivar la cuenta');
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada. Por favor, inicie sesión nuevamente.');
    } else {
      throw Exception('Error al desactivar la cuenta: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}

   
}