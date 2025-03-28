import 'dart:convert';
import 'package:BCG_Store/common/constants/constants.dart';
import 'package:BCG_Store/features/rewards/data/models/check_point_model.dart';
import 'package:BCG_Store/features/rewards/data/models/clientes_app_rewards_model.dart';
import 'package:BCG_Store/features/rewards/data/models/get_data_sells_model.dart';
import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:http/http.dart' as http;

abstract class RewardLocalDataSources {
  
  Future<List<CheckPointsEntitie>> getRewards(String token,String id_cliente);
  
   Future<List<ClientesAppRewardsEntitie>> getClientesAppRewards(String token,int id);
   Future<void> updateAccountData(String token,ClientesAppRewardsEntitie clientesAppRewardsEntitie);
   Future<List<GetDataSellsEntitie>> getDataSells(String token,String id_cliente);

}
class RewardLocalDataSourcesImpl implements RewardLocalDataSources {

  String defaultApiServer = AppConstants.serverBase;
  
  @override
  Future<List<CheckPointsEntitie>> getRewards(String token,String id_cliente) async {
  try {

    final response = await http.get(
      Uri.parse('$defaultApiServer/check_points/$id_cliente'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('⭐ Código de respuesta: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('⭐ Respuesta exitosa');
      print('⭐ Cuerpo de respuesta: ${response.body}');
      
      final List<dynamic> jsonData = json.decode(response.body);
      print('⭐ Número de elementos recibidos: ${jsonData.length}');
      
      final List<CheckPointsEntitie> results = [];
      for (var item in jsonData) {
        print('⭐ Procesando item: $item');
        try {
          final model = CheckPointModel.fromJson(item);
          print('⭐ Item procesado exitosamente: ${model.folio_venta}');
          results.add(model);
        } catch (e) {
          print('❌ Error procesando item: $e');
        }
      }
      
      print('⭐ Total de elementos procesados: ${results.length}');
      return results;
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
          throw Exception('Error al obtener recompensas: ${response.statusCode}');
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

@override
Future<List<ClientesAppRewardsEntitie>> getClientesAppRewards(String token, int id) async {
  try {
    print('⭐ Iniciando getRewards');
    print('⭐ Token: ${token.substring(0, 10)}...'); 

    final response = await http.get(
      Uri.parse('$defaultApiServer/clientesapprewards/$id/'),
    headers: {
  'Content-Type': 'application/json; charset=utf-8',
  'Authorization': 'Bearer $token',
  'Accept': 'application/json; charset=utf-8',
},
    );
    
    print('⭐ Código de respuesta: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('⭐ Respuesta exitosa');
      print('⭐ Cuerpo de respuesta: ${response.body}');
      
final dynamic jsonData = json.decode(utf8.decode(response.bodyBytes));      
      if (jsonData is Map<String, dynamic>) {
        print('⭐ Procesando objeto único');
        try {
          final model = ClientesAppRewardsModel.fromJson(jsonData);
          return [model];
        } catch (e) {
          print('❌ Error procesando objeto: $e');
          throw Exception('Error al procesar los datos: $e');
        }
      } else if (jsonData is List) {
        print('⭐ Procesando lista de ${jsonData.length} elementos');
        final List<ClientesAppRewardsEntitie> results = [];
        for (var item in jsonData) {
          try {
            final model = ClientesAppRewardsModel.fromJson(item);
            results.add(model);
          } catch (e) {
            print('❌ Error procesando item: $e');
          }
        }
        return results;
      } else {
        print('❌ Formato de respuesta inesperado: ${jsonData.runtimeType}');
        throw Exception('Formato de respuesta inesperado');
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
          throw Exception('Error al obtener recompensas: ${response.statusCode}');
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

  @override
  Future<void> updateAccountData(String token,ClientesAppRewardsEntitie clientesAppRewardsEntitie) async {
  
    var response = await http.put(
      Uri.parse('$defaultApiServer/clientesapprewards/update/${clientesAppRewardsEntitie.id}/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
          ClientesAppRewardsModel.fromEntity(clientesAppRewardsEntitie).toJson()),
    );

    dynamic body = jsonDecode(response.body);
    
    print(body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      String message = body['message'].toString();
      print(message);
      print("si se ejecuto bien el qualification $message ");
    } else {
      String message = body['message'].toString();
      print('error al qualification $body');
      throw Exception(message);
    }
  }
  
  @override
Future<List<GetDataSellsEntitie>> getDataSells(String token, String id_cliente) async {
  try {
    print('⭐ Iniciando getDataSells');
    print('⭐ Token: ${token.substring(0, 10)}...'); 
    print('⭐ ID Cliente: $id_cliente');

    final response = await http.get(
      Uri.parse('$defaultApiServer/ventas_cliente/$id_cliente/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('⭐ Código de respuesta: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('⭐ Respuesta exitosa');
      
      // Decodificar el JSON
      final dynamic jsonData = json.decode(utf8.decode(response.bodyBytes));      

      print('⭐ Número de ventas recibidas: ${jsonData.length}');
      
      // Utilizar el método parseList del modelo para procesar los datos
      try {
        final List<GetDataSellsEntitie> results = GetDataSellsModel.parseList(jsonData);
        print('⭐ Total de productos procesados: ${results.length}');
        return results;
      } catch (e) {
        print('❌ Error procesando datos de ventas: $e');
        throw Exception('Error al procesar los datos de ventas: $e');
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
          throw Exception('Error al obtener datos de ventas: ${response.statusCode}');
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
