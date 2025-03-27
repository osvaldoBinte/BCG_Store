import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gerena/common/routes/navigation_service.dart';
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:gerena/common/services/auth_service.dart';
import 'package:gerena/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:gerena/features/rewards/domain/usecases/get_data_sells_usecase.dart';

class PurchasesController extends GetxController with GetSingleTickerProviderStateMixin {
  TabController? tabController;
  final RxInt selectedTab = 0.obs;
  final RxBool isTiendaActiva = false.obs;
  
  final GetDataSellsUsecase getDataSellsUsecase;
  final AuthService authService = AuthService();
  
  final RxList storeItems = [].obs;
  final RxBool isLoadingStore = true.obs;
  final RxBool hasErrorStore = false.obs;
  final RxString errorMessageStore = "".obs;
  
  final RxMap<String, List> purchasesByFolio = <String, List>{}.obs;
  
  final RxBool hasAttemptedToLoad = false.obs;
  
  final RxBool isInitialized = false.obs;

  PurchasesController({required this.getDataSellsUsecase});

  @override
  void onInit() {
    super.onInit();
  }
  
  Future<void> initialize() async {
    if (isInitialized.value) {
      print('🔍 Controller ya inicializado, verificando estado...');
      if (isLoadingStore.value && hasAttemptedToLoad.value) {
        print('⚠️ Detectado estado de carga indefinido, reiniciando controller...');
        await resetAndReload();
        return;
      }
      return;
    }
    
    resetData();
    await checkTiendaStatus();
    await setupTabController();
    await fetchStoreItems();
    
    isInitialized.value = true;
  }
  
  Future<void> resetAndReload() async {
    print('🔄 Reiniciando completamente el controlador...');
    isInitialized.value = false;
    resetData();
    await checkTiendaStatus();
    await setupTabController();
    
    // Asegurarse de reiniciar el estado de carga
    isLoadingStore.value = true;
    hasAttemptedToLoad.value = false;
    
    // Intentar cargar de nuevo
    await fetchStoreItems();
    isInitialized.value = true;
  }
  
  // Método para reiniciar todos los datos del controlador
  void resetData() {
    print('🧹 Limpiando datos antiguos...');
    // Limpiar los datos antiguos para evitar mostrar datos de otro usuario
    storeItems.clear();
    purchasesByFolio.clear();
    isLoadingStore.value = true;
    hasErrorStore.value = false;
    errorMessageStore.value = "";
    
    // Resetear el controlador de tabs si existe
    if (tabController != null) {
      tabController!.removeListener(_tabListener);
      tabController!.dispose();
      tabController = null;
    }
  }
  
  // Método separado para verificar el estado de la tienda
  Future<void> checkTiendaStatus() async {
    try {
      final session = await authService.getSession();
      
      if (session != null) {
        // Comprobar si la tienda está activa (1) o inactiva (0)
        final tiendaStatus = session.tienda_activa == "1";
        isTiendaActiva.value = tiendaStatus;
        
        print('✅ Estado de la tienda: ${tiendaStatus ? "Activa" : "Inactiva"}');
      } else {
        // Si no hay sesión, asumimos que la tienda no está activa
        isTiendaActiva.value = false;
        print('❌ No hay sesión activa');
      }
    } catch (e) {
      print('❌ Error al verificar el estado de la tienda: $e');
      // Por defecto, si hay un error, no mostramos la tienda online
      isTiendaActiva.value = false;
    }
  }
  
  // Configurar el TabController
  Future<void> setupTabController() async {
    // Asegurarnos de que el controlador anterior ha sido eliminado
    if (tabController != null) {
      tabController!.removeListener(_tabListener);
      tabController!.dispose();
    }
    
    try {
      // Inicializar el TabController basado en si la tienda está activa
      tabController = TabController(
        length: isTiendaActiva.value ? 2 : 1, 
        vsync: this
      );
      
      // Configurar listener para cambios de tab
      tabController!.addListener(_tabListener);
      
      // Establecer la pestaña inicial (se carga siempre la tienda física)
      selectedTab.value = isTiendaActiva.value ? 1 : 0;
      tabController!.index = selectedTab.value;
      
      print('✅ TabController configurado correctamente');
      update(); // Notificar a los widgets que el TabController está listo
    } catch (e) {
      print('❌ Error configurando TabController: $e');
      // En caso de error, inicializamos con valores predeterminados
      tabController = TabController(length: 1, vsync: this);
      selectedTab.value = 0;
      update();
    }
  }
  
  // Método separado para el listener del TabController
  void _tabListener() {
    if (tabController != null && tabController!.index != selectedTab.value) {
      selectedTab.value = tabController!.index;
      
      // Cargar datos de tienda si se selecciona la pestaña de tienda
      final tiendaTabIndex = isTiendaActiva.value ? 1 : 0;
      if (selectedTab.value == tiendaTabIndex && storeItems.isEmpty && !isLoadingStore.value) {
        fetchStoreItems();
      }
    }
  }
  
