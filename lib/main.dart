import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/app_colors.dart';
import 'services/websocket_service.dart';
import 'pages/connection_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.card,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.card,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const EMECoreMobileApp());
}

class EMECoreMobileApp extends StatefulWidget {
  const EMECoreMobileApp({super.key});

  @override
  State<EMECoreMobileApp> createState() => _EMECoreMobileAppState();
}

class _EMECoreMobileAppState extends State<EMECoreMobileApp> {
  final _wsService = WebSocketService();

  @override
  void dispose() {
    _wsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E.M.E Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.pri,
          surface: AppColors.card,
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      home: ConnectionPage(wsService: _wsService),
    );
  }
}
