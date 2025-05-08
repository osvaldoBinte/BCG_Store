import 'dart:convert';
import 'package:BCG_Store/common/constants/constants.dart';
import 'package:BCG_Store/common/errors/api_errors.dart';
import 'package:BCG_Store/features/rewards/data/models/check_point_model.dart';
import 'package:BCG_Store/features/rewards/data/models/clientes_app_rewards_model.dart';
import 'package:BCG_Store/features/rewards/data/models/get_data_sells_model.dart';
import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
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
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      List<CheckPointsEntitie> results = [];
      if (responseData.containsKey('transacciones')) {
        for (var item in responseData['transacciones']) {
          final bool esGanado = item['TipoPuntos'] == 'GANADOS';
          final double puntos = (item['Puntos'] ?? 0).toDouble();
          
          results.add(CheckPointModel(
            folio_venta: item['Folio'] ?? '',
            puntos_ganados: esGanado ? puntos : 0,
            fecha_puntos_ganados: esGanado ? item['Fecha'] ?? '' : '',
            puntos_usados: esGanado ? 0 : puntos,
            fecha_puntos_usados: esGanado ? null : item['Fecha'],
            saldo_puntos: esGanado ? puntos : -puntos,
            monedero: esGanado ? puntos : 0,
            importe: item['Total'] ?? 0.0,
            id_cliente: id_cliente,
            ventaId: item['VentaId'] ?? '',
          ));
        }
      }
            print('getRewards results : $responseData');

      return results;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e) {
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
    final response = await http.get(
      Uri.parse('$defaultApiServer/ventas_cliente/$id_cliente/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('⭐ Respuesta exitosa');
      final dynamic jsonData = json.decode(utf8.decode(response.bodyBytes));
      
      print('Este es un mensaje de depuración ${jsonData}');
      
      if (jsonData is List<dynamic>) {
        print('⭐ Respuesta exitosa getDataSells ${jsonData.length}');
        
        // Lista para almacenar las ventas ya procesadas y agrupadas
        final List<GetDataSellsEntitie> results = [];
        
        // Mapa para agrupar las ventas por folio
        final Map<String, Map<String, dynamic>> ventasPorFolio = {};
        
        // Procesar cada venta del JSON
        for (var venta in jsonData) {
          final String folio = venta['Folio'] ?? '';
          
          if (folio.isEmpty) continue;
          
          // Si este folio no existe en nuestro mapa, lo inicializamos
          if (!ventasPorFolio.containsKey(folio)) {
            ventasPorFolio[folio] = {
              'folio': venta['Folio'],
              'subtotal': (venta['Subtotal'] ?? 0).toDouble(),
              'iva': (venta['IVA'] ?? 0).toDouble(),
              'total': (venta['Total'] ?? 0).toDouble(),
              'formaPago': venta['FormaPago'],
              'fecha': venta['Fecha'],
              'tipoPuntos': venta['TipoPuntos'],
              'puntos': (venta['Puntos'] ?? 0).toDouble(),
              'ventaId': venta['VentaId'],
              'orden': venta['Orden'],
              'salidas': <Map<String, dynamic>>[],
            };
          }
          
          // Si esta venta tiene puntos GANADOS, actualizamos el tipo y valor
          if ((venta['TipoPuntos'] ?? '').toUpperCase() == 'GANADOS') {
            ventasPorFolio[folio]!['tipoPuntos'] = 'GANADOS';
            ventasPorFolio[folio]!['puntos'] = (venta['Puntos'] ?? 0).toDouble();
          }
          
          // Procesamos las salidas (productos) de esta venta
          if (venta['Salidas'] is List<dynamic>) {
            for (var salida in venta['Salidas']) {
              // Añadimos esta salida a la lista del folio correspondiente
              ventasPorFolio[folio]!['salidas'].add(salida);
            }
          }
        }
        
        // Convertimos el mapa a objetos GetDataSellsEntitie
        ventasPorFolio.forEach((folio, ventaData) {
          // Convertimos la lista de salidas a objetos SalidaEntitie
          final List<SalidaEntitie> salidas = [];
          for (final salidaData in ventaData['salidas']) {
            salidas.add(SalidaModel.fromJson(salidaData));
          }
          
          // Creamos el objeto de venta con sus salidas
          results.add(GetDataSellsModel(
            folio: ventaData['folio'],
            subtotal: ventaData['subtotal'],
            iva: ventaData['iva'],
            total: ventaData['total'],
            formaPago: ventaData['formaPago'],
            fecha: ventaData['fecha'],
            tipoPuntos: ventaData['tipoPuntos'],
            puntos: ventaData['puntos'],
            ventaId: ventaData['ventaId'],
            orden: ventaData['orden'],
            salidas: salidas,
          ));
        });
        
        print('✅ Total de registros procesados: ${results.length}');
        return results;
      } else {
        throw Exception('Formato de respuesta inesperado del servidor');
      }
    } else {
      final apiException = ApiExceptionCustom(response: response);
      apiException.validateMesage();
      throw Exception(apiException.message);
    }
  } catch (e) {
    if (e is SocketException || e is http.ClientException || e is TimeoutException) {
      throw Exception(convertMessageException(error: e));
    }
    throw Exception(e.toString());
  }
}
}
