class CheckPointsEntitie {
  final String folio_venta;
  final int id_cliente;
  final double monedero;
  final double minimo_c;
  final double porcentaje;
  final String fecha;
  final String usuario;

  CheckPointsEntitie({
    required this.folio_venta,
    required this.id_cliente,
    required this.monedero,
    required this.minimo_c,
    required this.porcentaje,
    required this.fecha,
    required this.usuario,
  });
}