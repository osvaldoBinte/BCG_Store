import 'package:BCG_Store/features/clients/domain/usecases/client_data_usecase.dart';
import 'package:BCG_Store/features/rewards/domain/usecases/get_clientes_app_rewards.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
  
  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    try {
      await _requestCameraPermission();
      await _requestStoragePermission();
      await _requestNotificationPermission();
      
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
          duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('❌ Error al solicitar permiso de cámara: $e');
    }
  }

 Future<void> _requestStoragePermission() async {
  try {
    if (GetPlatform.isIOS) {
      print('📱 Solicitando permiso de galería en iOS usando canal nativo...');
      
      // Usar el canal nativo para solicitar el permiso
      final bool permissionGranted = await PhotoPermissionHelper.requestPhotoLibraryPermission();
      
      storagePermissionGranted.value = permissionGranted;
      
      if (!permissionGranted) {
        Get.dialog(
          AlertDialog(
            title: Text('Permiso de Galería'),
            content: Text('Para poder guardar imágenes en tu galería, necesitamos que habilites el permiso en la configuración de tu dispositivo.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  openAppSettings();
                },
                child: Text('Abrir Configuración'),
              ),
            ],
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
}

  Future<void> _requestNotificationPermission() async {
    try {
      // Para Android 13 y superior, usar permission_handler
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
        
        if (result.isPermanentlyDenied) {
         checkNotificationPermission() ;
        } else if (result.isDenied) {
          // Si fue negado pero no permanentemente, volver a solicitar tras breve pausa
          await Future.delayed(Duration(seconds: 1));
          return _requestNotificationPermission();
        } else if (result.isGranted) {
         
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
        
        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          notificationPermissionGranted.value = true;
          // Registrar FCM token
        } else {
          // Solicitar nuevamente tras breve pausa
          await Future.delayed(Duration(seconds: 1));
          return _requestNotificationPermission();
        }
      }
    } catch (e) {
      print('❌ Error al solicitar permiso de notificaciones: $e');
    }
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
    isLoading.value = false;
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