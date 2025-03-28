import 'package:BCG_Store/features/rewards/domain/entities/get_data_sells_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/get_data_sells_usecase.dart';
import 'package:get/get.dart';
class GetDataSellsController extends GetxController {
  final GetDataSellsUsecase getDataSellsUsecase;

  GetDataSellsController({
    required this.getDataSellsUsecase,
  });

  final Rx<bool> isLoading = false.obs;
  final RxList<GetDataSellsEntitie> sellsList = <GetDataSellsEntitie>[].obs;
  final Rx<String> errorMessage = ''.obs;
  
  // Agregar un flag para indicar si la respuesta está vacía pero es válida
  final Rx<bool> emptyResponse = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDataSells();
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
      } else {
        // En lugar de establecer un mensaje de error, marcamos que la respuesta está vacía pero es válida
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

  // Método para filtrar ventas por fecha
  List<GetDataSellsEntitie> filtrarVentasPorFecha(String fecha) {
    return sellsList.where((venta) => venta.fecha == fecha).toList();
  }

  // Método para filtrar ventas por forma de pago
  List<GetDataSellsEntitie> filtrarVentasPorFormaPago(String formaPago) {
    return sellsList.where((venta) => venta.formaPago == formaPago).toList();
  }

  // Método para buscar una venta por folio
  GetDataSellsEntitie? buscarVentaPorFolio(String folio) {
    try {
      return sellsList.firstWhere((venta) => venta.folio == folio);
    } catch (e) {
      return null;
    }
  }
}