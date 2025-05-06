import 'package:BCG_Store/common/constants/constants.dart';
import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/services/auth_service.dart';
import 'package:BCG_Store/features/users/domain/usecases/update_token_usecase.dart';
import 'package:BCG_Store/framework/preferences_service.dart';
import 'package:BCG_Store/page/widgets/custom_alert_type.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:BCG_Store/features/users/domain/entities/register_entitie.dart';
import 'package:BCG_Store/features/users/domain/entities/change_password_entitie.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/users/domain/usecases/login_usecase.dart';
import 'package:BCG_Store/features/users/domain/usecases/register_usecase.dart';
import 'package:BCG_Store/features/users/domain/usecases/recovery_password_usecase.dart';
import 'package:BCG_Store/features/users/domain/usecases/change_password_usecase.dart';

class LoginController extends GetxController {
  TextEditingController? emailController; 
  TextEditingController? passwordController;
  FocusNode? passwordFocusNode;
  
  TextEditingController? recoveryEmailController;
  TextEditingController? tempPasswordController;
  FocusNode? recoveryEmailFocusNode;
  FocusNode? tempPasswordFocusNode;
  
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  TextEditingController? currentPasswordController;
  TextEditingController? newPasswordController; 
  TextEditingController? confirmPasswordController;
  FocusNode? currentPasswordFocusNode;
  FocusNode? newPasswordFocusNode;
  FocusNode? confirmPasswordFocusNode;
  
  TextEditingController? firstNameController;
  TextEditingController? lastNameController;
  TextEditingController? emailRegisterController; 
  TextEditingController? registerPasswordController;
  FocusNode? lastNameFocusNode;
  FocusNode? emailRegisterFocusNode;
  FocusNode? registerPasswordFocusNode;
  
  final isPasswordVisible = false.obs;
  final isTempPasswordVisible = false.obs;
  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isRegisterPasswordVisible = false.obs;
  
  final isLoginForm = false.obs;
  final isRegisterForm = false.obs;
  final isQrScannerVisible = false.obs;
  final isLoading = false.obs;
  
  final isRecoveryForm = false.obs;
  final isTempPasswordForm = false.obs;
  final isChangePasswordForm = false.obs;
  final recoveryEmail = ''.obs;
  
  final scanOrigin = Rx<String>(''); 

  MobileScannerController? qrScannerController;
  
  final qrClientData = Rx<Map<String, dynamic>>({});
  
  final PreferencesUser _prefsUser = PreferencesUser();
  
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final RecoveryPasswordUsecase recoveryPasswordUsecase;
  final ChangePasswordUsecase changePasswordUsecase;
  final UpdateTokenUsecase updateTokenUsecase;
  final RxBool cameraPermissionDenied = false.obs;