  // Método para obtener los datos de compras en tienda
  Future<void> fetchStoreItems() async {
    // Marcamos que se ha intentado cargar al menos una vez
    hasAttemptedToLoad.value = true;
    
    try {
      print('🔄 Cargando datos de compras...');
      isLoadingStore.value = true;
      hasErrorStore.value = false;
      errorMessageStore.value = "";
      
      // Llamar al caso de uso para obtener los datos
      final items = await getDataSellsUsecase.execute();
      
      // Verificar si se obtuvieron datos
      if (items.isEmpty) {
        print('⚠️ No se encontraron compras, reintentando...');
        // Reintentar después de un pequeño retraso
        await Future.delayed(Duration(milliseconds: 1000));
        final retryItems = await getDataSellsUsecase.execute();
        
        if (retryItems.isNotEmpty) {
          print('✅ Datos obtenidos en segundo intento: ${retryItems.length} items');
          storeItems.clear();
          storeItems.addAll(retryItems);
          // Agrupar los items por folio (número de compra)
          _groupItemsByFolio();
        } else {
          print('⚠️ No se encontraron compras después del reintento - Lista vacía');
          storeItems.clear();
          purchasesByFolio.clear(); // Asegurar que se limpien los datos antiguos
        }
      } else {
        print('✅ Datos obtenidos en primer intento: ${items.length} items');
        storeItems.clear();
        storeItems.addAll(items);
        // Agrupar los items por folio (número de compra)
        _groupItemsByFolio();
      }
      
    } catch (e) {
      print('❌ Error al cargar compras en tienda: $e');
      hasErrorStore.value = true;
      errorMessageStore.value = e.toString();
      
      // Verificar si es un error de tipo 404 o "No encontrado"
      if (e.toString().contains('404') || 
          e.toString().contains('Not Found') || 
          e.toString().contains('no encontrado') ||
          e.toString().contains('No encontrado')) {
        print('ℹ️ Error 404 o "no encontrado" - Tratando como lista vacía');
        hasErrorStore.value = false;
        errorMessageStore.value = "";
      }
      
      // Limpiar los datos para asegurar que no se muestren datos antiguos
      storeItems.clear();
      purchasesByFolio.clear();
    } finally {
      print('✅ Finalizando carga de datos. Estado: error=${hasErrorStore.value}, items=${storeItems.length}');
      isLoadingStore.value = false;
      update();
    }
  }
  
  // Método para recargar datos forzadamente
  Future<void> forceReload() async {
    await fetchStoreItems();
  }
  
  void _groupItemsByFolio() {
    Map<String, List<GetDataSellsEntitie>> grouped = {};
    
    for (var item in storeItems) {
      if (item.folio != null) {
        if (!grouped.containsKey(item.folio)) {
          grouped[item.folio!] = [];
        }
        grouped[item.folio!]!.add(item);
      }
    }
    
    purchasesByFolio.clear();
    purchasesByFolio.addAll(grouped);
    
    print('📊 Compras agrupadas por folio: ${purchasesByFolio.length} folios diferentes');
  }
  
  String getPurchaseDate(String folio) {
    if (purchasesByFolio.containsKey(folio) && purchasesByFolio[folio]!.isNotEmpty) {
      return purchasesByFolio[folio]!.first.fecha ?? 'Fecha no disponible';
    }
    return 'Fecha no disponible';
  }
  
  double getPurchaseTotal(String folio) {
    if (purchasesByFolio.containsKey(folio) && purchasesByFolio[folio]!.isNotEmpty) {
      return purchasesByFolio[folio]!.first.total ?? 0.0;
    }
    return 0.0;
  }
  
  double getPurchaseSubtotal(String folio) {
    if (purchasesByFolio.containsKey(folio) && purchasesByFolio[folio]!.isNotEmpty) {
      return purchasesByFolio[folio]!.first.subtotal ?? 0.0;
    }
    return 0.0;
  }
  
  double getPurchaseIVA(String folio) {
    if (purchasesByFolio.containsKey(folio) && purchasesByFolio[folio]!.isNotEmpty) {
      return purchasesByFolio[folio]!.first.iva ?? 0.0;
    }
    return 0.0;
  }
  
  String getPurchasePaymentMethod(String folio) {
    if (purchasesByFolio.containsKey(folio) && purchasesByFolio[folio]!.isNotEmpty) {
      return purchasesByFolio[folio]!.first.formaPago ?? 'No disponible';
    }
    return 'No disponible';
  }
  
  void retryFetchStoreItems() {
    fetchStoreItems();
  }

  @override
  void onClose() {
    if (tabController != null) {
      tabController!.removeListener(_tabListener);
      tabController!.dispose();
    }
    super.onClose();
  }
}