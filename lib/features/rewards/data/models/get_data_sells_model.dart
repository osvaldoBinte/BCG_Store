import 'package:gerena/features/rewards/domain/entities/get_data_sells_entitie.dart';

class GetDataSellsModel extends GetDataSellsEntitie {
  GetDataSellsModel({
    required String? folio,
    required double? subtotal,
    required double? iva,
    required double? total,
    required String? formaPago,
    required String? fecha,
    required String? numParte,
    required String? descripcion,
    required double? cantidad,
    required double? precio,
    required double? importe,
    required String? um,
  }) : super(
          folio: folio,
          subtotal: subtotal,
          iva: iva,
          total: total,
          formaPago: formaPago,
          fecha: fecha,
          numParte: numParte,
          descripcion: descripcion,
          cantidad: cantidad,
          precio: precio,
          importe: importe,
          um: um,
        );

  factory GetDataSellsModel.fromJson(Map<String, dynamic> json, Map<String, dynamic> salidaItem) {
    return GetDataSellsModel(
      folio: json['Folio'],
      subtotal: (json['Subtotal'] ?? 0).toDouble(),
      iva: (json['IVA'] ?? 0).toDouble(),
      total: (json['Total'] ?? 0).toDouble(),
      formaPago: json['FormaPago'],
      fecha: json['Fecha'],
      numParte: salidaItem['NumParte'],
      descripcion: salidaItem['Descripcion'],
      cantidad: (salidaItem['Cantidad'] ?? 0).toDouble(),
      precio: (salidaItem['Precio'] ?? 0).toDouble(),
      importe: (salidaItem['Importe'] ?? 0).toDouble(),
      um: salidaItem['UM'],
    );
  }

  static List<GetDataSellsModel> parseList(List<dynamic> jsonList) {
    List<GetDataSellsModel> resultList = [];
    
    for (var json in jsonList) {
      if (json['Salidas'] != null && json['Salidas'] is List && (json['Salidas'] as List).isNotEmpty) {
        for (var salida in json['Salidas']) {
          resultList.add(GetDataSellsModel.fromJson(json, salida));
        }
      }
    }
    
    return resultList;
  }

  factory GetDataSellsModel.fromEntity(GetDataSellsEntitie entity) {
    return GetDataSellsModel(
      folio: entity.folio,
      subtotal: entity.subtotal,
      iva: entity.iva,
      total: entity.total,
      formaPago: entity.formaPago,
      fecha: entity.fecha,
      numParte: entity.numParte,
      descripcion: entity.descripcion,
      cantidad: entity.cantidad,
      precio: entity.precio,
      importe: entity.importe,
      um: entity.um,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Folio': folio,
      'Subtotal': subtotal,
      'IVA': iva,
      'Total': total,
      'FormaPago': formaPago,
      'Fecha': fecha,
      'NumParte': numParte,
      'Descripcion': descripcion,
      'Cantidad': cantidad,
      'Precio': precio,
      'Importe': importe,
      'UM': um,
    };
  }
}