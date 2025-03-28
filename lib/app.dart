// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/rewards/presentation/updateaccountdata/update_account_data_controller.dart';
import 'package:BCG_Store/features/users/presentation/changepassword/change_password_controller.dart';
import 'package:BCG_Store/features/clients/presentation/profile/profile_controller.dart';
import 'package:BCG_Store/features/clients/presentation/userdata/user_data_controller.dart';
import 'package:BCG_Store/features/users/presentation/login/login_controller.dart';
import 'package:BCG_Store/features/users/presentation/splashScreen/splash_screen_controller.dart';
import 'package:BCG_Store/features/users/presentation/home/home_controller.dart';
import 'package:BCG_Store/features/users/presentation/home/home_page.dart';
import 'package:BCG_Store/features/users/presentation/login/Login_screen.dart';
import 'package:BCG_Store/features/rewards/presentation/points/check_point_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/points/points_screen.dart';
import 'package:BCG_Store/features/rewards/presentation/getDataSells/get_data_sells_controller.dart';
import 'package:BCG_Store/features/rewards/presentation/getDataSells/get_data_sells_page.dart';
import 'package:BCG_Store/features/clients/presentation/userdata/user_data_page.dart';
import 'package:BCG_Store/usecase_config.dart';
import 'package:get/get.dart';

// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:BCG_Store/common/routes/navigation_service.dart';
import 'package:BCG_Store/common/routes/router.dart';
import 'package:BCG_Store/common/settings/routes_names.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/users/presentation/home/home_controller.dart';
import 'package:BCG_Store/features/users/presentation/home/home_page.dart';
import 'package:BCG_Store/features/users/presentation/login/Login_screen.dart';
import 'package:BCG_Store/features/rewards/presentation/points/points_screen.dart';
import 'package:BCG_Store/features/rewards/presentation/getDataSells/get_data_sells_page.dart';
import 'package:BCG_Store/features/clients/presentation/userdata/user_data_page.dart';
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
        Get.put(LoginController(loginUsecase: usecaseConfig.loginUsecase!, registerUsecase: usecaseConfig.registerUsecase!, recoveryPasswordUsecase: usecaseConfig.recoveryPasswordUsecase!, changePasswordUsecase: usecaseConfig.changePasswordUsecase!,));
        Get.put(SplashScreenController( clientDataUsecase: usecaseConfig.clientedataUsecase!,));
        Get.put(UserDataController(clientDataUsecase: usecaseConfig.clientedataUsecase!, getClientesAppRewards: usecaseConfig.getClientesAppRewards!,));
        Get.put(CheckPointController(checkPointUsecase: usecaseConfig.checkPointUsecase!));
        Get.put(ProfileController(clientDataUsecase: usecaseConfig.clientedataUsecase!));
        Get.put(GetDataSellsController(getDataSellsUsecase: usecaseConfig.getDataSellsUsecase!));
        Get.put(ChangePasswordController(changePasswordUsecase: usecaseConfig.changePasswordUsecase!));
        Get.put(UpdateAccountDataController(updateAccountDataUsecase: usecaseConfig.updateAccountDataUsecase!));
      }),
      
      initialRoute: RoutesNames.welcomePage, 
      getPages: AppPages.routes, 
      unknownRoute: AppPages.unknownRoute, 
    );
  }
}