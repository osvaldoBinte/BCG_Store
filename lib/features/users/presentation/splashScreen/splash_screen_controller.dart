import 'package:BCG_Store/features/clients/domain/usecases/client_data_usecase.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class SplashScreenController extends GetxController {
  final ClientDataUsecase clientDataUsecase;
  
  SplashScreenController({
    required this.clientDataUsecase,
  });
  
  final RxBool isLoading = true.obs;
  final RxString companyName = "".obs;
  
  // Variables para controlar el estado de los permisos
  final RxBool cameraPermissionGranted = false.obs;
  final RxBool storagePermissionGranted = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    try {
      await _requestCameraPermission();
      
      await _requestStoragePermission();
      
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
        _showPermanentlyDeniedDialog(
          'Permiso de Cámara', 
          'Necesitamos acceso a la cámara para escanear códigos QR. Por favor habilita el permiso en la configuración de la aplicación.'
        );
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
      Permission storagePermission;
      if (GetPlatform.isAndroid) {
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
      } else if (GetPlatform.isIOS) {
        final photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted) {
          final result = await Permission.photos.request();
          storagePermissionGranted.value = result.isGranted;
          print('📱 Estado del permiso de fotos iOS: $result');
        } else {
          storagePermissionGranted.value = true;
        }
      }
      
      if (!storagePermissionGranted.value) {
        Get.snackbar(
          'Permiso de Galería', 
          'Se requiere acceso a fotos y videos para compartir contenido',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('❌ Error al solicitar permiso de galería: $e');
    }
  }

  void _showPermanentlyDeniedDialog(String title, String message) {
    if (Get.context != null) {
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Cierra el diálogo
                openAppSettings(); // Abre la configuración de la aplicación
              },
              child: Text('Abrir Configuración'),
            ),
          ],
        ),
      );
    }
  }
  
  Future<void> checkAuthentication() async {
    try {
      final clientData = await clientDataUsecase.execute();
      if (clientData.isNotEmpty) {
        companyName.value = clientData.first.empresa;
        print('✅ Nombre de empresa obtenido: ${companyName.value}');
        Get.offAllNamed('/homePage');
      }
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
}