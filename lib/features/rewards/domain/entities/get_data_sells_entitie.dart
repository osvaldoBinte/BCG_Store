// Archivo: get_data_sells_entitie.dart

// Entidad para una salida (producto)
class SalidaEntitie {
  final String? numParte;
  final String? descripcion;
  final double? cantidad;
  final double? precio;
  final double? importe;
  final String? um;

  SalidaEntitie({
    this.numParte,
    this.descripcion,
    this.cantidad,
    this.precio,
    this.importe,
    this.um,
  });
}

// Entidad principal para la venta
class GetDataSellsEntitie {
  final String? folio;
  final double? subtotal;
  final double? iva;
  final double? total;
  final String? formaPago;
  final String? fecha;
  final String? tipoPuntos;
  final double? puntos;
  final int? ventaId;
  final int? orden;
  final List<SalidaEntitie>? salidas; // Lista de productos (salidas)

  GetDataSellsEntitie({
    this.folio,
    this.subtotal,
    this.iva,
    this.total,
    this.formaPago,
    this.fecha,
    this.tipoPuntos,
    this.puntos,
    this.ventaId,
    this.orden,
    this.salidas,
  });
}