  LoginController({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.recoveryPasswordUsecase,
    required this.changePasswordUsecase,
    required this.updateTokenUsecase,

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
    
    // Inicializar controllers de recuperación de contraseña
    recoveryEmailController = TextEditingController();
    tempPasswordController = TextEditingController();
    recoveryEmailFocusNode = FocusNode();
    tempPasswordFocusNode = FocusNode();
    
    // Inicializar controllers de cambio de contraseña
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    currentPasswordFocusNode = FocusNode();
    newPasswordFocusNode = FocusNode();
    confirmPasswordFocusNode = FocusNode();
    
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
    
    recoveryEmailController?.dispose();
    tempPasswordController?.dispose();
    recoveryEmailFocusNode?.dispose();
    tempPasswordFocusNode?.dispose();
    
    currentPasswordController?.dispose();
    newPasswordController?.dispose();
    confirmPasswordController?.dispose();
    currentPasswordFocusNode?.dispose();
    newPasswordFocusNode?.dispose();
    confirmPasswordFocusNode?.dispose();
    
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
    
    recoveryEmailController = null;
    tempPasswordController = null;
    recoveryEmailFocusNode = null;
    tempPasswordFocusNode = null;
    
    currentPasswordController = null;
    newPasswordController = null;
    confirmPasswordController = null;
    currentPasswordFocusNode = null;
    newPasswordFocusNode = null;
    confirmPasswordFocusNode = null;
    
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
    
    recoveryEmailController?.clear();
    tempPasswordController?.clear();
    
    currentPasswordController?.clear();
    newPasswordController?.clear();
    confirmPasswordController?.clear();
    
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
    isRecoveryForm.value = false;
    isTempPasswordForm.value = false;
    isChangePasswordForm.value = false;
  }
  
  void toggleLoginForm() {
    isLoginForm.value = !isLoginForm.value;
    isRegisterForm.value = false;
    isQrScannerVisible.value = false;
    isRecoveryForm.value = false;
    isTempPasswordForm.value = false;
    isChangePasswordForm.value = false;
    scanOrigin.value = '';
  }
  
  void toggleRegisterForm() {
    isQrScannerVisible.value = true;
    isRegisterForm.value = false;
    isLoginForm.value = false;
    isRecoveryForm.value = false;
    isTempPasswordForm.value = false;
    isChangePasswordForm.value = false;
    scanOrigin.value = 'register';
  }
  
  void toggleRecoveryForm() {
    isRecoveryForm.value = true;
    isLoginForm.value = false;
    isRegisterForm.value = false;
    isQrScannerVisible.value = false;
    isTempPasswordForm.value = false;
    isChangePasswordForm.value = false;
  }
  
  void showTempPasswordForm() {
    isTempPasswordForm.value = true;
    isRecoveryForm.value = false;
    isLoginForm.value = false;
    isRegisterForm.value = false;
    isQrScannerVisible.value = false;
    isChangePasswordForm.value = false;
  }
  
  void showChangePasswordForm() {
    isChangePasswordForm.value = true;
    isTempPasswordForm.value = false;
    isRecoveryForm.value = false;
    isLoginForm.value = false;
    isRegisterForm.value = false;
    isQrScannerVisible.value = false;
  }

  void showQRScannerForLogin() {
    isQrScannerVisible.value = true;
    isRegisterForm.value = false;
    isLoginForm.value = false;
    isRecoveryForm.value = false;
    isTempPasswordForm.value = false;
    isChangePasswordForm.value = false;
    scanOrigin.value = 'login';
  }

  void showRegisterFormAfterQR() {
    isQrScannerVisible.value = false;
    isRegisterForm.value = true;
    isLoginForm.value = false;
    isRecoveryForm.value = false;
    isTempPasswordForm.value = false;
    isChangePasswordForm.value = false;
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
  'Escaneo de QR para iniciar sesión',
  'El QR ha sido configurado correctamente. Ahora puedes escanearlo para iniciar sesión.'
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

  void _showSuccessAlert(String title, String message, {VoidCallback? onConfirm}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.success,
        onConfirm: onConfirm,
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
    isRecoveryForm.value = false;
    isTempPasswordForm.value = false;
    isChangePasswordForm.value = false;
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
  'Código QR no encontrado',
  'No se encontró un código QR válido. Por favor, escanea un código QR.',
  onDismiss: () {
    Get.back(); 
    Future.delayed(Duration(milliseconds: 300), () {
      showQRScannerForLogin();
    });
  }
);

          return;
        }
        
        final loginResponse = await loginUsecase.execute(
          emailController!.text,
          passwordController!.text,
          baseDatos
        );
        final authService = AuthService();
      final bool saved = await authService.saveLoginResponse(loginResponse);
      if (saved) {
       
      String? token = await messaging.getToken();
      await updateTokenUsecase.execute(token);
      }        
        emailController?.clear();
        passwordController?.clear();
        isLoading.value = false;
        
        if (isTempPasswordForm.value) {
          showChangePasswordForm();
        } else {
          Get.offAllNamed('/homePage');
          resetForm();
        }
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
  
  Future<void> recoverPassword() async {
    if (recoveryEmailController?.text.isEmpty == true) {
      _showWarningAlert('Campo incompleto', 'Por favor ingresa tu correo electrónico para recuperar tu contraseña.');
      return;
    }
    
    try {
      isLoading.value = true;
      
      await recoveryPasswordUsecase.execute(recoveryEmailController!.text);
      
      recoveryEmail.value = recoveryEmailController!.text;
          showTempPasswordForm();

      _showSuccessAlert(
        'Contraseña restablecida con éxito',
        'Por favor, verifica tu correo electrónico para obtener la contraseña temporal.',
        onConfirm: () {
          Get.back();
        }
      );
      
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: Exception:")) {
        errorMessage = errorMessage.replaceFirst("Exception: Exception:", "").trim();
      } else if (errorMessage.startsWith("Exception:")) {
        errorMessage = errorMessage.replaceFirst("Exception:", "").trim();
      }
      print('Error en recuperación: $e');
      _showErrorAlert('Error en recuperación', errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loginWithTempPassword() async {
    if (tempPasswordController?.text.isEmpty == true) {
      _showWarningAlert('Campo incompleto', 'Por favor ingresa la contraseña temporal que recibiste por correo.');
      return;
    }
    
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
      'QR no válido',
      'No se encontró un QR válido. Por favor escanea un código QR correcto.',
      onDismiss: () {
        Get.back(); 
        Future.delayed(Duration(milliseconds: 300), () {
          showQRScannerForLogin();
        });
      }
    );

        return;
      }
      
      final loginResponse = await loginUsecase.execute(
        recoveryEmail.value,
        tempPasswordController!.text,
        baseDatos
      );
      
        final authService = AuthService();
        final bool saved = await authService.saveLoginResponse(loginResponse);
      if (saved) {
       
      String? token = await messaging.getToken();
      await updateTokenUsecase.execute(token);
      }  
      
      currentPasswordController?.text = tempPasswordController!.text;
      
      tempPasswordController?.clear();
      isLoading.value = false;
      
      showChangePasswordForm();
      
    } catch (e) {
      String cleanErrorMessage = e.toString();
      if (cleanErrorMessage.startsWith("Exception: Exception:")) {
        cleanErrorMessage = cleanErrorMessage.replaceFirst("Exception: Exception:", "").trim();
      } else if (cleanErrorMessage.startsWith("Exception:")) {
        cleanErrorMessage = cleanErrorMessage.replaceFirst("Exception:", "").trim();
      }
      print('Error en login con contraseña temporal: $e');
      _showErrorAlert('ACCESO INCORRECTO', cleanErrorMessage);
      isLoading.value = false;
    }
  }
  
