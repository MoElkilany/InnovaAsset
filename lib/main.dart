import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/asset_registration/data/models/asset_description_model.dart';
import 'features/asset_registration/data/models/asset_model.dart';
import 'features/asset_registration/data/models/category_model.dart';
import 'features/asset_registration/data/models/location_model.dart';
import 'features/asset_registration/presentation/screens/asset_form_screen.dart';
import 'features/webview/webview_screen.dart';
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await _initHive();

  // Setup dependency injection
  await setupLocator();

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppTheme.primaryColor,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Boot connectivity monitoring
  ConnectivityService.instance.initialize();

  runApp(const InnovaApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(AssetModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(LocationModelAdapter());
  Hive.registerAdapter(AssetDescriptionModelAdapter());

  // Open boxes
  await Future.wait([
    Hive.openBox<AssetModel>(AppConstants.assetsBox),
    Hive.openBox<CategoryModel>(AppConstants.categoriesBox),
    Hive.openBox<LocationModel>(AppConstants.locationsBox),
    Hive.openBox<AssetDescriptionModel>(AppConstants.descriptionsBox),
  ]);
}

class InnovaApp extends StatelessWidget {
  const InnovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<bool>(
        stream: ConnectivityService.instance.onConnectivityChanged,
        initialData: true,
        builder: (context, snapshot) {
          final isOnline = snapshot.data ?? true;
          return isOnline ? const WebViewScreen() : const AssetFormScreen();
        },
      ),
    );
  }
}
