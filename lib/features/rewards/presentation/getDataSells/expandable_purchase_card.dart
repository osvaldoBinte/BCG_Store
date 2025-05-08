import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:BCG_Store/features/rewards/presentation/getDataSells/get_data_sells_controller.dart';

class ExpandablePurchaseCard extends StatelessWidget {
  final GetDataSellsEntitie venta; // Ahora recibimos un objeto completo
  final RxBool isExpanded = false.obs;
  
  // Controlador
  final GetDataSellsController controller = Get.find<GetDataSellsController>();

  ExpandablePurchaseCard({
    Key? key,
    required this.venta,
  }) : super(key: key);

  // Getters para acceder a los datos de la venta
  String get folio => venta.folio ?? '';
  List<SalidaEntitie> get salidas => venta.salidas ?? [];
  String get fecha => venta.fecha ?? '';
  double get total => venta.total ?? 0.0;
  double get subtotal => venta.subtotal ?? 0.0;
  double get iva => venta.iva ?? 0.0;
  String get formaPago => venta.formaPago ?? '';

  String get formattedDate {
    try {
      final parsedDate = DateTime.parse(fecha);
      return DateFormat('dd MMM yyyy', 'es_ES').format(parsedDate);
    } catch (e) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                isExpanded.toggle();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Columna con información principal
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Orden #$folio',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fecha: $formattedDate',
                            style: AppTheme.fieldLabelStyle,
                          ),
                        ],
                      ),
                    ),
                    
                    Obx(() {
                      if (controller.isPurchaseLoadingPoints(folio)) {
                        return SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      } else if (controller.purchaseHasPoints(folio)) {
                        final puntosPorTipo = controller.getPuntosPorTipo(folio);
                        final ganados = puntosPorTipo['GANADOS'] ?? 0;
                        final gastados = puntosPorTipo['GASTADOS'] ?? 0;

                        List<Widget> badges = [];

                        if (ganados > 0) {
                          badges.add(_buildPointsBadge(ganados, Colors.green));
                        }

                        if (gastados > 0) {
                          badges.add(_buildPointsBadge(gastados, Colors.red));
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: badges,
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                     Obx(() => Icon(
              isExpanded.value 
                  ? Icons.keyboard_arrow_up 
                  : Icons.keyboard_arrow_down,
              color: AppTheme.primaryColor,
            )),
                  ],
                ),
              ),
            ),
            
            // Resumen colapsado
            Obx(() => !isExpanded.value 
              ? _buildCollapsedSummary(context) 
              : const SizedBox.shrink()
            ),
            
            // Contenido expandido
            Obx(() => isExpanded.value 
              ? _buildExpandedContent(context) 
              : const SizedBox.shrink()
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsBadge(double puntos, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: color,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            '${puntos.toInt()} Pts',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // Resumen colapsado (solo muestra información básica)
  Widget _buildCollapsedSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGrey,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: AppTheme.fieldLabelStyle,
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: AppTheme.fieldValueStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IVA:',
                style: AppTheme.fieldLabelStyle,
              ),
              Text(
                '\$${iva.toStringAsFixed(2)}',
                style: AppTheme.fieldValueStyle,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Contenido expandido (muestra todos los detalles)
  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        
        // Productos - ahora iteramos sobre la lista de salidas
        ...salidas.map((salida) => _buildProductItem(context, salida)).toList(),
        
        // Pie de la compra
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGrey,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal:',
                    style: AppTheme.fieldLabelStyle,
                  ),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: AppTheme.fieldValueStyle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'IVA:',
                    style: AppTheme.fieldLabelStyle,
                  ),
                  Text(
                    '\$${iva.toStringAsFixed(2)}',
                    style: AppTheme.fieldValueStyle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              /* Comentado como en el original
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Forma de pago:',
                    style: AppTheme.fieldLabelStyle,
                  ),
                  Text(
                    formaPago,
                    style: AppTheme.fieldValueStyle,
                  ),
                ],
              ),
              */
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Item de producto (para el contenido expandido) - ahora recibe un SalidaEntitie
  Widget _buildProductItem(BuildContext context, SalidaEntitie salida) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder para la imagen
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(Icons.medication, color: Colors.grey.shade700, size: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  salida.descripcion ?? 'Sin descripción',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(salida.precio ?? 0).toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cantidad: ${salida.cantidad ?? 0}',
                      style: AppTheme.fieldLabelStyle,
                    ),
                    Text(
                      'Total: \$${(salida.importe ?? 0).toStringAsFixed(2)}',
                      style: AppTheme.fieldValueStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${salida.numParte ?? 'N/A'}',
                  style: AppTheme.fieldLabelStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}