import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:BCG_Store/features/rewards/presentation/points/check_point_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/points/points_loading.dart';
import 'package:BCG_Store/features/rewards/presentation/points/widget/expansion_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/points/widget/point_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class PointCard extends StatelessWidget {
  final CheckPointsEntitie checkPoint;
  final bool isPositive;
  final int index;
  final Function(double) formatPoints;
  final ExpansionController expansionController;

  const PointCard({
    Key? key,
    required this.checkPoint,
    required this.isPositive, 
    required this.index,
    required this.formatPoints,
    required this.expansionController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasUsedPoints = checkPoint.puntos_usados > 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Parte superior - siempre visible e interactiva
          InkWell(
            onTap: () {
              expansionController.toggleExpansion(index);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono circular
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF0D8067).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: Color(0xFF0D8067),
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  
                  // Información de la transacción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compra ${checkPoint.folio_venta}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Puntos ganados: ${formatPoints(checkPoint.saldo_puntos)} pts',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Icono de flecha
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          
          // Si hay puntos gastados, mostrar una sección adicional con la estrella roja
          if (hasUsedPoints)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Icono circular rojo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  
                  // Información de los puntos usados
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Puntos utilizados',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Total: ${formatPoints(checkPoint.puntos_usados)} pts',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Parte expandible - detalles
          Obx(() => expansionController.isExpanded(index)
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // Puntos ganados con ícono verde
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(0xFF0D8067).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_circle,
                            color: Color(0xFF0D8067),
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Puntos ganados:',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                        Text(
                          '${formatPoints(checkPoint.puntos_ganados)} pts',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D8067),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    
                    // Fecha de puntos ganados
                    Padding(
                      padding: EdgeInsets.only(left: 36),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fecha:',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          Text(
                            checkPoint.fecha_puntos_ganados,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Separador
                    SizedBox(height: 16),
                    
                    // Puntos usados con ícono rojo (solo si hay puntos usados)
                    if (hasUsedPoints) ...[
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Puntos usados:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ),
                          Text(
                            '${formatPoints(checkPoint.puntos_usados)} pts',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      
                      // Fecha de puntos usados
                      if (checkPoint.fecha_puntos_usados != null)
                        Padding(
                          padding: EdgeInsets.only(left: 36),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fecha:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              Text(
                                checkPoint.fecha_puntos_usados!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 16),
                    ],
                    
                    // Saldo final
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saldo actual:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          Text(
                            '${formatPoints(checkPoint.saldo_puntos)} pts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox.shrink()
          ),
        ],
      ),
    );
  }
}