import 'package:flutter/material.dart';
import 'package:gerena/features/rewards/domain/usecases/get_data_sells_usecase.dart';
import 'package:gerena/features/rewards/presentation/getDataSells/get_data_sells_loading.dart';
import 'package:gerena/features/rewards/presentation/getDataSells/get_data_sells_controller.dart';
import 'package:get/get.dart';
import 'package:gerena/common/routes/navigation_service.dart';
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:intl/intl.dart';

class GetDataSellsPage extends StatelessWidget {
  const GetDataSellsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PurchasesController controller = Get.find<PurchasesController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize();
    });

    return Scaffold(
      backgroundColor: AppTheme.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.backgroundColor),
          onPressed: () async {
            await NavigationService.to.navigateToHome(initialIndex: 1);
          },
        ),
        title: Text('MIS COMPRAS', style: AppTheme.theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Obx(() {
            if (controller.isLoadingStore.value) {
              return Container(
                height: 48,
                child: Center(
                  child: LinearProgressIndicator(
                    color: AppTheme.primaryColor,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
              );
            }
            
            // Si el tabController aún no existe, mostramos un indicador de carga
            if (controller.tabController == null) {
              return Container(
                height: 48,
                child: Center(
                  child: LinearProgressIndicator(
                    color: AppTheme.primaryColor,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
              );
            }
            
            // Si solo hay una pestaña (Tienda)
            if (!controller.isTiendaActiva.value && controller.tabController!.length == 1) {
              return TabBar(
                controller: controller.tabController!,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        color: controller.selectedTab.value == 0
                            ? AppTheme.backgroundGreyDark
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'TIENDA',
                        style: controller.selectedTab.value == 0
                            ? AppTheme.theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              )
                            : AppTheme.theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              );
            } else if (controller.tabController!.length == 2) {
              // Dos pestañas (Online y Tienda)
              return TabBar(
                controller: controller.tabController!,
                indicatorWeight: 3,
                tabs: [
                  // Pestaña Online
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        color: controller.selectedTab.value == 0
                            ? AppTheme.backgroundGreyDark
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'ONLINE',
                        style: controller.selectedTab.value == 0
                            ? AppTheme.theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              )
                            : AppTheme.theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                  
                  // Pestaña Tienda
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        color: controller.selectedTab.value == 1
                            ? AppTheme.backgroundGreyDark
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'TIENDA',
                        style: controller.selectedTab.value == 1
                            ? AppTheme.theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              )
                            : AppTheme.theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Estado de carga inicial
              return Center(
                child: Container(
                  height: 48,
                  child: LinearProgressIndicator(
                    color: AppTheme.primaryColor,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
              );
            }
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingStore.value) {
          return Center(
            child: GetDataSellsLoading(
            ),
          );
        }
        
        if (controller.tabController == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
                SizedBox(height: 16),
                Text(
                  'Inicializando...',
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    controller.initialize();
                  },
                  child: Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Si hay un error al cargar
        if (controller.hasErrorStore.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar compras',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    controller.errorMessageStore.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.retryFetchStoreItems(),
                  icon: Icon(Icons.refresh),
                  label: Text('Reintentar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.backgroundColor,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }
        
        return TabBarView(
          controller: controller.tabController!,
          children: [
            if (controller.isTiendaActiva.value)
              _buildEmptyStateOnline(context), 
            
            _buildPurchasesListFromAPI(context, controller),
          ],
        );
      }),
      floatingActionButton: Obx(() => controller.isLoadingStore.value
        ? SizedBox() 
        : FloatingActionButton(
            onPressed: () {
              controller.forceReload();
             
            },
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.refresh, color: AppTheme.backgroundColor),
          )
      ),
    );
  }

  Widget _buildEmptyStateOnline(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: AppTheme.iconGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Todavía no has realizado ningún pedido online',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await NavigationService.to.navigateToHome(initialIndex: 0);
              },
              child: const Text('Llévame a comprar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.secondaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Estado vacío para la sección TIENDA (sin botón)
  Widget _buildEmptyStateTienda(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: 64,
            color: AppTheme.iconGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron compras en tienda física',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Las compras realizadas en tienda aparecerán aquí',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Nuevo método para mostrar las compras desde la API
  Widget _buildPurchasesListFromAPI(BuildContext context, PurchasesController controller) {
    if (controller.purchasesByFolio.isEmpty) {
      // Si estamos en la pestaña de tienda física, mostramos el estado vacío sin botón
      if (!controller.isTiendaActiva.value || controller.selectedTab.value == 1) {
        return _buildEmptyStateTienda(context);
      } else {
        // Si estamos en la pestaña online, mostramos el estado vacío con botón
        return _buildEmptyStateOnline(context);
      }
    }

    final folios = controller.purchasesByFolio.keys.toList();
    folios.sort((a, b) => b.compareTo(a)); // Ordenar por folio descendente (más reciente primero)

    return RefreshIndicator(
      onRefresh: () => controller.forceReload(),
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: folios.length,
        itemBuilder: (context, index) {
          final folio = folios[index];
          final items = controller.purchasesByFolio[folio] ?? [];
          return _buildPurchaseCardFromAPI(context, controller, folio, items);
        },
      ),
    );
  }

  Widget _buildPurchaseCardFromAPI(BuildContext context, PurchasesController controller, String folio, List items) {
    final theme = Theme.of(context);
    final fecha = controller.getPurchaseDate(folio);
    final total = controller.getPurchaseTotal(folio);
    final subtotal = controller.getPurchaseSubtotal(folio);
    final iva = controller.getPurchaseIVA(folio);
    final formaPago = controller.getPurchasePaymentMethod(folio);
    
    // Formato de fecha
    String formattedDate = '';
    try {
      final parsedDate = DateTime.parse(fecha);
      formattedDate = DateFormat('dd MMM yyyy', 'es_ES').format(parsedDate);
    } catch (e) {
      formattedDate = fecha;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado de la compra
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Entregado',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Productos
          ...items.map((item) => _buildProductItemFromAPI(context, item)).toList(),
          
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
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
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
      ),
    );
  }

  Widget _buildProductItemFromAPI(BuildContext context, dynamic item) {
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
                  item.descripcion ?? 'Sin descripción',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(item.precio ?? 0).toStringAsFixed(2)}',
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
                      'Cantidad: ${item.cantidad ?? 0}',
                      style: AppTheme.fieldLabelStyle,
                    ),
                    Text(
                      'Total: \$${(item.importe ?? 0).toStringAsFixed(2)}',
                      style: AppTheme.fieldValueStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${item.numParte ?? 'N/A'}',
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