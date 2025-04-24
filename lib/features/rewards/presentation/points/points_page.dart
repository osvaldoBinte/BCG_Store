import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:BCG_Store/features/rewards/presentation/points/EarnedPointCard.dart';
import 'package:BCG_Store/features/rewards/presentation/points/check_point_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/points/points_loading.dart';
import 'package:BCG_Store/features/rewards/presentation/points/widget/expansion_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/points/widget/point_card.dart';
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
    List<PointTransaction> allTransactions = [];
    
    // Crear transacciones combinadas de ambas fuentes
    for (var checkPoint in controller.checkPoints) {
      // Si tiene puntos ganados, agregar transacción de ganancia
      if (checkPoint.puntos_ganados > 0) {
        allTransactions.add(PointTransaction(
          checkPoint: checkPoint,
          isEarning: true,
          transactionDate: checkPoint.fecha_puntos_ganados,
        ));
      }
      
      // Si tiene puntos usados, agregar transacción de gasto
      if (checkPoint.puntos_usados > 0 && checkPoint.fecha_puntos_usados != null) {
        allTransactions.add(PointTransaction(
          checkPoint: checkPoint,
          isEarning: false,
          transactionDate: checkPoint.fecha_puntos_usados!,
        ));
      }
    }
    
    // Ordenar transacciones por fecha (más reciente primero)
    allTransactions.sort((a, b) {
      DateTime dateA = _parseDate(a.transactionDate);
      DateTime dateB = _parseDate(b.transactionDate);
      return dateB.compareTo(dateA); // Orden descendente
    });
    
    // Controlador de expansión para los cards
    final expansionController = Get.put(ExpansionController(
      itemCount: allTransactions.length,
      initialExpandedIndex: allTransactions.isNotEmpty ? 0 : -1
    ));
    
    // Crear las tarjetas para cada transacción
    List<Widget> cards = [];
    for (int i = 0; i < allTransactions.length; i++) {
      PointTransaction transaction = allTransactions[i];
      
      if (transaction.isEarning) {
        cards.add(
          EarnedPointCard(
            checkPoint: transaction.checkPoint,
            index: i,
            formatPoints: controller.formatPoints,
            expansionController: expansionController,
          )
        );
      } else {
        cards.add(
          UsedPointCard(
            checkPoint: transaction.checkPoint,
            index: i,
            formatPoints: controller.formatPoints,
            expansionController: expansionController,
          )
        );
      }
    }
    
    return Column(
      children: [
        // Cabecera con puntos totales
        _buildHeaderSection(),
        
        // Lista de puntos
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.refreshCheckPoints(),
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                return cards[index];
              },
            ),
          ),
        ),
      ],
    );
  }
  
  // Función auxiliar para convertir string de fecha a objeto DateTime
  DateTime _parseDate(String dateStr) {
    try {
      // Intentar analizar la fecha en formato YYYY-MM-DD
      List<String> parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[0]), // año
          int.parse(parts[1]), // mes
          int.parse(parts[2].split(' ')[0])  // día (removiendo cualquier parte de hora)
        );
      }
    } catch (e) {
      print('Error al analizar fecha: $dateStr');
    }
    // Devolver una fecha antigua por defecto si hay error
    return DateTime(2000, 1, 1);
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

  Widget _buildLoadingView() {
    return PointsLoading();
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
  
  // Vista para cuando no hay puntos (resultado vacío o 404)
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