import 'package:BCG_Store/common/constants/constants.dart';
import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:BCG_Store/features/rewards/presentation/getDataSells/expandable_purchase_card.dart';
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
        
        if (isTiendaActiva.value && tabController!.length == 2) {
          return TabBarView(
            controller: tabController!,
            children: [
              _buildEmptyStateOnline(context),
              _buildPurchasesListFromAPI(context),
            ],
          );
        } else {
          return TabBarView(
            controller: tabController!,
            children: [
              _buildPurchasesListFromAPI(context),
            ],
          );
        }
      }),
      
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
Widget _buildPurchasesListFromAPI(BuildContext context) {
  if (controller.sellsList.isEmpty) {
    if (!isTiendaActiva.value || selectedTab.value == 1 || tabController!.length == 1) {
      return _buildEmptyStateTienda(context);
    } else {
      return _buildEmptyStateOnline(context);
    }
  }

  final purchases = controller.sellsList.toList();

  return RefreshIndicator(
    onRefresh: () async => forceReload(),
    color: AppTheme.primaryColor,
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final venta = purchases[index];
        return ExpandablePurchaseCard(
          venta: venta,
        );
      },
    ),
  );
}
}