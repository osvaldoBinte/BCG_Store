import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/services/auth_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/clients/presentation/userdata/user_data_Loading.dart';
import 'package:BCG_Store/features/clients/presentation/userdata/user_data_controller.dart';
import 'package:BCG_Store/page/widgets/custom_alert_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDataPage extends StatelessWidget {
  const UserDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserDataController controller = Get.find<UserDataController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchClientData();
      controller.fetchRewardsClients();
    });

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.secondaryColor,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              child: AppBar(
                primary: false,
                backgroundColor: AppTheme.secondaryColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppTheme.textPrimaryColor,
                  onPressed: () async {
                    await NavigationService.to.navigateToHome(initialIndex: 0);
                  },
                ),
                title: Column(
                  children: [
                    Text(
                      "TUS DATOS",
                      style: AppTheme.theme.textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Puedes administrar tu cuenta aquí",
                      style: AppTheme.theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                centerTitle: true,
              ),
            ),
          ),
          
          Expanded(
            child: Obx(() {
              final bool isLoading = controller.isLoading.value || controller.isLoadingRewards.value;
              
              final bool hasError = controller.errorMessage.value.isNotEmpty || 
                                  controller.rewardsErrorMessage.value.isNotEmpty;
              
              if (isLoading) {
                return UserDataLoading(
                 
                );
              }
              
              if (hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value.isNotEmpty 
                            ? controller.errorMessage.value 
                            : controller.rewardsErrorMessage.value,
                        style: TextStyle(color: AppTheme.textPrimaryColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          controller.fetchClientData();
                          controller.fetchRewardsClients();
                        },
                        child: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              final hasClientData = controller.clientData.value != null;
              final hasRewardsData = controller.rewardsClientsList.isNotEmpty;
              
              final rewardsClient = hasRewardsData ? controller.rewardsClientsList.first : null;
              
              return ListView(
                children: [
                  Container(
                    color: AppTheme.secondaryColor,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasRewardsData 
                                    ? "${rewardsClient!.first_name} ${rewardsClient.last_name}"
                                    : (hasClientData ? controller.getFullName() : "Usuario"),
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      hasRewardsData 
                                          ? rewardsClient!.email
                                          : (hasClientData ? controller.getEmail() : "Sin correo"),
                                      style: TextStyle(
                                        color: AppTheme.textPrimaryColor,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                 
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.logout,
                            label: "Cerrar Sesión",
                            onTap: () async {
                              if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
         title: 'Cerrar sesión',
      message: '¿Estás seguro de que deseas cerrar sesión?',
        type: CustomAlertType.error,
         confirmText: 'Sí',
      cancelText: 'No',
      onConfirm: () async {

                              AuthService().logout();
                              Get.offAllNamed('/login');      },
      onCancel: () {
        Navigator.of(Get.context!).pop();
      },
      );
    }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.edit,
                            label: "Editar",
                            onTap: () {
                                if (controller.selectedRewardsClient.value != null) {
                                        Get.toNamed('/updateAccountData', arguments: controller.selectedRewardsClient.value);
                                      } else {
                                        Get.toNamed('/updateAccountData');
                                      }
                            },        
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (hasClientData || hasRewardsData)
  Container(
    margin: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.secondaryColor,
      borderRadius: BorderRadius.circular(12), 
      boxShadow: [
        BoxShadow(
          color: AppTheme.shadowColor.withOpacity(0.6),  // Aumenté la opacidad para un sombreado más pronunciado
          blurRadius: 10,  
          spreadRadius: 3, 
          offset: const Offset(0, 4), 
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),  
              topRight: Radius.circular(16),
            ),
          ),
          child: Text(
            "Información de Usuario",
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        if (hasClientData) ...[
          _buildInfoItem(
            iconData: Icons.phone, 
            label: "Teléfono", 
            value: controller.getPhone(),
          ),
          _buildInfoItem(
            iconData: Icons.business, 
            label: "Empresa", 
            value: controller.getBusinessName(),
          ),
          _buildInfoItem(
            iconData: Icons.receipt, 
            label: "RFC", 
            value: controller.getRFC(),
          ),
          _buildInfoItem(
            iconData: Icons.location_on, 
            label: "Dirección", 
            value: controller.getBillingAddress(),
          ),
        ],
        
        if (hasRewardsData) ...[
          if (rewardsClient!.username.isNotEmpty)
            _buildInfoItem(
              iconData: Icons.person, 
              label: "Nombre de Usuario", 
              value: rewardsClient.username,
            ),
          
          if (!hasClientData)
            _buildInfoItem(
              iconData: Icons.badge, 
              label: "ID App Rewards", 
              value: "${rewardsClient.id}",
            ),
        ],
      ],
    ),
  ),

                  const SizedBox(height: 16),
                  
                  _buildMenuListItem(
                    icon: Icons.lock,
                    iconColor: AppTheme.primaryColor,
                    title: "Cambiar Contraseña",
                    subtitle: "Actualiza tu contraseña para mejorar la seguridad de tu cuenta",
                    onTap: () {
                      Get.toNamed('/changePassword');
                    },
                  ),
                  
                /*   _buildMenuListItem(
                    icon: Icons.info,
                    iconColor: AppTheme.primaryColor,
                    title: "Ayuda",
                    subtitle: "¿Te gustaría que te ayude con algo más relacionado a tu aplicación?",
                    onTap: () {
                    },
                  ),*/
                  
                  _buildMenuListItem(
                    icon: Icons.lock,
                    iconColor: AppTheme.primaryColor,
                    title: "Aviso de Privacidad",
                    subtitle: "Detalles de nuestras políticas y condiciones",
                    onTap: () {
                    },
                  ),
                  
                 /* _buildMenuListItem(
                    icon: Icons.person_remove,
                    iconColor: AppTheme.errorColor,
                    title: "Eliminar cuenta",
                    subtitle: "Elimina tu cuenta de forma permanente",
                    onTap: () {
                    },
                  ),*/
                  
                  const SizedBox(height: 32),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.textSecondaryColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem({
    required IconData iconData,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            iconData,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
 Widget _buildMenuListItem({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.4), // Puedes ajustar la opacidad para que sea más pronunciado
            blurRadius: 10,  // Aumenté el blur para un sombreado más difuso
            spreadRadius: 2, // Ajusté el spread para que la sombra sea más grande
            offset: const Offset(0, 4), // Desplazamiento vertical para hacer la sombra más notoria
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícono con círculo de fondo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Texto del ítem
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Flecha derecha
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    ),
  );
}

}