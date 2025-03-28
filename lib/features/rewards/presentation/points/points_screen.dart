import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:BCG_Store/features/rewards/presentation/points/check_point_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/points/points_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PointsScreen extends GetView<CheckPointController> {
  const PointsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCheckPoints();
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.secondaryColor),
          onPressed: () async {
            await NavigationService.to.navigateToHome(initialIndex: 0);
          },
        ),
        title: Text(
          'MIS PUNTOS',
          style: TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingView();
        } else if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorView();
        } else if (controller.hasNoPoints.value) {
          return _buildEmptyView(context);
        } else {
          return _buildContentView(context);
        }
      }),
    );
  }

  Widget _buildContentView(BuildContext context) {
    // Creamos el controlador de expansión
    final expansionController = Get.put(ExpansionController(
      itemCount: controller.checkPoints.length,
      initialExpandedIndex: 0 // Primer elemento expandido inicialmente
    ));
    
    return Column(
      children: [
        // Cabecera con puntos totales
        _buildHeaderSection(),
        
        // Lista de puntos
        Expanded(
          child: _buildPointsList(context, expansionController),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 10, bottom: 30, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${controller.formattedTotalPoints} PTS',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsList(BuildContext context, ExpansionController expansionController) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.checkPoints.length,
      itemBuilder: (context, index) {
        final checkPoint = controller.checkPoints[index];
        // El primer elemento es negativo (rojo), el resto positivos
        final bool isPositive = index != 0;
        
        return PointCard(
          checkPoint: checkPoint,
          isPositive: isPositive,
          index: index,
          formatPoints: controller.formatPoints,
          expansionController: expansionController,
        );
      },
    );
  }

  Widget _buildLoadingView() {
    return PointsLoading(
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red.withOpacity(0.8),
          ),
          SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.fetchCheckPoints(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Reintentar',
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Nuevo: Vista para cuando no hay puntos (resultado vacío o 404)
  Widget _buildEmptyView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshCheckPoints(),
      color: AppTheme.primaryColor,
      child: SingleChildScrollView( // Necesario para que RefreshIndicator funcione
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
          child: Column(
            children: [
              // Cabecera simplificada
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(top: 10, bottom: 30, left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '0 PTS',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido de estado vacío
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono circular grande
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.stars,
                          color: AppTheme.primaryColor,
                          size: 50,
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Mensaje principal
                      Text(
                        'No tienes puntos disponibles',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Realiza compras para comenzar a acumular puntos y obtener beneficios exclusivos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      
                      // Botón para ir a comprar
                      ElevatedButton(
                        onPressed: () async {
                          await NavigationService.to.navigateToHome(initialIndex: 0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.secondaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Volver a la página principal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpansionController extends GetxController {
  late List<RxBool> expandedItems;
  
  ExpansionController({
    required int itemCount,
    int? initialExpandedIndex,
  }) {
    expandedItems = List.generate(
      itemCount,
      (index) => (index == initialExpandedIndex).obs
    );
  }
  
  void toggleExpansion(int index) {
    expandedItems[index].value = !expandedItems[index].value;
  }
  
  bool isExpanded(int index) {
    return expandedItems[index].value;
  }
}

// Widget de tarjeta para cada punto
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
    final String points = formatPoints(checkPoint.monedero);
    
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
              // Toggle para expandir/contraer cuando se toca
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
                      color: isPositive
                          ? Color(0xFF0D8067).withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      color: isPositive ? Color(0xFF0D8067) : Colors.red,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  
                  // Texto "Puntos"
                  Expanded(
                    child: Text(
                      'Puntos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isPositive ? Color(0xFF0D8067) : Colors.red,
                      ),
                    ),
                  ),
                  
                  // Cantidad de puntos
                  Text(
                    '$points pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  
                  // Icono de flecha
                  SizedBox(width: 8),
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Color(0xFF0D8067) : Colors.red,
                  ),
                ],
              ),
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
                    _buildDetailRow(
                      context: context,
                      label: 'Compra',
                      value: checkPoint.folio_venta,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow(
                      context: context,
                      label: 'Fecha',
                      value: checkPoint.fecha,
                    ),
                    SizedBox(height: 8),
                    _buildDetailRow(
                      context: context,
                      label: 'Puntos Obtenidos',
                      value: '$points pts',
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

  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}