  Future<void> changePassword() async {
    if (newPasswordController?.text.isEmpty == true ||
        confirmPasswordController?.text.isEmpty == true) {
      _showWarningAlert('Campos incompletos', 'Por favor completa todos los campos.');
      return;
    }
    
    if (newPasswordController!.text != confirmPasswordController!.text) {
      _showErrorAlert('Error de validación', 'Las contraseñas nuevas no coinciden.');
      return;
    }
    
    try {
      isLoading.value = true;
      
      int? idCliente;
      if (qrClientData.value.containsKey('id_cliente')) {
        idCliente = int.tryParse(qrClientData.value['id_cliente'].toString());
      }
      
      if (currentPasswordController?.text.isEmpty == true) {
        print('No hay contraseña actual, usando la contraseña temporal');
        currentPasswordController?.text = tempPasswordController?.text ?? '';
      }
      
      print('Enviando datos para cambio de contraseña: {"id_cliente":$idCliente,"current_password":"${currentPasswordController?.text}","new_password":"${newPasswordController?.text}","confirm_password":"${confirmPasswordController?.text}"}');
      
      final changePasswordEntity = ChangePasswordEntitie(
        id_cliente: idCliente,
        current_password: currentPasswordController?.text ?? '',
        new_password: newPasswordController!.text,
        confirm_password: confirmPasswordController!.text,
      );
      
      await changePasswordUsecase.execute(changePasswordEntity);
      
      _showSuccessAlert(
        'Contraseña actualizada',
        'Tu contraseña ha sido actualizada exitosamente.',
        onConfirm: () {
          Get.back();
          Get.offAllNamed('/homePage');
          resetForm();
        }
      );
      
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.startsWith("Exception: Exception:")) {
        errorMessage = errorMessage.replaceFirst("Exception: Exception:", "").trim();
      } else if (errorMessage.startsWith("Exception:")) {
        errorMessage = errorMessage.replaceFirst("Exception:", "").trim();
      }
      print('Error al cambiar contraseña: $e');
      _showErrorAlert('Error', errorMessage);
    } finally {
      isLoading.value = false;
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
    String? token = await messaging.getToken();
debugPrint('Token de Firebase: $token');
        final registerEntity = RegisterEntitie(
          first_name: firstNameController!.text,
          last_name: lastNameController!.text,
          id_cliente: int.parse(qrClientData.value['id_cliente'].toString()),
          email: emailRegisterController!.text,
          password: registerPasswordController!.text,
          token_device: token,
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