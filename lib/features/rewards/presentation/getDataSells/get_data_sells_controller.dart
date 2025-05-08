import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/get_data_sells_usecase.dart';
import 'package:BCG_Store/features/rewards/presentation/points/check_point_controller.dart';
import 'package:BCG_Store/features/rewards/domain/entities/check_points_entitie.dart';
import 'package:get/get.dart';

class GetDataSellsController extends GetxController {
  final GetDataSellsUsecase getDataSellsUsecase;

  GetDataSellsController({
    required this.getDataSellsUsecase,
  });

  final Rx<bool> isLoading = false.obs;
  final RxList<GetDataSellsEntitie> sellsList = <GetDataSellsEntitie>[].obs;
  final Rx<String> errorMessage = ''.obs;
  final Rx<bool> emptyResponse = false.obs;
  
  // Mapa para almacenar información de puntos por folio
  final RxMap<String, double> pointsByFolio = <String, double>{}.obs;
  final RxMap<String, bool> loadingStatusByFolio = <String, bool>{}.obs;
  final RxMap<String, bool> hasPointsByFolio = <String, bool>{}.obs;
  
  // Nueva propiedad para controlar el orden de clasificación
  final Rx<bool> isDescendingOrder = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchDataSells();
  }

  // Obtener el tipo de puntos para un folio específico
  String getTipoPuntos(String folio) {
    final venta = buscarVentaPorFolio(folio);
    if (venta == null) return '';
    
    return (venta.tipoPuntos ?? '').toUpperCase();
  }

  // Obtener los puntos por tipo (GANADOS/GASTADOS) para un folio específico
  Map<String, double> getPuntosPorTipo(String folio) {
    final venta = buscarVentaPorFolio(folio);
    if (venta == null) return {'GANADOS': 0.0, 'GASTADOS': 0.0};
    
    final tipo = (venta.tipoPuntos ?? '').toUpperCase();
    final puntos = venta.puntos ?? 0.0;
    
    if (tipo.contains('GANADOS')) {
      return {'GANADOS': puntos, 'GASTADOS': 0.0};
    } else if (tipo.contains('GASTADOS')) {
      return {'GANADOS': 0.0, 'GASTADOS': puntos};
    }
    
    return {'GANADOS': 0.0, 'GASTADOS': 0.0};
  }

  void sortByVentaId({bool? descending}) {
    if (descending != null) {
      isDescendingOrder.value = descending;
    }
    
    final sortedList = List<GetDataSellsEntitie>.from(sellsList);
    
    if (isDescendingOrder.value) {
      sortedList.sort((a, b) => (b.ventaId ?? 0).compareTo(a.ventaId ?? 0));
    } else {
      sortedList.sort((a, b) => (a.ventaId ?? 0).compareTo(b.ventaId ?? 0));
    }
    
    sellsList.assignAll(sortedList);
  }
  
  void toggleSortOrder() {
    isDescendingOrder.value = !isDescendingOrder.value;
    sortByVentaId();
  }

  // Cargar los datos de ventas desde el repositorio
  Future<void> fetchDataSells() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      emptyResponse.value = false;

      final result = await getDataSellsUsecase.execute();

      if (result.isNotEmpty) {
        sellsList.assignAll(result);
        print('✅ Datos de ventas cargados correctamente: ${result.length}');
        
        // Ordena la lista por ventaId (por defecto en orden descendente)
        sortByVentaId();
        
        // Inicializa la información de puntos para cada folio
        _initializePointsData();
        
      } else {
        sellsList.clear();
        emptyResponse.value = true;
        print('⚠️ No se encontraron datos de ventas');
      }
    } catch (e) {
      errorMessage.value = 'Error al cargar los datos de ventas: ${e.toString()}';
      print('❌ Error en fetchDataSells: $e');
      
      if (e.toString().contains('Token')) {
        errorMessage.value = 'Error de autenticación. Por favor inicie sesión nuevamente.';
      } else if (e.toString().contains('404')) {
        errorMessage.value = 'No se encontraron datos de ventas.';
      } else if (e.toString().contains('conexión')) {
        errorMessage.value = 'Error de conexión. Verifique su conexión a internet.';
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  // Método para inicializar los datos de puntos
  void _initializePointsData() {
    // Ahora sellsList ya contiene objetos agrupados por folio
    for (final venta in sellsList) {
      final folio = venta.folio;
      if (folio == null || folio.isEmpty) continue;
      
      final tienePuntos = (venta.puntos ?? 0) > 0;
      
      // Almacenamos el estado en los mapas reactivos
      hasPointsByFolio[folio] = tienePuntos;
      loadingStatusByFolio[folio] = false;
      pointsByFolio[folio] = venta.puntos ?? 0.0;
    }
  }

  // Verificar si una compra está cargando información de puntos
  bool isPurchaseLoadingPoints(String folio) {
    return loadingStatusByFolio[folio] ?? false;
  }
  
  // Verificar si una compra tiene puntos
  bool purchaseHasPoints(String folio) {
    if (!hasPointsByFolio.containsKey(folio)) {
      final venta = buscarVentaPorFolio(folio);
      final tienePuntos = (venta?.puntos ?? 0) > 0;
      hasPointsByFolio[folio] = tienePuntos;
    }
    return hasPointsByFolio[folio] ?? false;
  }
  
  // Obtener la cantidad de puntos para una compra
  double getPurchasePoints(String folio) {
    return pointsByFolio[folio] ?? 0.0;
  }

  // Métodos para obtener información específica de las ventas
  double getTotalVentas() {
    return sellsList.fold(0.0, (sum, item) => sum + (item.total ?? 0.0));
  }

  double getSubtotalVentas() {
    return sellsList.fold(0.0, (sum, item) => sum + (item.subtotal ?? 0.0));
  }

  double getIvaVentas() {
    return sellsList.fold(0.0, (sum, item) => sum + (item.iva ?? 0.0));
  }

  List<GetDataSellsEntitie> filtrarVentasPorFecha(String fecha) {
    return sellsList.where((venta) => venta.fecha == fecha).toList();
  }

  List<GetDataSellsEntitie> filtrarVentasPorFormaPago(String formaPago) {
    return sellsList.where((venta) => venta.formaPago == formaPago).toList();
  }

  GetDataSellsEntitie? buscarVentaPorFolio(String folio) {
    try {
      return sellsList.firstWhere((venta) => venta.folio == folio);
    } catch (e) {
      return null;
    }
  }
  
  // Obtener todas las salidas (productos) para un folio específico
  List<SalidaEntitie> obtenerSalidasPorFolio(String folio) {
    final venta = buscarVentaPorFolio(folio);
    return venta?.salidas ?? [];
  }
  
  // Contar el número total de productos en todas las ventas
  int contarTotalProductos() {
    return sellsList.fold(0, (sum, venta) => sum + (venta.salidas?.length ?? 0));
  }
}