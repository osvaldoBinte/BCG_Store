import 'package:BCG_Store/common/errors/api_errors.dart';
import 'package:BCG_Store/common/errors/convert_message.dart';
import 'package:BCG_Store/common/services/auth_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/clients/domain/entities/client_data_entitie.dart';
import 'package:BCG_Store/features/clients/domain/usecases/client_data_usecase.dart';
import 'package:BCG_Store/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/get_clientes_app_rewards.dart';
import 'package:BCG_Store/features/users/domain/usecases/deactivate_account_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
class UserDataController extends GetxController {
  final ClientDataUsecase clientDataUsecase;
  final GetClientesAppRewards getClientesAppRewards;
  final DeactivateAccountUsecase deactivateAccountUsecase;

  UserDataController({
    required this.clientDataUsecase,
    required this.getClientesAppRewards,
    required this.deactivateAccountUsecase,
  });

  final Rx<bool> isLoading = false.obs;
  final Rx<ClientDataEntitie?> clientData = Rx<ClientDataEntitie?>(null);
  final RxList<ClientDataEntitie> clientsList = <ClientDataEntitie>[].obs;
  final Rx<String> errorMessage = ''.obs;
  final Rx<String> errorMessagedelete = ''.obs;

  final Rx<bool> isLoadingRewards = false.obs;
  final Rx<ClientesAppRewardsEntitie?> selectedRewardsClient = Rx<ClientesAppRewardsEntitie?>(null);
  final RxList<ClientesAppRewardsEntitie> rewardsClientsList = <ClientesAppRewardsEntitie>[].obs;
  final Rx<String> rewardsErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClientData();
  }

  Future<void> fetchClientData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await clientDataUsecase.execute();

      if (result.isNotEmpty) {
        clientsList.assignAll(result);
        clientData.value = result.first; 
      } else {
        errorMessage.value = 'No se encontraron datos del cliente';
      }
    } catch (e) {
      errorMessage.value = 'Error al cargar los datos: ${e.toString()}';
      print('❌ Error en fetchClientData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRewardsClients() async {
    try {
      isLoadingRewards.value = true;
      rewardsErrorMessage.value = '';

      final result = await getClientesAppRewards.execute();

      if (result.isNotEmpty) {
        rewardsClientsList.assignAll(result);
        selectedRewardsClient.value = result.first; 
        print('✅ Clientes de rewards cargados correctamente: ${result.length}');
      } else {
        rewardsErrorMessage.value = 'No se encontraron datos de clientes en App Rewards';
        print('⚠️ No se encontraron clientes de rewards');
      }
    } catch (e) {
      rewardsErrorMessage.value = 'Error al cargar los datos de App Rewards: ${e.toString()}';
      print('❌ Error en fetchRewardsClients: $e');
      
      if (e.toString().contains('Token')) {
        rewardsErrorMessage.value = 'Error de autenticación. Por favor inicie sesión nuevamente.';
      } else if (e.toString().contains('404')) {
        rewardsErrorMessage.value = 'No se encontraron datos de clientes en App Rewards.';
      } else if (e.toString().contains('conexión')) {
        rewardsErrorMessage.value = 'Error de conexión. Verifique su conexión a internet.';
      }
    } finally {
      isLoadingRewards.value = false;
    }
  }

  void selectRewardsClient(ClientesAppRewardsEntitie client) {
    selectedRewardsClient.value = client;
  }

  String getFullName() {
    return clientData.value?.empresa ?? 'Usuario';
  }

  String getEmail() {
    return clientData.value?.correo ?? 'Sin correo';
  }

  String getPhone() {
    return clientData.value?.celular ?? 'Sin teléfono';
  }

 String getBillingAddress() {
  final client = clientData.value;
  if (client == null) return 'Sin dirección';
  
  List<String> addressParts = [];
  
  if (client.domicilio != null && client.domicilio.isNotEmpty) {
    addressParts.add(client.domicilio);
  }
  
  if (client.numext != null && client.numext.isNotEmpty) {
    addressParts.add('#${client.numext}');
  }
  
  if (client.numint != null && client.numint!.isNotEmpty) {
    addressParts.add('Int. ${client.numint}');
  }
  
  String firstPart = addressParts.join(' ');
  
  addressParts = [];
  
  if (client.colonia != null && client.colonia.isNotEmpty) {
    addressParts.add(client.colonia);
  }
  
  if (client.municipio != null && client.municipio.isNotEmpty) {
    addressParts.add(client.municipio);
  }
  
  if (client.cp != null && client.cp.isNotEmpty) {
    addressParts.add(client.cp);
  }
  
  if (client.estado != null && client.estado.isNotEmpty) {
    addressParts.add(client.estado);
  }
  
  if (client.pais != null && client.pais.isNotEmpty) {
    addressParts.add(client.pais);
  }
  
  String secondPart = addressParts.join(', ');
  
  if (firstPart.isNotEmpty && secondPart.isNotEmpty) {
    return '$firstPart, $secondPart';
  } else {
    return firstPart + secondPart;
  }
}

  String getDeliveryAddress() {
    return getBillingAddress();
  }

  String getBusinessName() {
    return clientData.value?.empresa ?? 'Sin razón social';
  }

  String getRFC() {
    return clientData.value?.rfc ?? 'Sin RFC';
  }

  String getTaxRegime() {
    return clientData.value?.regimenfiscal ?? 'Sin régimen fiscal';
  }

  String getCFDIUse() {
    return clientData.value?.cfdi ?? 'Sin uso de CFDI';
  }

  // Métodos para formatear datos de clientes de rewards
  String getRewardsClientFullName() {
    final client = selectedRewardsClient.value;
    if (client == null) return 'Sin nombre';
    
    return '${client.first_name} ${client.last_name}';
  }
  
  String getRewardsClientEmail() {
    return selectedRewardsClient.value?.email ?? 'Sin correo';
  }
  
  String getRewardsClientUsername() {
    return selectedRewardsClient.value?.username ?? 'Sin usuario';
  }
Future<void> deactivateAccount(String password) async {
  try {
    // Mostrar indicador de carga con flutter_spinkit
    Get.dialog(
      Center(
        child: SpinKitFadingCircle(
          color: AppTheme.primaryColor,
          size: 50.0,
        ),
      ),
      barrierDismissible: false,
    );
    
    await deactivateAccountUsecase.execute(password);
    
    Get.back();
    
    Get.snackbar(
      'Éxito',
      'Tu cuenta ha sido eliminada correctamente',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    
    await AuthService().logout();
    Get.offAllNamed('/login');
 } catch (e) {
  if (Get.isDialogOpen!) {
    Get.back();
  }

      final cleanErrorMessage = cleanExceptionMessage(e);

      
      
     Get.snackbar(
    'Ups...',
    cleanErrorMessage,
    backgroundColor: AppTheme.errorColor,
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
  );

  print('❌ Error en deactivateAccount: $cleanErrorMessage');
}

}



}