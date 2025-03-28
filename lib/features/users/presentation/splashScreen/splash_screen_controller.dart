import 'package:BCG_Store/features/clients/domain/usecases/client_data_usecase.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/check_point_usecase.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  final ClientDataUsecase clientDataUsecase;
  
  SplashScreenController({
    required this.clientDataUsecase,
  });
  
  final RxBool isLoading = true.obs;
  
  final RxString companyName = "".obs;
  
  @override
  void onInit() {
    super.onInit();
    checkAuthentication();
  }
  
  Future<void> checkAuthentication() async {
    try {
        final clientData = await clientDataUsecase.execute();
        if (clientData.isNotEmpty) {
          companyName.value = clientData.first.empresa;
          print('✅ Nombre de empresa obtenido: ${companyName.value}');
          Get.offAllNamed('/homePage');
        }
      } catch (e) {
        print('⚠️ Error al obtener datos de cliente: $e');
      Get.offAllNamed('/login');
      } finally {
      isLoading.value = false;
    }
  }
}