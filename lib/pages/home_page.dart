import 'dart:async';

import 'package:flutter/material.dart';

import '../services/websocket_service.dart';
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
        backgroundColor: const Color(0xFF161719),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B2838),
          title: const Text(
            'E.M.E Core',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF66C0F4)),
              onPressed: () {
                if (_currentIndex == 0) {
                  widget.wsService.requestHardwareStats();
                } else {
                  widget.wsService.requestGames();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: Color(0xFFD94040)),
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
          backgroundColor: const Color(0xFF1B2838),
          selectedItemColor: const Color(0xFF66C0F4),
          unselectedItemColor: const Color(0xFF8F98A0),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.memory), label: 'Hardware'),
            BottomNavigationBarItem(icon: Icon(Icons.games), label: 'Jogos'),
          ],
        ),
      ),
    );
  }
}
