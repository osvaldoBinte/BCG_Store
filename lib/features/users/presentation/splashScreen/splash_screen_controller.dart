import 'dart:async';

import 'package:BCG_Store/features/clients/domain/usecases/client_data_usecase.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/get_clientes_app_rewards.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class PhotoPermissionHelper {
  static const platform = MethodChannel('com.bgcstore.photoPermission');
  
  static Future<bool> requestPhotoLibraryPermission() async {
    try {
      final bool result = await platform.invokeMethod('requestPhotoAccess');
      print('📱 Resultado de solicitud de permiso PhotoLibrary: $result');
      return result;
    } on PlatformException catch (e) {
      print('❌ Error al solicitar permiso PhotoLibrary: ${e.message}');
      return false;
    }
  }
}

class SplashScreenController extends GetxController {
  final GetClientesAppRewards getClientesAppRewards;
  
  SplashScreenController({
    required this.getClientesAppRewards,
  });
  
  final RxBool isLoading = true.obs;
  final RxString companyName = "".obs;
  
  // Variables para controlar el estado de los permisos
  final RxBool cameraPermissionGranted = false.obs;
  final RxBool storagePermissionGranted = false.obs;
  final RxBool notificationPermissionGranted = false.obs;
  
  // Timer para asegurar que la pantalla de splash no se quede cargando indefinidamente
  Timer? _timeoutTimer;
  
  @override
  void onInit() {
    super.onInit();
    // Establecer un tiempo máximo para la pantalla de splash
    _setTimeoutTimer();
    _requestPermissions();
  }
  
  @override
  void onClose() {
    _timeoutTimer?.cancel();
    super.onClose();
  }
  
  void _setTimeoutTimer() {
    // Si después de 10 segundos no se ha completado el proceso, forzar navegación
    _timeoutTimer = Timer(Duration(seconds: 10), () {
      if (isLoading.value) {
        print('⚠️ Tiempo de espera excedido, redirigiendo al login');
        isLoading.value = false;
        Get.offAllNamed('/login');
      }
    });
  }
  
