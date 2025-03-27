import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gerena/common/settings/routes_names.dart';
import 'package:gerena/features/users/presentation/login/login_controller.dart';
import 'package:get/get.dart';

class NavigationService extends GetxService {
  static NavigationService get to => Get.find();
  
  Future<void> navigateToHome({required int initialIndex}) async {
    await Get.offAllNamed(
      RoutesNames.homePage,
      arguments: initialIndex,
      predicate: (route) => false, 
    );
  }

  Future<void> navigateToLogin() async {
    Get.delete<LoginController>(force: true);
    await Get.offAllNamed(
      RoutesNames.loginPage,
      predicate: (route) => false, 
    );
  }

  Future<void> navigateToPoints() async {
    await Get.offAllNamed(
      RoutesNames.pointsPage,
      predicate: (route) => false,
    );
  }

  Future<void> navigateToUserData() async {
    await Get.offAllNamed(
      RoutesNames.userDataPage,
      predicate: (route) => false,
    );
  }
  

  Future<void> navigateToPurchases() async {
    await Get.offAllNamed(
      RoutesNames.purchasesPage,
      predicate: (route) => false,
    );
  }
  Future<void> navigateToShoppingCart() async {
    await Get.offAllNamed(
      RoutesNames.shoppingCartPage,
      predicate: (route) => false,
    );
  }
}