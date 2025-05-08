// Archivo: salida_model.dart
import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';

class SalidaModel extends SalidaEntitie {
  SalidaModel({
    required String? numParte,
    required String? descripcion,
    required double? cantidad,
    required double? precio,
    required double? importe,
    required String? um,
  }) : super(
          numParte: numParte,
          descripcion: descripcion,
          cantidad: cantidad,
          precio: precio,
          importe: importe,
          um: um,
        );

  factory SalidaModel.fromJson(Map<String, dynamic> json) {
    return SalidaModel(
      numParte: json['NumParte'],
      descripcion: json['Descripcion'],
      cantidad: (json['Cantidad'] ?? 0).toDouble(),
      precio: (json['Precio'] ?? 0).toDouble(),
      importe: (json['Importe'] ?? 0).toDouble(),
      um: json['UM'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NumParte': numParte,
      'Descripcion': descripcion,
      'Cantidad': cantidad,
      'Precio': precio,
      'Importe': importe,
      'UM': um,
    };
  }
}

// Archivo: get_data_sells_model.dart
class GetDataSellsModel extends GetDataSellsEntitie {
  GetDataSellsModel({
    required String? folio,
    required double? subtotal,
    required double? iva,
    required double? total,
    required String? formaPago,
    required String? fecha,
    required String? tipoPuntos,
    required double? puntos,
    required int? ventaId,
    required int? orden,
    required List<SalidaEntitie>? salidas,
  }) : super(
          folio: folio,
          subtotal: subtotal,
          iva: iva,
          total: total,
          formaPago: formaPago,
          fecha: fecha,
          tipoPuntos: tipoPuntos,
          puntos: puntos,
          ventaId: ventaId,
          orden: orden,
          salidas: salidas,
        );

  factory GetDataSellsModel.fromJson(Map<String, dynamic> json) {
    // Procesamos las salidas si existen
    List<SalidaEntitie>? salidas;
    if (json['Salidas'] != null) {
      salidas = <SalidaEntitie>[];
      json['Salidas'].forEach((salida) {
        salidas!.add(SalidaModel.fromJson(salida));
      });
    }

    return GetDataSellsModel(
      folio: json['Folio'],
      subtotal: (json['Subtotal'] ?? 0).toDouble(),
      iva: (json['IVA'] ?? 0).toDouble(),
      total: (json['Total'] ?? 0).toDouble(),
      formaPago: json['FormaPago'],
      fecha: json['Fecha'],
      tipoPuntos: json['TipoPuntos'],
      puntos: (json['Puntos'] ?? 0).toDouble(),
      ventaId: json['VentaId'],
      orden: json['Orden'],
      salidas: salidas,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'Folio': folio,
      'Subtotal': subtotal,
      'IVA': iva,
      'Total': total,
      'FormaPago': formaPago,
      'Fecha': fecha,
      'TipoPuntos': tipoPuntos,
      'Puntos': puntos,
      'VentaId': ventaId,
      'Orden': orden,
    };

    if (salidas != null) {
      data['Salidas'] = salidas!.map((salida) {
        if (salida is SalidaModel) {
          return salida.toJson();
        } else {
          // Si no es un SalidaModel, convertirlo manualmente
          return {
            'NumParte': salida.numParte,
            'Descripcion': salida.descripcion,
            'Cantidad': salida.cantidad,
            'Precio': salida.precio,
            'Importe': salida.importe,
            'UM': salida.um,
          };
        }
      }).toList();
    }

    return data;
  }
}