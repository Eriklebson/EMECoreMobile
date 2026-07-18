import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/hardware_stats.dart';
import '../models/game.dart';
import '../models/achievement.dart';

enum ConnectionStatus { disconnected, connecting, connected }

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<ConnectionStatus> _statusController =
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<HardwareStats> _hardwareController =
      StreamController<HardwareStats>.broadcast();
  final StreamController<List<Game>> _gamesController =
      StreamController<List<Game>>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<List<Achievement>> _achievementController =
      StreamController<List<Achievement>>.broadcast();

  Timer? _pingTimer;
  Timer? _reconnectTimer;
  Timer? _connectTimeout;
  String _host = '127.0.0.1';
  int _port = 8181;
  bool _shouldReconnect = false;
  bool _hasConnectedOnce = false;
  bool _welcomeReceived = false;
  int _reconnectAttempts = 0;
  int _connectGeneration = 0;
  static const int maxReconnectAttempts = 3;

  Stream<ConnectionStatus> get status => _statusController.stream;
  Stream<HardwareStats> get hardwareStats => _hardwareController.stream;
  Stream<List<Game>> get games => _gamesController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<List<Achievement>> get achievements => _achievementController.stream;
  ConnectionStatus _currentStatus = ConnectionStatus.disconnected;
  ConnectionStatus get currentStatus => _currentStatus;

  void connect(String host, int port) {
    _shouldReconnect = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    if (_channel != null) {
      try { _channel!.sink.close(); } catch (_) {}
      _channel = null;
    }
    _host = host;
    _port = port;
    _hasConnectedOnce = false;
    _reconnectAttempts = 0;
    _connectGeneration++;
    _doConnect(_connectGeneration);
  }

  void _doConnect([int? generation]) {
    final gen = generation ?? _connectGeneration;
    _welcomeReceived = false;
    _updateStatus(ConnectionStatus.connecting);

    _connectTimeout?.cancel();
    _connectTimeout = Timer(const Duration(seconds: 8), () {
      if (gen != _connectGeneration) return;
      if (!_welcomeReceived) {
        _errorController.add('Tempo esgotado. Verifique IP/porta e se o PC esta ligado.');
        _updateStatus(ConnectionStatus.disconnected);
        try { _channel?.sink.close(); } catch (_) {}
        _channel = null;
      }
    });

    try {
      final uri = Uri.parse('ws://$_host:$_port');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          if (gen != _connectGeneration) return;
          _handleMessage(data);
        },
        onDone: () {
          if (gen != _connectGeneration) return;
          _connectTimeout?.cancel();
          _updateStatus(ConnectionStatus.disconnected);
          _pingTimer?.cancel();
          if (_shouldReconnect && _hasConnectedOnce &&
              _reconnectAttempts < maxReconnectAttempts) {
            _reconnectAttempts++;
            _reconnectTimer?.cancel();
            _reconnectTimer =
                Timer(Duration(seconds: 3 * _reconnectAttempts), () {
              if (_shouldReconnect) _doConnect(gen);
            });
          }
        },
        onError: (error) {
          if (gen != _connectGeneration) return;
          _connectTimeout?.cancel();
          _errorController.add('Erro de conexao: $error');
          _updateStatus(ConnectionStatus.disconnected);
        },
      );
    } catch (e) {
      _connectTimeout?.cancel();
      _errorController.add('Falha ao conectar: $e');
      _updateStatus(ConnectionStatus.disconnected);
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data.toString());
      final type = json['type'];

      switch (type) {
        case 'welcome':
          _welcomeReceived = true;
          _hasConnectedOnce = true;
          _reconnectAttempts = 0;
          _connectTimeout?.cancel();
          _updateStatus(ConnectionStatus.connected);
          _startPing();
          break;
        case 'hardware_stats':
          _hardwareController.add(HardwareStats.fromJson(json));
          break;
        case 'game_list':
          final list = (json['data'] as List?)
                  ?.map((g) => Game.fromJson(g))
                  .toList() ??
              [];
          _gamesController.add(list);
          break;
        case 'achievements':
          final list = (json['data'] as List?)
                  ?.map((a) => Achievement.fromJson(a))
                  .toList() ??
              [];
          _achievementController.add(list);
          break;
        case 'achievement_data':
          final list = (json['data'] as List?)
                  ?.map((a) => Achievement.fromJson(a))
                  .toList() ??
              [];
          _achievementController.add(list);
          break;
        case 'pong':
          break;
        case 'game_launched':
          break;
        case 'error':
          _errorController.add(json['message'] ?? 'Erro desconhecido');
          break;
      }
    } catch (e) {
      _errorController.add('Erro ao processar mensagem: $e');
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _send({'type': 'ping'});
    });
  }

  void _send(Map<String, dynamic> message) {
    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (_) {}
  }

  void requestHardwareStats() {
    _send({'type': 'get_hardware'});
  }

  void requestGames() {
    _send({'type': 'get_games'});
  }

  void launchGame(String gameId) {
    _send({'type': 'launch_game', 'gameId': gameId});
  }

  void requestAchievements(String gameId) {
    _send({'type': 'get_achievements', 'gameId': gameId});
  }

  void disconnect() {
    _shouldReconnect = false;
    _hasConnectedOnce = false;
    _welcomeReceived = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _connectTimeout?.cancel();
    _channel?.sink.close();
    _channel = null;
    _updateStatus(ConnectionStatus.disconnected);
  }

  void _updateStatus(ConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void dispose() {
    disconnect();
    _statusController.close();
    _hardwareController.close();
    _gamesController.close();
    _errorController.close();
    _achievementController.close();
  }
}
