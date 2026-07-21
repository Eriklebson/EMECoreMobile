import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hardware_stats.dart';

class GamepadWidget extends StatefulWidget {
  final GamepadState state;
  final bool showCalibrationButton;

  const GamepadWidget({
    super.key,
    required this.state,
    this.showCalibrationButton = true,
  });

  @override
  State<GamepadWidget> createState() => _GamepadWidgetState();
}

class _GamepadWidgetState extends State<GamepadWidget> {
  static const String _prefsKey = 'gamepad_button_positions';
  Map<String, List<double>> _positions = {};
  bool _loaded = false;

  static const Map<String, List<double>> _defaultPositions = {
    'A': [0.568, 0.450],
    'B': [0.633, 0.355],
    'X': [0.503, 0.355],
    'Y': [0.568, 0.260],
    'LB': [0.085, 0.060],
    'RB': [0.500, 0.060],
    'Back': [0.380, 0.330],
    'Start': [0.470, 0.330],
    'DUp': [0.220, 0.260],
    'DDown': [0.220, 0.450],
    'DLeft': [0.155, 0.355],
    'DRight': [0.285, 0.355],
    'LS': [0.220, 0.580],
    'RS': [0.390, 0.580],
  };

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json != null) {
      try {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        _positions = decoded.map((k, v) => MapEntry(k, List<double>.from(v)));
      } catch (_) {
        _positions = Map.from(_defaultPositions);
      }
    } else {
      _positions = Map.from(_defaultPositions);
    }
    if (mounted) setState(() => _loaded = true);
  }

  Map<String, List<double>> get _pos =>
      _loaded ? _positions : _defaultPositions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 360 / 256,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Image.asset(
                      'assets/gamepad/controller.png',
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                    ..._buildButtonOverlays(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                    ..._buildStickDots(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildTriggers(),
          if (widget.showCalibrationButton) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openCalibration(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, color: Color(0xFF6B7280), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Calibrar posicoes',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildButtonOverlays(double w, double h) {
    final entries = [
      ('A', GamepadState.a),
      ('B', GamepadState.b),
      ('X', GamepadState.x),
      ('Y', GamepadState.y),
      ('LB', GamepadState.leftShoulder),
      ('RB', GamepadState.rightShoulder),
      ('Back', GamepadState.back),
      ('Start', GamepadState.start),
      ('DUp', GamepadState.dpadUp),
      ('DDown', GamepadState.dpadDown),
      ('DLeft', GamepadState.dpadLeft),
      ('DRight', GamepadState.dpadRight),
      ('LS', GamepadState.leftThumb),
      ('RS', GamepadState.rightThumb),
    ];

    return entries.map((entry) {
      final (name, button) = entry;
      final pos = _pos[name]!;
      final pressed = widget.state.isPressed(button);
      final isDpad = name.startsWith('D');
      final isShoulder = name == 'LB' || name == 'RB';
      final isStick = name == 'LS' || name == 'RS';

      double radius;
      if (isShoulder) {
        radius = w * 0.04;
      } else if (isDpad) {
        radius = w * 0.035;
      } else if (isStick) {
        radius = w * 0.055;
      } else {
        radius = w * 0.035;
      }

      return Positioned(
        left: pos[0] * w - radius,
        top: pos[1] * h - radius,
        width: radius * 2,
        height: radius * 2,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pressed
                ? const Color(0xFF4ADE80).withAlpha(200)
                : Colors.white.withAlpha(15),
            boxShadow: pressed
                ? [
                    BoxShadow(
                      color: const Color(0xFF4ADE80).withAlpha(100),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildStickDots(double w, double h) {
    final lsPos = _pos['LS']!;
    final rsPos = _pos['RS']!;

    final lsNormX = (widget.state.thumbLX / 32767.0).clamp(-1.0, 1.0);
    final lsNormY = (widget.state.thumbLY / 32767.0).clamp(-1.0, 1.0);
    final rsNormX = (widget.state.thumbRX / 32767.0).clamp(-1.0, 1.0);
    final rsNormY = (widget.state.thumbRY / 32767.0).clamp(-1.0, 1.0);

    final stickRadius = w * 0.02;
    final maxOffset = w * 0.04;

    return [
      Positioned(
        left: lsPos[0] * w + lsNormX * maxOffset - stickRadius,
        top: lsPos[1] * h - lsNormY * maxOffset - stickRadius,
        width: stickRadius * 2,
        height: stickRadius * 2,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4ADE80),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ADE80).withAlpha(120),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
      Positioned(
        left: rsPos[0] * w + rsNormX * maxOffset - stickRadius,
        top: rsPos[1] * h - rsNormY * maxOffset - stickRadius,
        width: stickRadius * 2,
        height: stickRadius * 2,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4ADE80),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ADE80).withAlpha(120),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildTriggers() {
    return Row(
      children: [
        Expanded(child: _buildTriggerBar('LT', widget.state.leftTrigger)),
        const SizedBox(width: 12),
        Expanded(child: _buildTriggerBar('RT', widget.state.rightTrigger)),
      ],
    );
  }

  Widget _buildTriggerBar(String label, int value) {
    final pct = value / 255.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    color: pct > 0
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF6B7280),
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D31),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: pct,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCalibration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GamepadCalibrationPage(
          initialPositions: _positions,
          onSaved: (newPos) {
            setState(() => _positions = newPos);
          },
        ),
      ),
    );
  }
}

class GamepadCalibrationPage extends StatefulWidget {
  final Map<String, List<double>> initialPositions;
  final ValueChanged<Map<String, List<double>>> onSaved;

  const GamepadCalibrationPage({
    super.key,
    required this.initialPositions,
    required this.onSaved,
  });

  @override
  State<GamepadCalibrationPage> createState() => _GamepadCalibrationPageState();
}

class _GamepadCalibrationPageState extends State<GamepadCalibrationPage> {
  late Map<String, List<double>> _positions;
  String? _draggingKey;
  String? _selectedKey;
  double _imageW = 1;
  double _imageH = 1;
  double _imageLeft = 0;
  double _imageTop = 0;

  static const Map<String, String> _labels = {
    'A': 'A',
    'B': 'B',
    'X': 'X',
    'Y': 'Y',
    'LB': 'LB',
    'RB': 'RB',
    'Back': 'Back',
    'Start': 'Start',
    'DUp': 'D-Up',
    'DDown': 'D-Down',
    'DLeft': 'D-Left',
    'DRight': 'D-Right',
    'LS': 'L3',
    'RS': 'R3',
  };

  static const Map<String, Color> _buttonColors = {
    'A': Color(0xFF4ADE80),
    'B': Color(0xFFEF4444),
    'X': Color(0xFF3B82F6),
    'Y': Color(0xFFFBBF24),
    'LB': Color(0xFFA8ABB0),
    'RB': Color(0xFFA8ABB0),
    'Back': Color(0xFFA8ABB0),
    'Start': Color(0xFFA8ABB0),
    'DUp': Color(0xFFA8ABB0),
    'DDown': Color(0xFFA8ABB0),
    'DLeft': Color(0xFFA8ABB0),
    'DRight': Color(0xFFA8ABB0),
    'LS': Color(0xFF4ADE80),
    'RS': Color(0xFF4ADE80),
  };

  @override
  void initState() {
    super.initState();
    _positions = widget.initialPositions.map((k, v) => MapEntry(k, List<double>.from(v)));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggingKey == null) return;
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;

    final normX = ((dx - _imageLeft) / _imageW).clamp(0.0, 1.0);
    final normY = ((dy - _imageTop) / _imageH).clamp(0.0, 1.0);

    setState(() {
      _positions[_draggingKey!] = [normX, normY];
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _draggingKey = null;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gamepad_button_positions', jsonEncode(_positions));
    widget.onSaved(_positions);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posicoes salvas'),
          backgroundColor: Color(0xFF4ADE80),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _reset() {
    setState(() {
      _positions = {
        'A': [0.568, 0.450],
        'B': [0.633, 0.355],
        'X': [0.503, 0.355],
        'Y': [0.568, 0.260],
        'LB': [0.085, 0.060],
        'RB': [0.500, 0.060],
        'Back': [0.380, 0.330],
        'Start': [0.470, 0.330],
        'DUp': [0.220, 0.260],
        'DDown': [0.220, 0.450],
        'DLeft': [0.155, 0.355],
        'DRight': [0.285, 0.355],
        'LS': [0.220, 0.580],
        'RS': [0.390, 0.580],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161719),
        title: const Text(
          'Calibrar Controle',
          style: TextStyle(color: Color(0xFFE8E9EB), fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFA8ABB0)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Resetar',
              style: TextStyle(color: Color(0xFFE84D4D), fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: _save,
            child: const Text(
              'Salvar',
              style: TextStyle(color: Color(0xFF4ADE80), fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTapUp: (details) {
                final dx = details.localPosition.dx;
                final dy = details.localPosition.dy;
                double closest = double.infinity;
                String? closestKey;
                for (final entry in _positions.entries) {
                  final px = entry.value[0] * _imageW + _imageLeft;
                  final py = entry.value[1] * _imageH + _imageTop;
                  final dist = (dx - px) * (dx - px) + (dy - py) * (dy - py);
                  if (dist < closest && dist < 2500) {
                    closest = dist;
                    closestKey = entry.key;
                  }
                }
                setState(() => _selectedKey = closestKey);
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: 360 / 256,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final imgW = constraints.maxWidth;
                      final imgH = constraints.maxHeight;

                      final double displayW;
                      final double displayH;
                      final double left;
                      final double top;

                      const srcAspect = 360.0 / 256.0;
                      if (imgW / imgH > srcAspect) {
                        displayH = imgH;
                        displayW = imgH * srcAspect;
                      } else {
                        displayW = imgW;
                        displayH = imgW / srcAspect;
                      }
                      left = (imgW - displayW) / 2;
                      top = (imgH - displayH) / 2;

                      _imageW = displayW;
                      _imageH = displayH;
                      _imageLeft = left;
                      _imageTop = top;

                      return Stack(
                        children: [
                          Positioned(
                            left: left,
                            top: top,
                            width: displayW,
                            height: displayH,
                            child: Image.asset(
                              'assets/gamepad/controller.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          ..._buildCalibrationButtons(displayW, displayH, left, top),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          _buildSelectedInfo(),
          _buildLegend(),
        ],
      ),
    );
  }

  List<Widget> _buildCalibrationButtons(
      double w, double h, double left, double top) {
    return _positions.entries.map((entry) {
      final key = entry.key;
      final norm = entry.value;
      final px = norm[0] * w + left;
      final py = norm[1] * h;
      final color = _buttonColors[key] ?? const Color(0xFF4ADE80);
      final isSelected = _selectedKey == key;
      final label = _labels[key] ?? key;

      return Positioned(
        left: px - 18,
        top: py - 18,
        width: 36,
        height: 36,
        child: GestureDetector(
          onPanStart: (details) {
            _draggingKey = key;
            setState(() => _selectedKey = key);
          },
          onPanUpdate: (details) {
            if (_draggingKey == key) {
              final dx = details.delta.dx;
              final dy = details.delta.dy;
              final normX = (_positions[key]![0] + dx / w).clamp(0.0, 1.0);
              final normY = (_positions[key]![1] + dy / h).clamp(0.0, 1.0);
              setState(() {
                _positions[key] = [normX, normY];
              });
            }
          },
          onPanEnd: (_) {
            _draggingKey = null;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? color.withAlpha(220)
                  : color.withAlpha(120),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(isSelected ? 150 : 60),
                  blurRadius: isSelected ? 12 : 6,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSelectedInfo() {
    if (_selectedKey == null) return const SizedBox.shrink();
    final pos = _positions[_selectedKey!]!;
    final label = _labels[_selectedKey!] ?? _selectedKey!;
    final color = _buttonColors[_selectedKey!] ?? const Color(0xFF4ADE80);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D23),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(180),
            ),
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'X: ${(pos[0] * 100).toStringAsFixed(1)}%   Y: ${(pos[1] * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
                color: Color(0xFFA8ABB0), fontSize: 12),
          ),
          const Spacer(),
          const Text(
            'Arraste para mover',
            style: TextStyle(
                color: Color(0xFF6B7280), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final groups = [
      ('Face', ['A', 'B', 'X', 'Y']),
      ('D-Pad', ['DUp', 'DDown', 'DLeft', 'DRight']),
      ('Bumpers', ['LB', 'RB']),
      ('Sticks', ['LS', 'RS']),
      ('Menu', ['Back', 'Start']),
    ];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF161719),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: groups.map((group) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${group.$1}: ',
                  style: const TextStyle(
                      color: Color(0xFF6B7280), fontSize: 10)),
              ...group.$2.map((key) {
                final color = _buttonColors[key] ?? const Color(0xFF4ADE80);
                final isSelected = _selectedKey == key;
                return GestureDetector(
                  onTap: () => setState(() => _selectedKey = key),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withAlpha(100)
                          : color.withAlpha(30),
                      borderRadius: BorderRadius.circular(3),
                      border: isSelected
                          ? Border.all(color: color)
                          : null,
                    ),
                    child: Text(
                      _labels[key] ?? key,
                      style: TextStyle(
                        color: isSelected ? color : color.withAlpha(150),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }
}
