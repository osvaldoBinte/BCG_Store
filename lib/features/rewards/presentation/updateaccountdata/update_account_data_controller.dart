import 'package:flutter/material.dart';
import 'package:gerena/features/rewards/domain/entities/clientes_app_rewards_entitie.dart';
import 'package:gerena/features/rewards/domain/usecases/update_account_data_usecase.dart';
import 'package:gerena/page/widgets/custom_alert_type.dart';
import 'package:get/get.dart';
import 'package:gerena/features/users/domain/usecases/change_password_usecase.dart';
import 'package:gerena/features/users/domain/entities/change_password_entitie.dart';

class UpdateAccountDataController extends GetxController {
  final UpdateAccountDataUsecase updateAccountDataUsecase;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

   final FocusNode usernameFocus = FocusNode();
    final FocusNode firstnameFocus = FocusNode();
    final FocusNode lastnameFocus = FocusNode();
    final FocusNode emailFocus = FocusNode();
      FocusNode? _usernameFocus;
  FocusNode? _firstnameFocus;
  FocusNode? _lastnameFocus;
  FocusNode? _emailFocus;
  
  final RxBool isLoading = false.obs;
  final RxBool obsusername = true.obs;
  final RxBool obsfirstname = true.obs;
  final RxBool obslastname = true.obs;
  final RxBool obscemail= true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSuccess = false.obs;
  final formKey = GlobalKey<FormState>();

  UpdateAccountDataController({required this.updateAccountDataUsecase});

  void registerFocusNodes(
    FocusNode usernameFocus,
    FocusNode firstnameFocus,
    FocusNode lastnameFocus,
    FocusNode emailFocus,
  ) {
    _usernameFocus = usernameFocus;
    _firstnameFocus = firstnameFocus;
    _lastnameFocus = lastnameFocus;
    _emailFocus = emailFocus;

  }

  @override
  void onClose() {
    usernameController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();

    _usernameFocus?.dispose();
    _firstnameFocus?.dispose();
    _lastnameFocus?.dispose();
    _emailFocus?.dispose();
    
    super.onClose();
  }

// Validación para el campo de usuario (username)
String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa un nombre de usuario';
  }
  if (value.length < 4) {
    return 'El nombre de usuario debe tener al menos 4 caracteres';
  }
  return null;
}

// Validación para el campo de primer nombre (firstname)
String? validateFirstName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu primer nombre';
  }
  if (value.length < 2) {
    return 'El primer nombre debe tener al menos 2 caracteres';
  }
  return null;
}

// Validación para el campo de apellido (lastname)
String? validateLastName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu apellido';
  }
  if (value.length < 2) {
    return 'El apellido debe tener al menos 2 caracteres';
  }
  return null;
}

// Validación para el campo de email (correo electrónico)
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa un correo electrónico';
  }
  // Expresión regular básica para validar el formato de email
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Por favor ingresa un correo electrónico válido';
  }
  return null;
}



 
  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    isSuccess.value = false;

    try {
      final clientesAppRewardsEntitie = ClientesAppRewardsEntitie(
       
        username: usernameController.text,
        first_name: firstnameController.text,
        last_name: lastnameController.text,
        email: emailController.text,
      );

      await updateAccountDataUsecase.execute(clientesAppRewardsEntitie);
      isSuccess.value = true;


    usernameController.clear();
    firstnameController.clear();
    lastnameController.clear();
    emailController.clear();
      showSuccessAlert('Éxito', 'Datos actualizados correctamente');
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
    showErrorAlert('ACTUALIZACIÓN ', cleanErrorMessage);
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