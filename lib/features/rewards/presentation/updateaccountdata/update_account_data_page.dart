import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gerena/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:gerena/features/rewards/presentation/updateaccountdata/update_account_data_controller.dart';
import 'package:get/get.dart';
import 'package:gerena/common/theme/App_Theme.dart';

class UpdateAccountDataPage extends GetView<UpdateAccountDataController> {
  const UpdateAccountDataPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ClientesAppRewardsEntitie? clientData = Get.arguments as ClientesAppRewardsEntitie?;
    
    if (clientData != null) {
      controller.usernameController.text = clientData.username;
      controller.firstnameController.text = clientData.first_name;
      controller.lastnameController.text = clientData.last_name;
      controller.emailController.text = clientData.email;
    }
    
    controller.registerFocusNodes(
      controller.usernameFocus,
      controller.firstnameFocus,
      controller.lastnameFocus,
      controller.emailFocus,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualizar Datos de Cuenta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => Form(
            key: controller.formKey,
            child: ListView(
              children: [
                if (AppTheme.hasCustomLogo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Center(
                      child: Image.network(
                        AppTheme.logoUrl,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            AppTheme.defaultLogoAsset,
                            height: 80,
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Actualiza tus datos personales',
                  style: AppTheme.theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: controller.usernameController,
                  focusNode: controller.usernameFocus,
                  validator: controller.validateUsername,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(controller.firstnameFocus);
                  },
                  decoration: InputDecoration(
                    labelText: 'Nombre de Usuario',
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.firstnameController,
                  focusNode: controller.firstnameFocus,
                  validator: controller.validateFirstName,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(controller.lastnameFocus);
                  },
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.lastnameController,
                  focusNode: controller.lastnameFocus,
                  validator: controller.validateLastName,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(controller.emailFocus);
                  },
                  decoration: InputDecoration(
                    labelText: 'Apellido',
                    prefixIcon: Icon(Icons.people, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.emailController,
                  focusNode: controller.emailFocus,
                  validator: controller.validateEmail,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (_) {
                    if (!controller.isLoading.value) {
                      controller.changePassword();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 24),
                if (controller.errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (controller.isSuccess.value)
  Container(
    padding: const EdgeInsets.all(8),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppTheme.successColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Text(
      'Datos actualizados correctamente',
      style: TextStyle(
        color: AppTheme.successColor,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    ),
  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isLoading.value
                        ?   SpinKitPulsingGrid(
                    color: AppTheme.primaryColor,
                    size: 30.0,
                  ) 
                        : const Text(
                            'ACTUALIZAR DATOS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}