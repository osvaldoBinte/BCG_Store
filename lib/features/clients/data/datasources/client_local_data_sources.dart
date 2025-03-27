import 'dart:convert';

import 'package:gerena/common/constants/constants.dart';
import 'package:gerena/features/clients/data/models/cliente_data_model.dart';
import 'package:gerena/features/clients/domain/entities/client_data_entitie.dart';
import 'package:http/http.dart' as http;

abstract class ClientLocalDataSources {
    Future<List<ClientDataEntitie>> getclientdata(String token);

}
class ClientLocalDataSourcesImp implements ClientLocalDataSources {
    String defaultApiServer = AppConstants.serverBase;

@override
Future<List<ClientDataEntitie>> getclientdata(String token) async {
  try {
    final response = await http.get(
      Uri.parse('$defaultApiServer/get_client_data/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('⭐ Código de respuesta: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('⭐ Respuesta exitosa');
      print('⭐ Cuerpo de respuesta: ${response.body}');
      
      // Decodificamos el JSON
      final dynamic jsonData = json.decode(response.body);
      
      // Verificamos si el resultado es un objeto o una lista
      if (jsonData is Map<String, dynamic>) {
        print('⭐ Recibido un objeto único');
        try {
          final model = ClienteDataModel.fromJson(jsonData);
          return [model]; // Devolvemos una lista con un único elemento
        } catch (e) {
          print('❌ Error procesando el objeto: $e');
          throw Exception('Error al procesar los datos del cliente: $e');
        }
      } 
      // Si es una lista, procesamos como antes
      else if (jsonData is List<dynamic>) {
        print('⭐ Número de elementos recibidos: ${jsonData.length}');
        
        final List<ClientDataEntitie> results = [];
        for (var item in jsonData) {
          print('⭐ Procesando item: $item');
          try {
            final model = ClienteDataModel.fromJson(item);
            results.add(model);
          } catch (e) {
            print('❌ Error procesando item: $e');
          }
        }
        
        print('⭐ Total de elementos procesados: ${results.length}');
        return results;
      } else {
        print('❌ Formato de respuesta inesperado: ${jsonData.runtimeType}');
        throw Exception('Formato de respuesta inesperado del servidor');
      }
    } else {
      print('❌ Error en la respuesta: ${response.statusCode}');
      print('❌ Cuerpo de respuesta: ${response.body}');
      
      switch (response.statusCode) {
        case 401:
          print('❌ Error 401: Token inválido o expirado');
          throw Exception('No autorizado: Token inválido o expirado');
        case 403:
          print('❌ Error 403: Sin permisos necesarios');
          throw Exception('Prohibido: No tiene permisos para acceder a este recurso');
        case 404:
          print('❌ Error 404: Recurso no encontrado');
          throw Exception('Recurso no encontrado');
        default:
          print('❌ Error desconocido: ${response.statusCode}');
          try {
            final errorBody = json.decode(response.body);
            print('❌ Detalles del error: $errorBody');
          } catch (e) {
            print('❌ No se pudo parsear el cuerpo de la respuesta');
          }
          throw Exception('Error al obtener datos del cliente: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('❌ Excepción capturada: $e');
    if (e is http.ClientException) {
      print('❌ Error de cliente HTTP: ${e.message}');
    } else if (e is FormatException) {
      print('❌ Error de formato: ${e.message}');
    }
    throw Exception('Error de conexión: $e');
  }
}
  
}