  Future<void> _requestPermissions() async {
    try {
      // Solicitar permisos en paralelo para ser más eficientes
      await Future.wait([
        _requestStoragePermission(),
        _requestNotificationPermission(),
        _requestCameraPermission(),

      ]);
      
      // Continuar con la autenticación independientemente del resultado de los permisos
      await checkAuthentication();
    } catch (e) {
      print('❌ Error general al solicitar permisos: $e');
      await checkAuthentication();
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        cameraPermissionGranted.value = true;
        print('✅ Permiso de cámara ya concedido');
        return;
      }
      
      final result = await Permission.camera.request();
      cameraPermissionGranted.value = result.isGranted;
      
      print('📸 Estado del permiso de cámara: $result');
      
      if (result.isPermanentlyDenied) {
        
      } else if (result.isDenied) {
        Get.snackbar(
          'Permiso de Cámara', 
          'Se requiere acceso a la cámara para el correcto funcionamiento de la aplicación',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
           mainButton: TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Configuración', style: TextStyle(color: Colors.white)),
            ),
        );
      }
    } catch (e) {
      print('❌ Error al solicitar permiso de cámara: $e');
    }
    // Siempre continuar, sin importar el resultado
  }

  Future<void> _requestStoragePermission() async {
    try {
      if (GetPlatform.isIOS) {
        print('📱 Solicitando permiso de galería en iOS usando canal nativo...');
        
        // Usar el canal nativo para solicitar el permiso
        final bool permissionGranted = await PhotoPermissionHelper.requestPhotoLibraryPermission();
        
        storagePermissionGranted.value = permissionGranted;
        
        if (!permissionGranted) {
          // Mostrar diálogo pero no esperar por respuesta del usuario
          Get.snackbar(
            'Permiso de Galería',
            'Se requiere acceso a la galería para guardar imágenes',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
            mainButton: TextButton(
              onPressed: () => openAppSettings(),
              child: Text('Configuración', style: TextStyle(color: Colors.white)),
            ),
          );
        }
      } else if (GetPlatform.isAndroid) {
        try {
          final photosStatus = await Permission.photos.status;
          if (!photosStatus.isGranted) {
            final result = await Permission.photos.request();
            storagePermissionGranted.value = result.isGranted;
            print('📱 Estado del permiso de fotos: $result');
            
            if (!result.isGranted) {
              final videosResult = await Permission.videos.request();
              storagePermissionGranted.value = storagePermissionGranted.value || videosResult.isGranted;
              print('🎥 Estado del permiso de videos: $videosResult');
            }
          } else {
            storagePermissionGranted.value = true;
          }
        } catch (e) {
          print('Intentando con permiso de almacenamiento tradicional...');
          final storageStatus = await Permission.storage.status;
          if (!storageStatus.isGranted) {
            final result = await Permission.storage.request();
            storagePermissionGranted.value = result.isGranted;
            print('💾 Estado del permiso de almacenamiento: $result');
          } else {
            storagePermissionGranted.value = true;
          }
        }
      }
    } catch (e) {
      print('❌ Error general al solicitar permiso de galería: $e');
    }
    // Siempre continuar, sin importar el resultado
  }

  Future<void> _requestNotificationPermission() async {
    try {
      if (GetPlatform.isAndroid) {
        final status = await Permission.notification.status;
        
        if (status.isGranted) {
          notificationPermissionGranted.value = true;
          print('✅ Permiso de notificaciones ya concedido');
          return;
        }
        
        final result = await Permission.notification.request();
        notificationPermissionGranted.value = result.isGranted;
        
        print('🔔 Estado del permiso de notificaciones: $result');
        
        // Solo mostrar un mensaje informativo, sin bloquear el flujo
        if (result.isPermanentlyDenied || result.isDenied) {
          Get.snackbar(
            'Notificaciones', 
            'Las notificaciones están desactivadas. No recibirás alertas importantes.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      } else if (GetPlatform.isIOS) {
        // Para iOS usar FirebaseMessaging directamente
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        
        print('🔔 Estado de autorización iOS: ${settings.authorizationStatus}');
        
        notificationPermissionGranted.value = 
            settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      }
    } catch (e) {
      print('❌ Error al solicitar permiso de notificaciones: $e');
    }
    // Siempre continuar, sin importar el resultado
  }

  Future<void> checkAuthentication() async {
    try {
      final clientesData = await getClientesAppRewards.execute();
      
      if (clientesData.isEmpty || clientesData.first.token_device == null || clientesData.first.token_device!.isEmpty) {
        print('⚠️ Datos de cliente insuficientes o token de dispositivo no encontrado');
        Get.offAllNamed('/login');
        return;
      }
      
      print('✅ Autenticación exitosa con token: ${clientesData.first.token_device}');
      Get.offAllNamed('/homePage');
      
    } catch (e) {
      print('⚠️ Error al obtener datos de cliente: $e');
      Get.offAllNamed('/login');
    } finally {
      // Asegurar que isLoading se establece como false
      isLoading.value = false;
      // Cancelar el temporizador de timeout ya que la operación se completó
      _timeoutTimer?.cancel();
    }
  }
  
  Future<bool> checkCameraPermission() async {
    if (cameraPermissionGranted.value) return true;
    
    return _requestCameraPermission().then((_) => cameraPermissionGranted.value);
  }
  
  Future<bool> checkStoragePermission() async {
    if (storagePermissionGranted.value) return true;
    
    return _requestStoragePermission().then((_) => storagePermissionGranted.value);
  }
  
  Future<bool> checkNotificationPermission() async {
    if (notificationPermissionGranted.value) return true;
    
    return _requestNotificationPermission().then((_) => notificationPermissionGranted.value);
  }
}