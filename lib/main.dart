import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'features/webview/webview_screen.dart';
import 'services/connectivity_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

class InnovaApp extends StatelessWidget {
  const InnovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Innova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WebViewScreen(),
    );
  }
}
