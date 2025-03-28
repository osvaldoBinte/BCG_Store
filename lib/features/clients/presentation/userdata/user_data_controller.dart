import 'package:BCG_Store/features/clients/domain/entities/client_data_entitie.dart';
import 'package:BCG_Store/features/clients/domain/usecases/client_data_usecase.dart';
import 'package:BCG_Store/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/get_clientes_app_rewards.dart';
import 'package:get/get.dart';
class UserDataController extends GetxController {
  final ClientDataUsecase clientDataUsecase;
  final GetClientesAppRewards getClientesAppRewards;

  UserDataController({
    required this.clientDataUsecase,
    required this.getClientesAppRewards,
  });

  final Rx<bool> isLoading = false.obs;
  final Rx<ClientDataEntitie?> clientData = Rx<ClientDataEntitie?>(null);
  final RxList<ClientDataEntitie> clientsList = <ClientDataEntitie>[].obs;
  final Rx<String> errorMessage = ''.obs;

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

    String address = '${client.domicilio} #${client.numext}';
    if (client.numint != null && client.numint!.isNotEmpty) {
      address += ', Int. ${client.numint}';
    }
    address += ', ${client.colonia}, ${client.municipio}, ${client.cp}, ${client.estado}, ${client.pais}';

    return address;
  }

  String getDeliveryAddress() {
    // Por ahora, usamos la misma dirección de facturación
    // Esto podría extenderse para manejar múltiples direcciones
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
}