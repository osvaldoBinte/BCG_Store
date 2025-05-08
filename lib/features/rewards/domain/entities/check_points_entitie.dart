class CheckPointsEntitie {
  final String folio_venta;
  final double puntos_ganados;
  final String fecha_puntos_ganados;
  final double puntos_usados;
  final String? fecha_puntos_usados;
  final double saldo_puntos;
  
  // Campos adicionales que podrían venir del backend
  final double? monedero;
  final double? minimo_c;
  final double? porcentaje;
  final String? usuario;
  
  // Para puntos gastados
  final double? importe;
  final String? id_cliente;
  final int? ventaId;

  CheckPointsEntitie({
    required this.folio_venta,
    required this.puntos_ganados,
    required this.fecha_puntos_ganados,
    required this.puntos_usados,
     this.ventaId,
    this.fecha_puntos_usados,
    required this.saldo_puntos,
    this.monedero,
    this.minimo_c,
    this.porcentaje,
    this.usuario,
    this.importe,
    this.id_cliente,
  });
}