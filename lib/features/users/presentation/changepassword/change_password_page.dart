import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:BCG_Store/common/widgets/rounded_logo_widget.dart';
import 'package:BCG_Store/features/users/presentation/changepassword/change_password_controller.dart';
import 'package:get/get.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';

class ChangePasswordPage extends GetView<ChangePasswordController> {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
 
 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
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
                    child: Padding(
  padding: const EdgeInsets.only(bottom: 24.0),
  child: Center(
    child: RoundedLogoWidget(
      height: 80,
      borderRadius: 8.0,
    ),
  ),
)
                  ),
                const SizedBox(height: 16),
                Text(
                  'Ingresa tu contraseña actual y la nueva contraseña para actualizarla',
                  style: AppTheme.theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: controller.currentPasswordController,
                  focusNode: controller.currentPasswordFocus,
                  obscureText: controller.obscureCurrentPassword.value,
                  validator: controller.validateCurrentPassword,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(controller.newPasswordFocus);
                  },
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureCurrentPassword.value ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textGrey,
                      ),
                      onPressed: controller.toggleCurrentPasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.newPasswordController,
                  focusNode: controller.newPasswordFocus,
                  obscureText: controller.obscureNewPassword.value,
                  validator: controller.validateNewPassword,
                  textInputAction: TextInputAction.next, 
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(controller.confirmPasswordFocus);
                  },
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureNewPassword.value ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textGrey,
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.confirmPasswordController,
                  focusNode: controller.confirmPasswordFocus,
                  obscureText: controller.obscureConfirmPassword.value,
                  validator: controller.validateConfirmPassword,
                  textInputAction: TextInputAction.done, 
                  onFieldSubmitted: (_) {
                    if (!controller.isLoading.value) {
                      controller.changePassword();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    prefixIcon: Icon(Icons.lock_clock, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirmPassword.value ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textGrey,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
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
                      'Contraseña actualizada correctamente',
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
                            'CAMBIAR CONTRASEÑA',
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