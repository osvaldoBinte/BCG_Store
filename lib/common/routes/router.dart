import 'package:flutter/material.dart';
import 'package:gerena/common/settings/routes_names.dart';
import 'package:gerena/features/rewards/presentation/updateaccountdata/update_account_data_page.dart';
import 'package:gerena/features/users/presentation/changepassword/change_password_page.dart';
import 'package:gerena/features/users/presentation/splashScreen/splash_screen.dart';
import 'package:gerena/features/users/presentation/home/home_page.dart';
import 'package:gerena/features/users/presentation/login/Login_screen.dart';
import 'package:gerena/features/rewards/presentation/points/points_screen.dart';
import 'package:gerena/features/rewards/presentation/getDataSells/get_data_sells_page.dart';
import 'package:gerena/page/shoppingCart/shopping_cart_screen.dart';
import 'package:gerena/features/clients/presentation/userdata/user_data_page.dart';
import 'package:get/get.dart';
class AppPages {
  static final routes = [
    GetPage(
      name: RoutesNames.welcomePage,
      page:  () => SplashScreen(),
    ),
    GetPage(
      name: RoutesNames.homePage,
 page: () {
        final initialIndex = Get.arguments is int ? Get.arguments : 0;
        return HomePage(initialIndex: initialIndex);
      },    ),
    GetPage(
      name: RoutesNames.loginPage,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: RoutesNames.changePasswordPage,
      page: () => ChangePasswordPage(),
    ),
    GetPage(
      name: RoutesNames.pointsPage,
      page: () => PointsScreen(),
    ),
   GetPage(
      name: RoutesNames.userDataPage,
      page: () => UserDataPage(),
    ),
    GetPage(
      name: RoutesNames.purchasesPage,
      page: () => GetDataSellsPage(),
    ),
    GetPage(
      name: RoutesNames.shoppingCartPage,
      page: () => ShoppingCartScreen(),
    ),
    GetPage(
      name: RoutesNames.updateAccountDataPage,
      page: () => UpdateAccountDataPage(),
      
    ),
  ];

  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada'),
      ),
    ),
  );
}