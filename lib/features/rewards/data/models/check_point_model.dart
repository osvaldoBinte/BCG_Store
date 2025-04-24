import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';

class CheckPointModel extends CheckPointsEntitie {
  CheckPointModel({
    required String folio_venta,
    required double puntos_ganados,
    required String fecha_puntos_ganados,
    required double puntos_usados,
    String? fecha_puntos_usados,
    required double saldo_puntos,
    double? monedero,
    double? minimo_c,
    double? porcentaje,
    String? usuario,
    double? importe,
    int? id_cliente,
  }) : super(
          folio_venta: folio_venta,
          puntos_ganados: puntos_ganados,
          fecha_puntos_ganados: fecha_puntos_ganados,
          puntos_usados: puntos_usados,
          fecha_puntos_usados: fecha_puntos_usados,
          saldo_puntos: saldo_puntos,
          monedero: monedero,
          minimo_c: minimo_c,
          porcentaje: porcentaje,
          usuario: usuario,
          importe: importe,
          id_cliente: id_cliente,
        );

  factory CheckPointModel.fromJson(Map<String, dynamic> json) {
    // Para determinar si estamos manejando puntos ganados o gastados
    final bool isPuntosGanados = json.containsKey('monedero');
    final bool isPuntosGastados = json.containsKey('puntos');
    
    if (isPuntosGanados) {
      // Mapear desde la respuesta de Ventas_Fidelizacion
      return CheckPointModel(
        folio_venta: json['folio_venta'] ?? '',
        puntos_ganados: (json['monedero'] ?? 0).toDouble(),
        fecha_puntos_ganados: json['fecha'] ?? '',
        puntos_usados: 0,
        fecha_puntos_usados: null,
        saldo_puntos: (json['monedero'] ?? 0).toDouble(),
        monedero: (json['monedero'] ?? 0).toDouble(),
        minimo_c: (json['minimo_c'] ?? 0).toDouble(),
        porcentaje: (json['porcentaje'] ?? 0).toDouble(),
        usuario: json['usuario'] ?? '',
        id_cliente: json['id_cliente'],
      );
    } else if (isPuntosGastados) {
      // Mapear desde la respuesta de Ventas_ConPuntos
      return CheckPointModel(
        folio_venta: json['folio'] ?? '',
        puntos_ganados: 0,
        fecha_puntos_ganados: '',  // No hay fecha de puntos ganados en este caso
        puntos_usados: (json['puntos'] ?? 0).toDouble(),
        fecha_puntos_usados: json['fec'] ?? '',
        saldo_puntos: -(json['puntos'] ?? 0).toDouble(),  // Negativo porque son puntos usados
        usuario: json['usuario'] ?? '',
        importe: (json['importe'] ?? 0).toDouble(),
        id_cliente: json['id_cliente'],
      );
    } else {
      // Si ya viene en el formato unificado que espera la app
      return CheckPointModel(
        folio_venta: json['folio_venta'] ?? '',
        puntos_ganados: (json['puntos_ganados'] ?? 0).toDouble(),
        fecha_puntos_ganados: json['fecha_puntos_ganados'] ?? '',
        puntos_usados: (json['puntos_usados'] ?? 0).toDouble(),
        fecha_puntos_usados: json['fecha_puntos_usados'],
        saldo_puntos: (json['saldo_puntos'] ?? 0).toDouble(),
        monedero: json['monedero']?.toDouble(),
        minimo_c: json['minimo_c']?.toDouble(),
        porcentaje: json['porcentaje']?.toDouble(),
        usuario: json['usuario'],
        importe: json['importe']?.toDouble(),
        id_cliente: json['id_cliente'],
      );
    }
  }

  factory CheckPointModel.fromEntity(CheckPointsEntitie checkPointsEntitie) {
    return CheckPointModel(
      folio_venta: checkPointsEntitie.folio_venta,
      puntos_ganados: checkPointsEntitie.puntos_ganados,
      fecha_puntos_ganados: checkPointsEntitie.fecha_puntos_ganados,
      puntos_usados: checkPointsEntitie.puntos_usados,
      fecha_puntos_usados: checkPointsEntitie.fecha_puntos_usados,
      saldo_puntos: checkPointsEntitie.saldo_puntos,
      monedero: checkPointsEntitie.monedero,
      minimo_c: checkPointsEntitie.minimo_c,
      porcentaje: checkPointsEntitie.porcentaje,
      usuario: checkPointsEntitie.usuario,
      importe: checkPointsEntitie.importe,
      id_cliente: checkPointsEntitie.id_cliente,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folio_venta': folio_venta,
      'puntos_ganados': puntos_ganados,
      'fecha_puntos_ganados': fecha_puntos_ganados,
      'puntos_usados': puntos_usados,
      'fecha_puntos_usados': fecha_puntos_usados,
      'saldo_puntos': saldo_puntos,
      'monedero': monedero,
      'minimo_c': minimo_c,
      'porcentaje': porcentaje,
      'usuario': usuario,
      'importe': importe,
      'id_cliente': id_cliente,
    };
  }
}