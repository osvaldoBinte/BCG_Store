import 'package:gerena/features/rewards/domain/entities/check_points_entitie.dart';

class CheckPointModel extends CheckPointsEntitie {
  CheckPointModel({
    required String folio_venta,
    required int id_cliente,
    required double monedero,
    required double minimo_c,
    required double porcentaje,
    required String fecha,
    required String usuario,
  }) : super(
          folio_venta: folio_venta,
          id_cliente: id_cliente,
          monedero: monedero,
          minimo_c: minimo_c,
          porcentaje: porcentaje,
          fecha: fecha,
          usuario: usuario,
        );

  factory CheckPointModel.fromJson(Map<String, dynamic> json) {
    return CheckPointModel(
      folio_venta: json['folio_venta'] ?? '',
      id_cliente: json['id_cliente'] ?? 0,
      monedero: (json['monedero'] ?? 0).toDouble(),
      minimo_c: (json['minimo_c'] ?? 0).toDouble(),
      porcentaje: (json['porcentaje'] ?? 0).toDouble(),
      fecha: json['fecha'] ?? '',
      usuario: json['usuario'] ?? '',
    );
  }

  factory CheckPointModel.fromEntity(CheckPointsEntitie checkPointsEntitie) {
    return CheckPointModel(
      folio_venta: checkPointsEntitie.folio_venta,
      id_cliente: checkPointsEntitie.id_cliente,
      monedero: checkPointsEntitie.monedero,
      minimo_c: checkPointsEntitie.minimo_c,
      porcentaje: checkPointsEntitie.porcentaje,
      fecha: checkPointsEntitie.fecha,
      usuario: checkPointsEntitie.usuario,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folio_venta': folio_venta,
      'id_cliente': id_cliente,
      'monedero': monedero, 
      'minimo_c': minimo_c,
      'porcentaje': porcentaje,
      'fecha': fecha,
      'usuario': usuario,
    };
  }
}