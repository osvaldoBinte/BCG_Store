import 'package:BCG_Store/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:BCG_Store/app.dart';
import 'package:BCG_Store/common/settings/enviroment.dart';
import 'package:BCG_Store/common/services/theme_service.dart';
import 'package:BCG_Store/common/services/notification_service.dart'; 
import 'package:BCG_Store/framework/preferences_service.dart';
import 'package:get/get.dart';

String enviromentSelect = Enviroment.development.value;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  
  );
  
  print('=========ENVIROMENT SELECTED: $enviromentSelect');   
  await dotenv.load(fileName: enviromentSelect);
  await Get.putAsync(() => ThemeService().init());
  await PreferencesUser().initiPrefs();
  
  await NotificationService().initialize();
  
  runApp(const MyApp());
} 