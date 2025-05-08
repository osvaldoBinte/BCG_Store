import 'package:BCG_Store/common/services/auth_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/clients/domain/entities/client_data_entitie.dart';
import 'package:BCG_Store/features/clients/domain/usecases/client_data_usecase.dart';
import 'package:BCG_Store/features/clients/presentation/profile/custom_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:url_launcher/url_launcher.dart';
import 'qr_loading_widget.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ProfileController extends GetxController {
  final ClientDataUsecase clientDataUsecase;
  
  final Rx<ClientDataEntitie?> clientData = Rx<ClientDataEntitie?>(null);
  
  final RxBool isLoading = false.obs;
  final RxBool isDownloading = false.obs;
  
  final RxString errorMessage = ''.obs;
  final Dio _dio = Dio(); // Para descargas
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin(); // Para info del dispositivo

  ProfileController({required this.clientDataUsecase});

  @override
  void onInit() {
    super.onInit();
    fetchClientData();
    _requestPermissions();
    
    // Suscribirse a eventos de cambio de ruta para recargar datos cuando sea necesario
    ever(Get.routing.current.obs, (_) {
      if (Get.routing.current == '/home') {
        // Recargar datos cuando se navega a la página de inicio
        fetchClientData();
      }
    });
  }
Future<void> forceReload() async {
    await fetchClientData();
  }

  // Método para solicitar permisos al inicio
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      try {
        // Obtenemos la versión de Android
        final androidInfo = await _deviceInfo.androidInfo;
        final sdkVersion = androidInfo.version.sdkInt;
        
        if (sdkVersion >= 33) { // Android 13+
          await Permission.photos.request();
        } else {
          await Permission.storage.request();
        }
      } catch (e) {
        print('Error al solicitar permisos: $e');
        // Intentamos solicitar ambos permisos por si acaso
        await Permission.storage.request();
      }
    }
  }

  // Método para obtener los datos del cliente
 Future<void> fetchClientData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Añadimos log para debugging
      print('🔄 Cargando datos del cliente...');
      
      // Primer intento
      final clients = await clientDataUsecase.execute();
      
      if (clients.isNotEmpty) {
        clientData.value = clients.first;
        print('✅ Datos del cliente cargados exitosamente');
        print('🔗 URL del QR: ${clientData.value?.url_qr}');
      } else {
        // Si no hay clientes en el primer intento, reintentamos después de un breve retraso
        await Future.delayed(Duration(milliseconds: 500));
        print('⚠️ Primer intento sin datos, reintentando...');
        
        final retriedClients = await clientDataUsecase.execute();
        if (retriedClients.isNotEmpty) {
          clientData.value = retriedClients.first;
          print('✅ Datos del cliente cargados en el segundo intento');
          print('🔗 URL del QR: ${clientData.value?.url_qr}');
        } else {
          errorMessage.value = 'No se encontraron datos de cliente';
          print('❌ No se encontraron datos del cliente después de reintentar');
        }
      }
    } catch (e) {
      print('❌ Error al cargar datos del cliente: $e');
      errorMessage.value = 'Error al cargar datos: ${e.toString()}';
      
      // Reintentamos una vez más después de un error
      try {
        await Future.delayed(Duration(seconds: 1));
        print('🔄 Reintentando después de error...');
        
        final retriedClients = await clientDataUsecase.execute();
        if (retriedClients.isNotEmpty) {
          clientData.value = retriedClients.first;
          errorMessage.value = '';
          print('✅ Datos del cliente cargados después de error previo');
          print('🔗 URL del QR: ${clientData.value?.url_qr}');
        }
      } catch (_) {
        // Si falla el reintento, mantenemos el mensaje de error original
        print('❌ Falló el reintento después de error');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadQR(BuildContext context) async {
  if (clientData.value?.url_qr == null || clientData.value!.url_qr!.isEmpty) {
    Get.snackbar(
      'Error', 
      'No hay un código QR disponible para descargar',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  try {
    isDownloading.value = true;
    
    // Verificar permisos según la plataforma
    if (Platform.isAndroid) {
       bool permissionGranted = false;
      
      try {
        final androidInfo = await _deviceInfo.androidInfo;
        final sdkVersion = androidInfo.version.sdkInt;
        
        if (sdkVersion >= 33) { // Android 13+
          var photos = await Permission.photos.status;
          if (photos.isGranted) {
            permissionGranted = true;
          } else {
            var requestStatus = await Permission.photos.request();
            permissionGranted = requestStatus.isGranted;
          }
        } else {
          var storage = await Permission.storage.status;
          if (storage.isGranted) {
            permissionGranted = true;
          } else {
            var requestStatus = await Permission.storage.request();
            permissionGranted = requestStatus.isGranted;
          }
        }
      } catch (e) {
        print('Error al verificar permisos: $e');
        var storage = await Permission.storage.request();
        permissionGranted = storage.isGranted;
      }
      
      if (!permissionGranted) {
        isDownloading.value = false;
        Get.snackbar(
          'Permiso denegado', 
          'Se requiere permiso para guardar la imagen',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
    } else if (Platform.isIOS) {
      // Para iOS, verificar permiso de PhotoLibrary
      var photos = await Permission.photos.status;
      print('Estado de permiso fotos iOS: $photos');
      
      if (photos.isDenied || photos.isPermanentlyDenied) {
        // Si está denegado, solicitar mediante nuestro canal personalizado
        const platform = MethodChannel('com.bgcstore.photoPermission');
        try {
          final bool result = await platform.invokeMethod('requestPhotoAccess');
          if (!result) {
            isDownloading.value = false;
            Get.snackbar(
              'Permiso denegado', 
              'Se requiere acceso a la galería para guardar la imagen',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              mainButton: TextButton(
                onPressed: () {
                  openAppSettings();
                },
                child: Text('ABRIR AJUSTES', style: TextStyle(color: Colors.white)),
              ),
            );
            return;
          }
        } catch (e) {
          print('Error al solicitar permiso con canal: $e');
          isDownloading.value = false;
          Get.snackbar(
            'Error de permiso', 
            'No se pudo solicitar permiso para la galería',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }
    }

    // Primero descargamos la imagen a un archivo temporal
    final tempDir = await getTemporaryDirectory();
    final fileName = "QR_ID_${DateTime.now().millisecondsSinceEpoch}.png";
    final tempFile = File('${tempDir.path}/$fileName');
    
    try {
      // Intentar descargar con Dio
      await _dio.download(
        clientData.value!.url_qr!,
        tempFile.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('${(received / total * 100).toStringAsFixed(0)}%');
          }
        }
      );
    } catch (dioError) {
      print('Error Dio al descargar: $dioError');
      // Intentar con http como alternativa
      final response = await http.get(Uri.parse(clientData.value!.url_qr!));
      if (response.statusCode == 200) {
        await tempFile.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    }
    
    // Ahora guardar en la galería según la plataforma
    if (Platform.isIOS) {
      // Para iOS, usamos image_gallery_saver
      // Añade image_gallery_saver: ^2.0.3 a tus dependencias
      try {
        // Importar el paquete en la parte superior del archivo
        // import 'package:image_gallery_saver/image_gallery_saver.dart';
        
        // Leer el archivo como bytes
        final bytes = await tempFile.readAsBytes();
        
        // Guardar en la galería
        final result = await ImageGallerySaver.saveImage(
          bytes,
          quality: 100,
          name: fileName
        );
        
        print('Resultado de guardar en galería iOS: $result');
        
        if (result['isSuccess'] == true) {
          Get.snackbar(
            'Guardado', 
            'Código QR guardado en tu galería de fotos',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            mainButton: TextButton(
              onPressed: () {
                Share.shareXFiles([XFile(tempFile.path)], text: 'Mi código QR ID');
              },
              child: Text('COMPARTIR', style: TextStyle(color: Colors.white)),
            ),
          );
        } else {
          throw Exception('No se pudo guardar en la galería: ${result['errorMessage']}');
        }
      } catch (e) {
        print('Error al guardar en galería iOS: $e');
        throw Exception('Error al guardar en la galería de iOS: $e');
      }
    } else if (Platform.isAndroid) {
      // Para Android, el archivo ya está guardado en la ruta de descargas
      String? savePath;
      
      try {
        // Intentamos obtener el directorio de descargas
        Directory? directory;
        
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            throw Exception('Download directory does not exist');
          }
        } catch (e) {
          print('Error con directorio de descargas estándar: $e');
          try {
            directory = await getExternalStorageDirectory();
            if (directory == null) {
              throw Exception('External storage directory is null');
            }
          } catch (e) {
            print('Error con getExternalStorageDirectory: $e');
            directory = await getTemporaryDirectory();
          }
        }
        
        savePath = "${directory.path}/$fileName";
        
        // Copiar el archivo temporal al directorio de descargas
        await tempFile.copy(savePath);
        
        // Notificar a la galería sobre el nuevo archivo (opcional)
        try {
          // Usar MediaScanner para actualizar la galería
          await _scanFile(savePath);
        } catch (scanError) {
          print('Error al escanear archivo (no crítico): $scanError');
        }
        
        Get.snackbar(
          'Descargado', 
          'Código QR guardado en tu galería',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () {
              Share.shareXFiles([XFile(savePath!)], text: 'Mi código QR ID');
            },
            child: Text('COMPARTIR', style: TextStyle(color: Colors.white)),
          ),
        );
      } catch (e) {
        print('Error al guardar en Android: $e');
        throw Exception('Error al guardar en Android: $e');
      }
    }
  } catch (e) {
    print('Error final en downloadQR: $e');
    isDownloading.value = false;
    Get.snackbar(
      'Error', 
      'No se pudo descargar el QR: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isDownloading.value = false;
  }
}
Future<void> _scanFile(String path) async {
  try {
    if (Platform.isAndroid) {
      const platform = MethodChannel('com.bgcstore.mediaScanner');
      await platform.invokeMethod('scanFile', {'path': path});
    }
  } catch (e) {
    print('Error al escanear archivo: $e');
  }
}
  // Método para compartir el QR
  Future<void> shareQR(BuildContext context) async {
    if (clientData.value?.url_qr == null || clientData.value!.url_qr!.isEmpty) {
      Get.snackbar(
        'Error', 
        'No hay un código QR disponible para compartir',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isDownloading.value = true;
      
      // Descargar la imagen temporalmente
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/mi_qr_id.png');
      
      try {
        // Intentar con Dio primero
        await _dio.download(
          clientData.value!.url_qr!,
          file.path,
        );
      } catch (dioError) {
        print('Error Dio al compartir: $dioError');
        // Intentar con http como fallback
        final response = await http.get(Uri.parse(clientData.value!.url_qr!));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('No se pudo descargar la imagen para compartir');
        }
      }
      
      isDownloading.value = false;
      
      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Mi código QR ID',
      );
    } catch (e) {
      print('Error al compartir: $e');
      isDownloading.value = false;
      Get.snackbar(
        'Error', 
        'Ha ocurrido un error al compartir: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

void showQRModal(BuildContext context) async {
  if (clientData.value == null || clientData.value?.url_qr == null || clientData.value!.url_qr!.isEmpty) {
    Get.dialog(
      Center(
        child: CustomLoadingScreen(
          message: 'Preparando el código QR...',
        ),
      ),
      barrierDismissible: false,
    );
    
    try {
      print('🔄 Cargando datos del cliente antes de mostrar QR...');
      await fetchClientData();
      
      if (clientData.value == null || clientData.value?.url_qr == null || clientData.value!.url_qr!.isEmpty) {
        print('⚠️ Primer intento sin datos de QR, esperando más tiempo...');
        await Future.delayed(Duration(seconds: 2));
        
        await fetchClientData();
        print('🔍 Después del segundo intento: ${clientData.value?.url_qr}');
      }
    } catch (e) {
      print('❌ Error al precargar datos para QR: $e');
    } finally {
      Get.back();
    }
  }
  
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Material(
                color: Colors.black54, 
                child: Stack(
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      tween: Tween<double>(begin: screenHeight, end: 0),
                      builder: (_, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: child,
                        );
                      },
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {}, // Evita que el tap se propague al fondo
                          child: Container(
                            width: screenWidth,
                            constraints: BoxConstraints(
                              maxHeight: screenHeight * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundGrey,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.dividerColor.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Línea de arrastre
                                  Container(
                                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppTheme.dividerColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 16),
                                        Text(
                                          'MI QR ID',
                                          style: AppTheme.theme.textTheme.headlineMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        
                                        // Botón para forzar recarga si hay problemas
                                        if (clientData.value == null || clientData.value?.url_qr == null || clientData.value!.url_qr!.isEmpty)
                                          _buildActionButton(
                                                      icon: Icons.download,
                                                      label: 'Actualizar QR',
                                                      isLoading: isDownloading.value,
                                                      onPressed: () => fetchClientData(),
                                                    ),
                                                    
                                        
                                        // Usamos Obx para reaccionar a cambios en clientData
                                        Obx(() {
                                          if (isLoading.value) {
                                            // Reemplazamos el CircularProgressIndicator con CustomLoadingScreen
                                            return SizedBox(
                                              height: 200,
                                              child: CustomLoadingScreen(
                                                message: 'Cargando tu código QR...',
                                              ),
                                            );
                                          } else if (errorMessage.value.isNotEmpty) {
                                            return Column(
                                              children: [
                                                Text(
                                                  'Error: ${errorMessage.value}',
                                                  style: AppTheme.theme.textTheme.bodyMedium?.copyWith(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                SizedBox(height: 16),
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    await fetchClientData();
                                                  },
                                                  icon: Icon(Icons.refresh, size: 16),
                                                  label: Text('Reintentar'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppTheme.primaryColor,
                                                    foregroundColor: AppTheme.secondaryColor,
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else if (clientData.value?.url_qr != null && clientData.value!.url_qr!.isNotEmpty) {
                                            // Si tenemos una URL de QR, mostramos la imagen
                                            return Column(
                                              children: [
                                                Container(
                                                  width: 200,
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      clientData.value!.url_qr!,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        print('❌ Error cargando imagen de QR: $error');
                                                        return Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              Icons.error_outline,
                                                              size: 40,
                                                              color: Colors.red,
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              'Error al cargar QR',
                                                              textAlign: TextAlign.center,
                                                              style: AppTheme.theme.textTheme.bodyMedium,
                                                            ),
                                                            const SizedBox(height: 12),
                                                            TextButton(
                                                              onPressed: () async {
                                                                await fetchClientData();
                                                              },
                                                              child: Text('Reintentar'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        
                                                        // Usamos widget personalizado de carga QR
                                                        return QRLoadingWidget(
                                                          progress: loadingProgress.expectedTotalBytes != null
                                                              ? loadingProgress.cumulativeBytesLoaded / 
                                                                loadingProgress.expectedTotalBytes!
                                                              : null,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                
                                                // Botones de acción
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    // Botón de descargar
                                                    _buildActionButton(
                                                      icon: Icons.download,
                                                      label: 'Descargar',
                                                      isLoading: isDownloading.value,
                                                      onPressed: () => downloadQR(context),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    // Botón de compartir
                                                    _buildActionButton(
                                                      icon: Icons.share,
                                                      label: 'Compartir',
                                                      isLoading: isDownloading.value,
                                                      onPressed: () => shareQR(context),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.grey.shade300),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/icons-qr-code-scan.png', 
                                                    width: 64,
                                                    height: 64, 
                                                  ),
                                                  SizedBox(height: 16),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                                    child: Text(
                                                      'No hay código QR disponible',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.grey.shade700,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                                    child: Text(
                                                      'Contacta al administrador para obtener tu QR',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
                                                 
                                                ],
                                              ),
                                            );
                                          }
                                        }),
                                        
                                        const SizedBox(height: 24),
                                         _buildActionButton(
                                                      icon: Icons.download,
                                                      label: 'Cerrar',
                                                      isLoading: isDownloading.value,
 onPressed: () {
                                            Navigator.pop(context);
                                          },                                                    ),
                                        
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}
  
  // Widget para construir botones de acción
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      label: Text(label),
    );
  }
  Future<void> openWebsiteFromSession() async {
  try {
    final auth = AuthService();
    final session = await auth.getSession();
    
    print('Sitio web desde sesión: ${session?.sitioWeb}');
    
    if (session?.sitioWeb != null && session!.sitioWeb!.isNotEmpty) {
      final url = session.sitioWeb!;
      
      // Imprimir la URL para depuración
      print('Intentando abrir URL: $url');
      
      // Crea una Uri sin modificaciones
      final uri = Uri.parse(url);
      
      // Intenta con el modo universal primero
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      
      if (!launched) {
        print('Intento 1 fallido, probando con externalApplication');
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          print('Intento 2 fallido, probando con inAppWebView');
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );
          
          if (!launched) {
            print('Todos los intentos fallaron');
            throw 'No se pudo abrir la URL: $url';
          }
        }
      }
    } else {
      print('ℹ️ No hay sitio web disponible');
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text('No hay sitio web disponible'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    print('❌ Error al abrir URL: $e');
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text('No se pudo abrir el sitio web. ${e.toString()}'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
}