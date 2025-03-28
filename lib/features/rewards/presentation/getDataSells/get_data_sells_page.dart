import 'package:BCG_Store/common/constants/constants.dart';
import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:BCG_Store/features/rewards/presentation/getDataSells/get_data_sells_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/getDataSells/get_data_sells_loading.dart';
import 'package:BCG_Store/framework/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
class GetDataSellsPage extends StatefulWidget {
  const GetDataSellsPage({Key? key}) : super(key: key);

  @override
  State<GetDataSellsPage> createState() => _GetDataSellsPageState();
}

class _GetDataSellsPageState extends State<GetDataSellsPage> with TickerProviderStateMixin {
  late GetDataSellsController controller;
  TabController? tabController;
  final RxInt selectedTab = 0.obs;
  final RxBool isTiendaActiva = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<GetDataSellsController>();
    
    _checkTiendaActiva();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDataSells();
    });
  }

  Future<void> _checkTiendaActiva() async {
    try {
      final PreferencesUser prefsUser = PreferencesUser();
      final sessionJson = await prefsUser.loadPrefs(
        type: String,
        key: AppConstants.sessionKey
      );
      
      if (sessionJson != null && sessionJson.isNotEmpty) {
        final Map<String, dynamic> sessionMap = jsonDecode(sessionJson);
        isTiendaActiva.value = sessionMap['tienda_activa'] == "1";
        
        _initializeTabController();
      } else {
        isTiendaActiva.value = false;
        _initializeTabController();
      }
    } catch (e) {
      print('❌ Error al verificar tienda_activa: $e');
      isTiendaActiva.value = false;
      _initializeTabController();
    }
  }

  void _initializeTabController() {
    // Si tienda_activa es true, mostrar dos pestañas, si no, solo una (Tienda)
    int numberOfTabs = isTiendaActiva.value ? 2 : 1;
    
    // Disponer el controlador anterior si existe
    tabController?.dispose();
    
    // Crear un nuevo controlador con el número correcto de pestañas
    tabController = TabController(length: numberOfTabs, vsync: this);
    tabController!.addListener(() {
      selectedTab.value = tabController!.index;
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  // Método para recargar los datos
  void forceReload() {
    controller.fetchDataSells();
  }

  String getPurchaseDate(String folio) {
    final purchase = controller.buscarVentaPorFolio(folio);
    return purchase?.fecha ?? 'Fecha no disponible';
  }

  double getPurchaseTotal(String folio) {
    final purchase = controller.buscarVentaPorFolio(folio);
    return purchase?.total ?? 0.0;
  }

  double getPurchaseSubtotal(String folio) {
    final purchase = controller.buscarVentaPorFolio(folio);
    return purchase?.subtotal ?? 0.0;
  }

  double getPurchaseIVA(String folio) {
    final purchase = controller.buscarVentaPorFolio(folio);
    return purchase?.iva ?? 0.0;
  }

  String getPurchasePaymentMethod(String folio) {
    final purchase = controller.buscarVentaPorFolio(folio);
    return purchase?.formaPago ?? 'No disponible';
  }

  Map<String, List<GetDataSellsEntitie>> get purchasesByFolio {
    Map<String, List<GetDataSellsEntitie>> result = {};
    
    for (var item in controller.sellsList) {
      if (item.folio != null) {
        if (!result.containsKey(item.folio)) {
          result[item.folio!] = [];
        }
        result[item.folio!]!.add(item);
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
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
            if (controller.isLoading.value || tabController == null) {
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
            if (!isTiendaActiva.value && tabController!.length == 1) {
              return TabBar(
                controller: tabController!,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedTab.value == 0
                            ? AppTheme.backgroundGreyDark
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'TIENDA',
                        style: selectedTab.value == 0
                            ? AppTheme.theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              )
                            : AppTheme.theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              );
            } else if (isTiendaActiva.value && tabController!.length == 2) {
              // Dos pestañas (Online y Tienda)
              return TabBar(
                controller: tabController!,
                indicatorWeight: 3,
                tabs: [
                  // Pestaña Online
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        color: selectedTab.value == 0
                            ? AppTheme.backgroundGreyDark
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'ONLINE',
                        style: selectedTab.value == 0
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
                        color: selectedTab.value == 1
                            ? AppTheme.backgroundGreyDark
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'TIENDA',
                        style: selectedTab.value == 1
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
              // Estado de carga inicial o inconsistencia
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
        if (controller.isLoading.value || tabController == null) {
          return Center(
            child: GetDataSellsLoading(),
          );
        }
        
        // Solo mostrar error si hay un mensaje de error y NO es una respuesta vacía
        if (controller.errorMessage.value.isNotEmpty && !controller.emptyResponse.value) {
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
                    controller.errorMessage.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => controller.fetchDataSells(),
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
        
        // Construir el TabBarView con el número correcto de pestañas
        if (isTiendaActiva.value && tabController!.length == 2) {
          return TabBarView(
            controller: tabController!,
            children: [
              _buildEmptyStateOnline(context),
              _buildPurchasesListFromAPI(context),
            ],
          );
        } else {
          // Si solo hay una pestaña (Tienda)
          return TabBarView(
            controller: tabController!,
            children: [
              _buildPurchasesListFromAPI(context),
            ],
          );
        }
      }),
      floatingActionButton: Obx(() => controller.isLoading.value
        ? SizedBox() 
        : FloatingActionButton(
            onPressed: () {
              forceReload();
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
  Widget _buildPurchasesListFromAPI(BuildContext context) {
    if (purchasesByFolio.isEmpty) {
      // Si estamos en la pestaña de tienda física o solo hay una pestaña
      if (!isTiendaActiva.value || selectedTab.value == 1 || tabController!.length == 1) {
        return _buildEmptyStateTienda(context);
      } else {
        // Si estamos en la pestaña online
        return _buildEmptyStateOnline(context);
      }
    }

    final folios = purchasesByFolio.keys.toList();
    folios.sort((a, b) => b.compareTo(a)); // Ordenar por folio descendente (más reciente primero)

    return RefreshIndicator(
      onRefresh: () async => forceReload(),
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: folios.length,
        itemBuilder: (context, index) {
          final folio = folios[index];
          final items = purchasesByFolio[folio] ?? [];
          return _buildPurchaseCardFromAPI(context, folio, items);
        },
      ),
    );
  }

  Widget _buildPurchaseCardFromAPI(BuildContext context, String folio, List<GetDataSellsEntitie> items) {
    final theme = Theme.of(context);
    final fecha = getPurchaseDate(folio);
    final total = getPurchaseTotal(folio);
    final subtotal = getPurchaseSubtotal(folio);
    final iva = getPurchaseIVA(folio);
    final formaPago = getPurchasePaymentMethod(folio);
    
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

  Widget _buildProductItemFromAPI(BuildContext context, GetDataSellsEntitie item) {
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