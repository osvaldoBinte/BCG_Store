// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gerena/common/routes/navigation_service.dart';
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:gerena/features/rewards/presentation/updateaccountdata/update_account_data_controller.dart';
import 'package:gerena/features/users/presentation/changepassword/change_password_controller.dart';
import 'package:gerena/features/clients/presentation/profile/profile_controller.dart';
import 'package:gerena/features/clients/presentation/userdata/user_data_controller.dart';
import 'package:gerena/features/users/presentation/login/login_controller.dart';
import 'package:gerena/features/users/presentation/splashScreen/splash_screen_controller.dart';
import 'package:gerena/features/users/presentation/home/home_controller.dart';
import 'package:gerena/features/users/presentation/home/home_page.dart';
import 'package:gerena/features/users/presentation/login/Login_screen.dart';
import 'package:gerena/features/rewards/presentation/points/check_point_controller.dart';
import 'package:gerena/features/rewards/presentation/points/points_screen.dart';
import 'package:gerena/features/rewards/presentation/getDataSells/get_data_sells_controller.dart';
import 'package:gerena/features/rewards/presentation/getDataSells/get_data_sells_page.dart';
import 'package:gerena/features/clients/presentation/userdata/user_data_page.dart';
import 'package:gerena/usecase_config.dart';
import 'package:get/get.dart';

// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gerena/common/routes/navigation_service.dart';
import 'package:gerena/common/routes/router.dart';
import 'package:gerena/common/settings/routes_names.dart';
import 'package:gerena/common/theme/App_Theme.dart';
import 'package:gerena/features/users/presentation/home/home_controller.dart';
import 'package:gerena/features/users/presentation/home/home_page.dart';
import 'package:gerena/features/users/presentation/login/Login_screen.dart';
import 'package:gerena/features/rewards/presentation/points/points_screen.dart';
import 'package:gerena/features/rewards/presentation/getDataSells/get_data_sells_page.dart';
import 'package:gerena/features/clients/presentation/userdata/user_data_page.dart';
import 'package:get/get.dart';
UsecaseConfig usecaseConfig = UsecaseConfig();


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialBinding: BindingsBuilder(() {
        Get.put(NavigationService());
        Get.put(HomeController());
        Get.put(LoginController(loginUsecase: usecaseConfig.loginUsecase!, registerUsecase: usecaseConfig.registerUsecase!,));
        Get.put(SplashScreenController( clientDataUsecase: usecaseConfig.clientedataUsecase!,));
        Get.put(UserDataController(clientDataUsecase: usecaseConfig.clientedataUsecase!, getClientesAppRewards: usecaseConfig.getClientesAppRewards!,));
        Get.put(CheckPointController(checkPointUsecase: usecaseConfig.checkPointUsecase!));
        Get.put(ProfileController(clientDataUsecase: usecaseConfig.clientedataUsecase!));
        Get.put(PurchasesController(getDataSellsUsecase: usecaseConfig.getDataSellsUsecase!));
        Get.put(ChangePasswordController(changePasswordUsecase: usecaseConfig.changePasswordUsecase!));
        Get.put(UpdateAccountDataController(updateAccountDataUsecase: usecaseConfig.updateAccountDataUsecase!));
      }),
      
      initialRoute: RoutesNames.welcomePage, 
      getPages: AppPages.routes, 
      unknownRoute: AppPages.unknownRoute, 
    );
  }
}