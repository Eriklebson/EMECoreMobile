import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DiscoveredServer {
  final String ip;
  final int port;
  final String name;
  DateTime lastSeen;

  DiscoveredServer({
    required this.ip,
    required this.port,
    required this.name,
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredServer && ip == other.ip && port == other.port;

  @override
  int get hashCode => ip.hashCode ^ port.hashCode;
}

class DiscoveryService {
  static const int beaconPort = 8182;
  final StreamController<List<DiscoveredServer>> _serversController =
      StreamController<List<DiscoveredServer>>.broadcast();

  RawDatagramSocket? _socket;
  Timer? _cleanupTimer;
  final List<DiscoveredServer> _servers = [];
  bool _listening = false;

  Stream<List<DiscoveredServer>> get servers => _serversController.stream;
  List<DiscoveredServer> get currentServers => List.unmodifiable(_servers);

  Future<void> start() async {
    if (_listening) return;
    _listening = true;

    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        beaconPort,
        reuseAddress: true,
      );

      _socket!.broadcastEnabled = true;
      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram != null) {
            _handleBeacon(datagram);
          }
        }
      });

      _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _cleanupOldServers();
      });

      print('[Discovery] Escutando beacons na porta $beaconPort');
    } catch (e) {
      print('[Discovery] Erro ao iniciar: $e');
    }
  }

  void _handleBeacon(Datagram datagram) {
    try {
      final message = utf8.decode(datagram.data);
      final json = jsonDecode(message);

      if (json['app'] != 'EMECore') return;

      final server = DiscoveredServer(
        ip: json['ip'] ?? '',
        port: json['port'] ?? 8181,
        name: json['name'] ?? 'PC Desconhecido',
      );

      final existing = _servers.indexWhere(
        (s) => s.ip == server.ip && s.port == server.port,
      );

      if (existing >= 0) {
        _servers[existing].lastSeen = DateTime.now();
      } else {
        _servers.add(server);
        print('[Discovery] PC encontrado: ${server.name} (${server.ip}:${server.port})');
      }

      _serversController.add(List.unmodifiable(_servers));
    } catch (_) {}
  }

  void _cleanupOldServers() {
    final now = DateTime.now();
    final before = _servers.length;
    _servers.removeWhere(
      (s) => now.difference(s.lastSeen).inSeconds > 10,
    );
    if (_servers.length != before) {
      _serversController.add(List.unmodifiable(_servers));
    }
  }

  void stop() {
    _listening = false;
    _cleanupTimer?.cancel();
    _socket?.close();
    _socket = null;
    _servers.clear();
  }

  void dispose() {
    stop();
    _serversController.close();
  }
}
