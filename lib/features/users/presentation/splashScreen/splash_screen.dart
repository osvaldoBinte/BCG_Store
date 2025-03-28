import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/common/widgets/rounded_logo_widget.dart';
import 'package:BCG_Store/features/users/presentation/splashScreen/splash_screen_controller.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      return Padding(
  padding: const EdgeInsets.only(bottom: 24.0),
  child: Center(
    child: RoundedLogoWidget(
      height: 160,
      borderRadius: 8.0,
    ),
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