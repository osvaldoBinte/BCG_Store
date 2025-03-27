import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:gerena/features/users/presentation/splashScreen/splash_screen_controller.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializar y obtener el controlador
    final SplashScreenController controller = Get.find<SplashScreenController>();
    
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           ClipRRect(
  borderRadius: BorderRadius.circular(16.0), 
  child: Image.network(
    AppTheme.logoUrl.isNotEmpty
        ? AppTheme.logoUrl
        : AppTheme.defaultLogoAsset,
    height: 160,
    width: 300,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return ClipRRect( 
        borderRadius: BorderRadius.circular(16.0),
        child: Image.network(
          AppTheme.defaultLogoAsset,
          height: 160,
          width: 300,
          fit: BoxFit.contain,
        ),
      );
    },
  ),
),
            const SizedBox(height: 30),
            
            Obx(() => controller.isLoading.value
                ? SpinKitHourGlass(
                    color: AppTheme.primaryColor,
                    size: 50.0,
                  )
                : const SizedBox.shrink()
            ),
            
            const SizedBox(height: 20),
           
          ],
        ),
      ),
    );
  }
}