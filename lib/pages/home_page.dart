import 'dart:async';

import 'package:flutter/material.dart';

import '../services/websocket_service.dart';
import '../theme/app_colors.dart';
import 'hardware_page.dart';
import 'games_page.dart';
import 'connection_page.dart';

class HomePage extends StatefulWidget {
  final WebSocketService wsService;
  const HomePage({super.key, required this.wsService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late StreamSubscription _statusSub;

  @override
  void initState() {
    super.initState();
    _statusSub = widget.wsService.status.listen((s) {
      if (s == ConnectionStatus.disconnected && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ConnectionPage(wsService: widget.wsService)),
        );
      }
    });
  }

  @override
  void dispose() {
    _statusSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) widget.wsService.disconnect();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.card,
          title: const Text(
            'E.M.E Core',
            style: TextStyle(color: AppColors.fg, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.pri),
              onPressed: () {
                if (_currentIndex == 0) {
                  widget.wsService.requestHardwareStats();
                } else {
                  widget.wsService.requestGames();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: AppColors.danger),
              onPressed: () {
                widget.wsService.disconnect();
              },
            ),
          ],
        ),
        body: _currentIndex == 0
            ? HardwarePage(wsService: widget.wsService)
            : GamesPage(wsService: widget.wsService),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.pri,
          unselectedItemColor: AppColors.muted,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.memory), label: 'Hardware'),
            BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Jogos'),
          ],
        ),
      ),
    );
  }
}
