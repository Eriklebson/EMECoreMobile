import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/websocket_service.dart';
import 'pages/connection_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF1B2838),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF1B2838),
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
        scaffoldBackgroundColor: const Color(0xFF161719),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF66C0F4),
          surface: Color(0xFF1B2838),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1B2838),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      home: ConnectionPage(wsService: _wsService),
    );
  }
}
