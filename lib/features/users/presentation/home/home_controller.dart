import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  DateTime? lastBackPressTime;

  void setIndex(int index) {
    selectedIndex.value = index;
  }

Future<bool> handleBackButton(int initialIndex) async {
    if (selectedIndex.value != initialIndex) {
      selectedIndex.value = initialIndex;
      return false;
    }
    
    if (lastBackPressTime == null || 
        DateTime.now().difference(lastBackPressTime!) > Duration(seconds: 2)) {
      lastBackPressTime = DateTime.now();
      Get.showSnackbar(
        GetSnackBar(
          message: 'Presiona nuevamente para salir',
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    
    // Minimize app
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return false;
  }
  
}