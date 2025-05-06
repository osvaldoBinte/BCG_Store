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
Future<List<CheckPointsEntitie>> getRewards(String token, String id_cliente) async {
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
      
      final Map<String, dynamic> responseData = json.decode(response.body);
       

      List<CheckPointsEntitie> results = [];
      
      if (responseData.containsKey('puntos_ganados')) {
        print('⭐ Procesando puntos ganados');
        final List<dynamic> puntosGanadosJson = responseData['puntos_ganados'];
        print('⭐ Número de puntos ganados: ${puntosGanadosJson.length}');
        
        for (var item in puntosGanadosJson) {
          try {
            final model = CheckPointModel(
              folio_venta: item['folio_venta'] ?? '',
              puntos_ganados: (item['monedero'] ?? 0).toDouble(),
              fecha_puntos_ganados: item['fecha'] ?? '',
              puntos_usados: 0,
              fecha_puntos_usados: null,
              saldo_puntos: (item['monedero'] ?? 0).toDouble(),
              monedero: (item['monedero'] ?? 0).toDouble(),
              minimo_c: (item['minimo_c'] ?? 0).toDouble(),
              porcentaje: (item['porcentaje'] ?? 0).toDouble(),
              usuario: item['usuario'] ?? '',
              id_cliente: item['id_cliente'],
            );
            
            print('⭐ Punto ganado procesado: ${model.folio_venta}, puntos: ${model.puntos_ganados}');
            results.add(model);
          } catch (e) {
            print('❌ Error procesando punto ganado: $e');
          }
        }
      }
      
      if (responseData.containsKey('puntos_gastados')) {
        print('⭐ Procesando puntos gastados');
        final List<dynamic> puntosGastadosJson = responseData['puntos_gastados'];
        print('⭐ Número de puntos gastados: ${puntosGastadosJson.length}');
        
        for (var item in puntosGastadosJson) {
          try {
            final model = CheckPointModel(
              folio_venta: item['folio'] ?? '',
              puntos_ganados: 0,
              fecha_puntos_ganados: '', 
              puntos_usados: (item['puntos'] ?? 0).toDouble(),
              fecha_puntos_usados: item['fec'] ?? '',
              saldo_puntos: -(item['puntos'] ?? 0).toDouble(), 
              usuario: item['usuario'] ?? '',
              importe: (item['importe'] ?? 0).toDouble(),
              id_cliente: item['id_cliente'],
            );
            
            print('⭐ Punto gastado procesado: ${model.folio_venta}, puntos: ${model.puntos_usados}');
            results.add(model);
          } catch (e) {
            print('❌ Error procesando punto gastado: $e');
          }
        }
      }
      
      if (responseData.containsKey('resumen')) {
        print('⭐ Información de resumen disponible: ${responseData['resumen']}');
        final double balanceActual = (responseData['resumen']['balance_actual'] ?? 0).toDouble();
        print('⭐ Balance actual: $balanceActual');
      }
      
      print('⭐ Total de elementos procesados: ${results.length}');
      
      results.sort((a, b) {
        DateTime dateA = _parseDate(a.puntos_ganados > 0 ? a.fecha_puntos_ganados : (a.fecha_puntos_usados ?? ''));
        DateTime dateB = _parseDate(b.puntos_ganados > 0 ? b.fecha_puntos_ganados : (b.fecha_puntos_usados ?? ''));
        return dateB.compareTo(dateA);
      });
      
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

// Método auxiliar para parsear fechas
DateTime _parseDate(String dateStr) {
  try {
    if (dateStr.isEmpty) return DateTime(2000); // fecha predeterminada si está vacía
    
    // Intentar con formato YYYY-MM-DD
    List<String> parts = dateStr.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]), // año
        int.parse(parts[1]), // mes
        int.parse(parts[2].split(' ')[0])  // día (removiendo cualquier parte de hora)
      );
    }
    
    // Si no se pudo parsear, retornar fecha predeterminada
    return DateTime(2000);
  } catch (e) {
    print('❌ Error al parsear fecha: $dateStr');
    return DateTime(2000); // fecha predeterminada
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
   
    final response = await http.get(
      Uri.parse('$defaultApiServer/ventas_cliente/$id_cliente/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    
    if (response.statusCode == 200) {
      
      final dynamic jsonData = json.decode(utf8.decode(response.bodyBytes));      

      
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
