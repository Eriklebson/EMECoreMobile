import 'dart:async';

import 'package:flutter/material.dart';

import '../services/websocket_service.dart';
import '../services/discovery_service.dart';
import '../theme/app_colors.dart';
import 'home_page.dart';

class ConnectionPage extends StatefulWidget {
  final WebSocketService wsService;
  const ConnectionPage({super.key, required this.wsService});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final _discoveryService = DiscoveryService();
  ConnectionStatus _status = ConnectionStatus.disconnected;
  bool _showError = false;
  String _errorMsg = '';
  bool _showManual = false;
  final _ipController = TextEditingController(text: '');
  final _portController = TextEditingController(text: '8181');
  late StreamSubscription _statusSub;
  late StreamSubscription _errorSub;
  late StreamSubscription _serversSub;

  @override
  void initState() {
    super.initState();
    _statusSub = widget.wsService.status.listen((s) {
      if (!mounted) return;
      setState(() {
        _status = s;
      });
      if (s == ConnectionStatus.connected) {
        setState(() {
          _showError = false;
          _errorMsg = '';
        });
        _discoveryService.stop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(wsService: widget.wsService),
          ),
        );
      }
    });
    _errorSub = widget.wsService.errors.listen((e) {
      if (!mounted) return;
      setState(() {
        _showError = true;
        _errorMsg = e;
      });
    });
    _serversSub = _discoveryService.servers.listen((_) {
      if (mounted) setState(() {});
    });
    _discoveryService.start();
  }

  @override
  void dispose() {
    _statusSub.cancel();
    _errorSub.cancel();
    _serversSub.cancel();
    _discoveryService.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servers = _discoveryService.currentServers;
    final isConnecting = _status == ConnectionStatus.connecting;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.gamepad,
                  size: 40,
                  color: AppColors.pri,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'E.M.E Core',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.fg,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Controle Remoto',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 40),

              if (_showError && _errorMsg.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMsg,
                          style: const TextStyle(color: AppColors.danger, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              if (servers.isNotEmpty && !isConnecting)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.wifi, color: AppColors.pri, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'PCs encontrados na rede',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.fg,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...servers.map((server) => _buildServerCard(server)),
                    ],
                  ),
                ),

              if (servers.isEmpty && !isConnecting)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Procurando PCs na rede...',
                        style: TextStyle(fontSize: 14, color: AppColors.muted),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Certifique-se de que o app desktop esta aberto',
                        style: TextStyle(fontSize: 11, color: AppColors.muted70),
                      ),
                    ],
                  ),
                ),

              if (isConnecting)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.pri,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Conectando...',
                        style: TextStyle(fontSize: 14, color: AppColors.fg),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              if (!isConnecting)
                TextButton(
                  onPressed: () => setState(() => _showManual = !_showManual),
                  child: Text(
                    _showManual ? 'Ocultar conexao manual' : 'Conexao manual (IP/Porta)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.pri,
                    ),
                  ),
                ),

              if (_showManual && !isConnecting)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _ipController,
                        style: const TextStyle(color: AppColors.fg),
                        decoration: InputDecoration(
                          labelText: 'IP do PC',
                          labelStyle: const TextStyle(color: AppColors.muted),
                          hintText: '192.168.0.102',
                          hintStyle: const TextStyle(color: AppColors.muted70),
                          prefixIcon: const Icon(Icons.computer, color: AppColors.pri),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.sec),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.sec),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.pri),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _portController,
                        style: const TextStyle(color: AppColors.fg),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Porta',
                          labelStyle: const TextStyle(color: AppColors.muted),
                          hintText: '8181',
                          hintStyle: const TextStyle(color: AppColors.muted70),
                          prefixIcon: const Icon(Icons.settings_ethernet, color: AppColors.pri),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.sec),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.sec),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.pri),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _connectManual,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sec,
                            foregroundColor: AppColors.fg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Conectar manualmente',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerCard(DiscoveredServer server) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.sec,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _connectToServer(server),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.pri10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.computer,
                    color: AppColors.pri,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${server.ip}:${server.port}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.pri,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _connectToServer(DiscoveredServer server) {
    setState(() {
      _showError = false;
      _errorMsg = '';
    });
    widget.wsService.connect(server.ip, server.port);
  }

  void _connectManual() {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      setState(() {
        _showError = true;
        _errorMsg = 'Digite o IP do PC';
      });
      return;
    }
    final port = int.tryParse(_portController.text.trim()) ?? 8181;
    setState(() {
      _showError = false;
      _errorMsg = '';
    });
    widget.wsService.connect(ip, port);
  }
}
