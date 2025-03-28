import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:get/get.dart';
import 'package:BCG_Store/features/users/presentation/login/login_controller.dart';

class QRScannerWidget extends StatefulWidget {
  QRScannerWidget({Key? key}) : super(key: key);

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final LoginController controller = Get.find<LoginController>();
  late MobileScannerController scannerController;
  bool isTorchOn = false;
  
  @override
  void initState() {
    super.initState();
    // Inicializamos el controller aquí para asegurarnos de que sea nuevo cada vez
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      // Añadir formatos específicos de códigos QR y barras
      formats: [BarcodeFormat.qrCode],
    );
    
    // Asignamos el controller al controlador principal
    controller.qrScannerController = scannerController;
  }
  
  @override
  void dispose() {
    // Nos aseguramos de liberar los recursos del scanner al salir
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('qr_scanner'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ESCANEA EL CÓDIGO QR',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textTertiaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Para registrarte, escanea el código QR que te proporcionó el administrador',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Contenedor para el escáner QR con indicaciones visuales
        Container(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scanner de fondo
                MobileScanner(
                  controller: scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      final qrData = barcodes.first.rawValue!;
                      controller.onQRCodeDetected(qrData);
                    }
                  },
                  errorBuilder: (context, error, child) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error de cámara: ${error.errorCode}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Recrear el controller
                                scannerController.dispose();
                                scannerController = MobileScannerController(
                                  detectionSpeed: DetectionSpeed.normal,
                                  facing: CameraFacing.back,
                                  torchEnabled: false,
                                  formats: [BarcodeFormat.qrCode],
                                );
                                controller.qrScannerController = scannerController;
                                setState(() {});
                              },
                              child: Text('Reiniciar cámara'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // Overlay con marco de escaneo y línea animada
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                
                // Marco de escaneo
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                
                // Línea de escaneo animada
                ScannerAnimation(
                  width: 180,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Texto de instrucción adicional
        Text(
          'Coloca el código QR dentro del marco y mantén estable el dispositivo',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón para encender/apagar la linterna
            StatefulBuilder(
              builder: (context, setButtonState) {
                return ElevatedButton.icon(
                  onPressed: () {
                    scannerController.toggleTorch();
                    setButtonState(() => isTorchOn = !isTorchOn);
                  },
                  icon: Icon(
                    isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
                    color: AppTheme.secondaryColor,
                  ),
                  label: Text(isTorchOn ? 'Apagar' : 'Linterna'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                );
              },
            ),
            
            // Botón para cambiar de cámara
            ElevatedButton.icon(
              onPressed: () {
                scannerController.switchCamera();
              },
              icon: Icon(Icons.cameraswitch, color: AppTheme.secondaryColor),
              label: Text('Cambiar cámara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.secondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Botón para cancelar el escaneo
        TextButton(
          onPressed: controller.cancelQRScan,
          child: Text(
            'Cancelar escaneo',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
        ),
      ],
    );
  }
}

// Clase para animar la línea de escaneo
class ScannerAnimation extends StatefulWidget {
  final double width;
  final Color color;

  ScannerAnimation({required this.width, required this.color});

  @override
  _ScannerAnimationState createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<ScannerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: -100, end: 100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 150 + _animation.value,
          child: Container(
            height: 2,
            width: widget.width,
            decoration: BoxDecoration(
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.7),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}