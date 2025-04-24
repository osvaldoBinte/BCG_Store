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
  
  // Referencia al controlador de puntos
  CheckPointController? _pointsController;

  @override
  void onInit() {
    super.onInit();
    fetchDataSells();
    _initPointsController();
  }
  
  // Inicializar el controlador de puntos si está disponible
  void _initPointsController() {
    try {
      _pointsController = Get.find<CheckPointController>();
      print('✅ CheckPointController encontrado');
    } catch (e) {
      print('⚠️ No se pudo encontrar el CheckPointController: $e');
    }
  }

  Future<void> fetchDataSells() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      emptyResponse.value = false;

      final result = await getDataSellsUsecase.execute();

      if (result.isNotEmpty) {
        sellsList.assignAll(result);
        print('✅ Datos de ventas cargados correctamente: ${result.length}');
        
        // Verificar puntos para todas las ventas cargadas
        _checkPointsForAllPurchases();
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
  
  // Verificar puntos para todas las compras
  void _checkPointsForAllPurchases() {
    if (_pointsController == null) return;
    
    // Obtener folios únicos de compras
    final folios = <String>{};
    for (var item in sellsList) {
      if (item.folio != null) {
        folios.add(item.folio!);
      }
    }
    
    // Verificar puntos para cada folio
    for (var folio in folios) {
      checkPointsForPurchase(folio);
    }
  }
  
  // Verificar puntos para una compra específica
  Future<void> checkPointsForPurchase(String folio) async {
    if (_pointsController == null) return;
    
    // Marcar como cargando
    loadingStatusByFolio[folio] = true;
    hasPointsByFolio[folio] = false;
    
    try {
      // Buscar en la lista de puntos
      final points = _pointsController!.checkPoints;
      for (var point in points) {
        if (point.folio_venta == folio) {
          pointsByFolio[folio] = point.puntos_ganados;
          hasPointsByFolio[folio] = true;
          print('✅ Puntos encontrados para folio $folio: ${point.puntos_ganados}');
          break;
        }
      }
    } catch (e) {
      print('❌ Error al buscar puntos para folio $folio: $e');
    } finally {
      loadingStatusByFolio[folio] = false;
    }
  }
  
  // Verificar si una compra está cargando información de puntos
  bool isPurchaseLoadingPoints(String folio) {
    return loadingStatusByFolio[folio] ?? false;
  }
  
  // Verificar si una compra tiene puntos
  bool purchaseHasPoints(String folio) {
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
}