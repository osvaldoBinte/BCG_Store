import 'package:flutter/material.dart';
import 'package:BCG_Store/page/widgets/custom_alert_type.dart';
import 'package:get/get.dart';
import 'package:BCG_Store/features/users/domain/usecases/change_password_usecase.dart';
import 'package:BCG_Store/features/users/domain/entities/change_password_entitie.dart';

class ChangePasswordController extends GetxController {
  final ChangePasswordUsecase changePasswordUsecase;
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
   final FocusNode currentPasswordFocus = FocusNode();
    final FocusNode newPasswordFocus = FocusNode();
    final FocusNode confirmPasswordFocus = FocusNode();
      FocusNode? _currentPasswordFocus;
  FocusNode? _newPasswordFocus;
  FocusNode? _confirmPasswordFocus;
  
  final RxBool isLoading = false.obs;
  final RxBool obscureCurrentPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSuccess = false.obs;
  final formKey = GlobalKey<FormState>();

  ChangePasswordController({required this.changePasswordUsecase});

  // Método para registrar los focus nodes desde la vista
  void registerFocusNodes(
    FocusNode currentPasswordFocus,
    FocusNode newPasswordFocus,
    FocusNode confirmPasswordFocus
  ) {
    _currentPasswordFocus = currentPasswordFocus;
    _newPasswordFocus = newPasswordFocus;
    _confirmPasswordFocus = confirmPasswordFocus;
  }

  @override
  void onClose() {
    // Liberar los controllers
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    
    // Liberar los focus nodes
    _currentPasswordFocus?.dispose();
    _newPasswordFocus?.dispose();
    _confirmPasswordFocus?.dispose();
    
    super.onClose();
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña actual';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una nueva contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu nueva contraseña';
    }
    if (value != newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void toggleCurrentPasswordVisibility() {
    obscureCurrentPassword.value = !obscureCurrentPassword.value;
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    isSuccess.value = false;

    try {
      final changePasswordEntity = ChangePasswordEntitie(
        current_password: currentPasswordController.text,
        new_password: newPasswordController.text,
        confirm_password: confirmPasswordController.text,
      );

      await changePasswordUsecase.execute(changePasswordEntity);
      isSuccess.value = true;

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      showSuccessAlert('Éxito', 'Contraseña actualizada correctamente');
  Future.delayed(const Duration(seconds: 2), () {
      isSuccess.value = false;
    });
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.previousRoute.isNotEmpty) {
          Get.back();
        }
      });
    } catch (e) {
      String cleanErrorMessage = e.toString();
      if (cleanErrorMessage.startsWith("Exception: Exception:")) {
        cleanErrorMessage = cleanErrorMessage.replaceFirst("Exception: Exception:", "").trim();
      } else if (cleanErrorMessage.startsWith("Exception:")) {
        cleanErrorMessage = cleanErrorMessage.replaceFirst("Exception:", "").trim();
      }

      cleanErrorMessage = cleanErrorMessage
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('{', '')
          .replaceAll('}', '')
          .replaceAll('"', '')
          .replaceAll("'", '')
          .trim();

      if (cleanErrorMessage.contains(":")) {
        final parts = cleanErrorMessage.split(":");
        if (parts.length > 1) {
          cleanErrorMessage = parts.sublist(1).join(":").trim();
        }
      }
    
      cleanErrorMessage = fixEncoding(cleanErrorMessage);
      errorMessage.value = cleanErrorMessage;
      Future.delayed(const Duration(seconds: 3), () {
        errorMessage.value = '';
      });
      showErrorAlert('CONTRASEÑA', cleanErrorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  String fixEncoding(String text) {
    final Map<String, String> replacements = {
      'Ã±': 'ñ',
      'Ã¡': 'á',
      'Ã©': 'é',
      'Ã­': 'í',
      'Ã³': 'ó',
      'Ãº': 'ú',
      'Ã': 'í',
      'Â': '',
    };

    String result = text;
    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    if (result.contains('contraseÃta')) {
      result = result.replaceAll('contraseÃta', 'contraseña');
    }

    return result;
  }

  void showErrorAlert(String title, String message, {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
        onConfirm: onDismiss, // Ejecutar callback cuando se cierra la alerta
      );
    }
  }

  void showSuccessAlert(String title, String message) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.success,
      );
    }
  }
}