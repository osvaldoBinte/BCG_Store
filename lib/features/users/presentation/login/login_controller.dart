import 'package:gerena/common/constants/constants.dart';
import 'package:gerena/common/routes/navigation_service.dart';
import 'package:gerena/framework/preferences_service.dart';
import 'package:gerena/page/widgets/custom_alert_type.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:gerena/features/users/domain/entities/register_entitie.dart';
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:gerena/features/users/domain/usecases/login_usecase.dart';
import 'package:gerena/features/users/domain/usecases/register_usecase.dart';
class LoginController extends GetxController {
  TextEditingController? emailController; 
  TextEditingController? passwordController;
  FocusNode? passwordFocusNode;
  
  TextEditingController? firstNameController;
  TextEditingController? lastNameController;
  TextEditingController? emailRegisterController; 
  TextEditingController? registerPasswordController;
  FocusNode? lastNameFocusNode;
  FocusNode? emailRegisterFocusNode;
  FocusNode? registerPasswordFocusNode;
  
  final isLoginForm = false.obs;
  final isRegisterForm = false.obs;
  final isQrScannerVisible = false.obs;
  final isLoading = false.obs;
  
  final scanOrigin = Rx<String>(''); 

  MobileScannerController? qrScannerController;
  
  final qrClientData = Rx<Map<String, dynamic>>({});
  
  final PreferencesUser _prefsUser = PreferencesUser();
  
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  
  LoginController({
    required this.loginUsecase,
    required this.registerUsecase,
  });
  
  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      String? savedBaseDatos = await _prefsUser.loadPrefs(
        type: String, 
        key: AppConstants.baseDatosKey
      );
      
      int? savedIdCliente = await _prefsUser.loadPrefs(
        type: int, 
        key: AppConstants.idClienteKey
      );
      
