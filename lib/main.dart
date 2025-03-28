// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:BCG_Store/app.dart';
import 'package:BCG_Store/common/settings/enviroment.dart';
import 'package:BCG_Store/common/services/theme_service.dart';
import 'package:BCG_Store/common/theme/App_Theme.dart';
import 'package:BCG_Store/features/users/presentation/home/home_controller.dart';
import 'package:BCG_Store/features/users/presentation/home/home_page.dart';
import 'package:BCG_Store/framework/preferences_service.dart';
import 'package:get/get.dart';
String enviromentSelect = Enviroment.testing.value;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 
  print('=========ENVIROMENT SELECTED: $enviromentSelect');                                         
  await dotenv.load(fileName: enviromentSelect);
    await Get.putAsync(() => ThemeService().init());
  await PreferencesUser().initiPrefs();

  runApp(const MyApp());
}