      if (savedBaseDatos != null && savedIdCliente != null) {
        qrClientData.value = {
          'base_datos': savedBaseDatos,
          'id_cliente': savedIdCliente
        };
      }
    } catch (e) {
      print('Error al cargar datos guardados: $e');
    }
  }
  
  Future<void> _saveData(String key, dynamic value) async {
    try {
      dynamic type;
      if (value is String) {
        type = String;
      } else if (value is int) {
        type = int;
      } else if (value is bool) {
        type = bool;
      }
      
      _prefsUser.savePrefs(
        type: type,
        key: key,
        value: value
      );
    } catch (e) {
      print('Error al guardar datos: $e');
    }
  }

  void _initializeControllers() {
    // Inicializar controllers de login
    emailController = TextEditingController();
    passwordController = TextEditingController();
    passwordFocusNode = FocusNode();
    
    // Inicializar controllers de registro
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailRegisterController = TextEditingController();
    registerPasswordController = TextEditingController();
    lastNameFocusNode = FocusNode();
    emailRegisterFocusNode = FocusNode();
    registerPasswordFocusNode = FocusNode();

    qrScannerController = null;
  }
  
  void _disposeControllers() {
    emailController?.dispose();
    passwordController?.dispose();
    passwordFocusNode?.dispose();
    
    firstNameController?.dispose();
    lastNameController?.dispose();
    emailRegisterController?.dispose();
    registerPasswordController?.dispose();
    lastNameFocusNode?.dispose();
    emailRegisterFocusNode?.dispose();
    registerPasswordFocusNode?.dispose();

    emailController = null;
    passwordController = null;
    passwordFocusNode = null;
    firstNameController = null;
    lastNameController = null;
    emailRegisterController = null;
    registerPasswordController = null;
    lastNameFocusNode = null;
    emailRegisterFocusNode = null;
    registerPasswordFocusNode = null;
    qrScannerController = null;
  }

  void resetForm() {
    emailController?.clear();
    passwordController?.clear();
    firstNameController?.clear();
    lastNameController?.clear();
    emailRegisterController?.clear();
    registerPasswordController?.clear();
    
    isLoading.value = false;
    
    _disposeControllers();
    _initializeControllers();
    isLoginForm.value = false;
    isRegisterForm.value = false;
    isQrScannerVisible.value = false;
  }
  
  void toggleLoginForm() {
    isLoginForm.value = !isLoginForm.value;
    isRegisterForm.value = false;
    isQrScannerVisible.value = false;
    scanOrigin.value = '';
  }
  
  void toggleRegisterForm() {
    isQrScannerVisible.value = true;
    isRegisterForm.value = false;
    isLoginForm.value = false;
    scanOrigin.value = 'register';
  }

  void showQRScannerForLogin() {
    isQrScannerVisible.value = true;
    isRegisterForm.value = false;
    isLoginForm.value = false;
    scanOrigin.value = 'login';
  }

  void showRegisterFormAfterQR() {
    isQrScannerVisible.value = false;
    isRegisterForm.value = true;
    isLoginForm.value = false;
  }

  void onQRCodeDetected(String qrData) {
    try {
      print('QR escaneado: $qrData');
      
      Map<String, dynamic> qrInfo = jsonDecode(qrData);
      print('QR parseado: $qrInfo');
      
      if (qrInfo.containsKey('id_cliente')) {
        qrClientData.value = qrInfo;
        
        if (qrInfo.containsKey('base_datos')) {
          _saveData(AppConstants.baseDatosKey, qrInfo['base_datos']);
        }
        _saveData(AppConstants.idClienteKey, qrInfo['id_cliente']);
        
        AppTheme.updateColorsFromQR(qrInfo);
        
        update();
        
        if (scanOrigin.value == 'login') {
          isQrScannerVisible.value = false;
          isLoginForm.value = true;
          isRegisterForm.value = false;
          
          _showSuccessAlert(
            'Base de datos configurada',
            'La base de datos ha sido configurada correctamente. Ahora puedes iniciar sesión.'
          );
        } else {
          showRegisterFormAfterQR();
        }
      } else {
        _showErrorAlert('Código QR inválido', 'El código no contiene la información necesaria.');
      }
    } catch (e) {
      print('Error procesando datos QR: $e');
      _showErrorAlert('Error en QR', 'El código escaneado no tiene el formato esperado.');
    }
  }
  
  void _showErrorAlert(String title, String message, {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
        onConfirm: onDismiss, 
      );
    }
  }

  void _showSuccessAlert(String title, String message) {
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

  void _showWarningAlert(String title, String message, {VoidCallback? onConfirm}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
        onConfirm: onConfirm ?? () => Get.back(),
      );
    }
  }

  void cancelQRScan() {
    isQrScannerVisible.value = false;
    isRegisterForm.value = false;
    isLoginForm.value = false;
  }
  
  Future<void> login() async {
    if (emailController?.text.isNotEmpty == true && 
        passwordController?.text.isNotEmpty == true) {
      try {
        isLoading.value = true;
        
        String? baseDatos;
        if (qrClientData.value.containsKey('base_datos')) {
          baseDatos = qrClientData.value['base_datos'].toString();
        } else {
          baseDatos = await _prefsUser.loadPrefs(
            type: String, 
            key: AppConstants.baseDatosKey
          );
        }
        
        if (baseDatos == null || baseDatos.isEmpty) {
          isLoading.value = false;
          
          _showErrorAlert(
            'Base de datos no encontrada', 
            'No se encontró la base de datos. Por favor escanea un código QR válido.',
            onDismiss: () {
              Get.back(); 
              Future.delayed(Duration(milliseconds: 300), () {
                showQRScannerForLogin();
              });
            }
          );
          return;
        }
        
        final result = await loginUsecase.execute(
          emailController!.text,
          passwordController!.text,
          baseDatos
        );
        
        print('Login exitoso: $result');
        
        emailController?.clear();
        passwordController?.clear();
        isLoading.value = false;
        
        Get.offAllNamed('/homePage');
        resetForm();
      } catch (e) {
        String cleanErrorMessage = e.toString();
        if (cleanErrorMessage.startsWith("Exception: Exception:")) {
          cleanErrorMessage = cleanErrorMessage.replaceFirst("Exception: Exception:", "").trim();
        } else if (cleanErrorMessage.startsWith("Exception:")) {
          cleanErrorMessage = cleanErrorMessage.replaceFirst("Exception:", "").trim();
        }
        print('Error en login: $e');
        _showErrorAlert('ACCESO INCORRECTO', cleanErrorMessage);
        isLoading.value = false;
      }
    } else {
      _showWarningAlert('Campos incompletos', 'Por favor completa todos los campos para iniciar sesión.');
    }
  }

  Future<void> register() async {
    if (firstNameController?.text.isNotEmpty == true && 
        lastNameController?.text.isNotEmpty == true &&
        emailRegisterController?.text.isNotEmpty == true && 
        registerPasswordController?.text.isNotEmpty == true) {
      
      if (qrClientData.value.isEmpty || !qrClientData.value.containsKey('id_cliente')) {
        _showErrorAlert('Información incompleta', 'Por favor escanea un código QR válido primero.');
        return;
      }
      
      try {
        isLoading.value = true;
        
        final registerEntity = RegisterEntitie(
          first_name: firstNameController!.text,
          last_name: lastNameController!.text,
          id_cliente: int.parse(qrClientData.value['id_cliente'].toString()),
          email: emailRegisterController!.text,
          password: registerPasswordController!.text,
        );
        
        await registerUsecase.register(registerEntity);
        
        _showSuccessAlert(
          '¡Registro exitoso!',
          'Tu cuenta ha sido creada correctamente. Ahora puedes iniciar sesión.'
        );
        
        if (qrClientData.value.containsKey('base_datos')) {
          _saveData(AppConstants.baseDatosKey, qrClientData.value['base_datos']);
        }
        
        firstNameController?.clear();
        lastNameController?.clear();
        emailRegisterController?.clear();
        registerPasswordController?.clear();
        
        Future.delayed(Duration(milliseconds: 1500), () {
          isRegisterForm.value = false;
          isLoginForm.value = false;
          qrClientData.value = qrClientData.value; 
        });
        
      } catch (e) {
        print('Error en registro: $e');
        _showErrorAlert('Algo salió mal', 'El usuario ya existe o el código QR ya ha sido utilizado');
      } finally {
        isLoading.value = false;
      }
    } else {
      _showWarningAlert('Campos incompletos', 'Por favor completa todos los campos para registrarte.');
    }
  }
  
  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }
}