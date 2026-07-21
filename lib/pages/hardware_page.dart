import 'dart:async';

import 'package:flutter/material.dart';

import '../models/hardware_stats.dart';
import '../services/websocket_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gamepad_widget.dart';

class HardwarePage extends StatefulWidget {
  final WebSocketService wsService;
  const HardwarePage({super.key, required this.wsService});

  @override
  State<HardwarePage> createState() => _HardwarePageState();
}

class _HardwarePageState extends State<HardwarePage> {
  HardwareStats? _stats;
  GamepadState _gamepadState = GamepadState.empty();
  late StreamSubscription _sub;
  late StreamSubscription _gamepadSub;
  Timer? _refreshTimer;

  final Map<String, bool> _collapsed = {
    'cpu': false,
    'gpu': false,
    'ram': false,
    'disk': false,
    'net': false,
    'mb': false,
    'gamepad': false,
  };

  final Map<String, bool> _detailsExpanded = {
    'cpu': false,
    'gpu': false,
    'ram': false,
    'disk': false,
    'mb': false,
  };

  final Set<String> _shownOptional = {};

  @override
  void initState() {
    super.initState();
    debugPrint('[HW] HardwarePage initState');
    _sub = widget.wsService.hardwareStats.listen((s) {
      debugPrint('[HW] Received stats: cpu=${s.cpu.usage} gpu=${s.gpu.usage} gamepads=${s.gamepads.length}');
      if (mounted) setState(() => _stats = s);
    });
    _gamepadSub = widget.wsService.gamepadState.listen((gs) {
      if (mounted) setState(() => _gamepadState = gs);
    });
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    widget.wsService.requestHardwareStats();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && widget.wsService.currentStatus == ConnectionStatus.connected) {
        widget.wsService.requestHardwareStats();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _sub.cancel();
    _gamepadSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.pri),
      );
    }
    final s = _stats!;
    return RefreshIndicator(
      onRefresh: () async => widget.wsService.requestHardwareStats(),
      color: AppColors.pri,
      backgroundColor: AppColors.card,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildMotherboardCard(s.motherboard, s.fans),
          const SizedBox(height: 8),
          _buildCpuCard(s.cpu, s.fans),
          const SizedBox(height: 8),
          _buildGpuCard(s.gpu, s.fans),
          const SizedBox(height: 8),
          _buildRamCard(s.ram),
          const SizedBox(height: 8),
          _buildFpsCard(s.fps),
          const SizedBox(height: 8),
          _buildDiskCard(s.disk),
          const SizedBox(height: 8),
          _buildNetworkCard(s.network),
          if (_shownOptional.contains('gamepad')) ...[
            const SizedBox(height: 8),
            _buildGamepadCard(s.gamepads),
          ],
          const SizedBox(height: 8),
          _buildAddModuleButton(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Color _usageColor(double pct, Color base) {
    if (pct >= 85) return const Color(0xFFEF4444);
    if (pct >= 60) return const Color(0xFFF59E0B);
    return base;
  }

  Color _tempColor(double temp) {
    if (temp >= 85) return const Color(0xFFEF4444);
    if (temp >= 70) return const Color(0xFFF59E0B);
    if (temp >= 50) return const Color(0xFF22C55E);
    return const Color(0xFF3B82F6);
  }

  String _fmtSpeed(double kbps) {
    if (kbps >= 1024) return '${(kbps / 1024).toStringAsFixed(1)} MB/s';
    return '${kbps.toStringAsFixed(0)} KB/s';
  }

  String _fmtSize(double gb) {
    return '${gb.toStringAsFixed(1)} GB';
  }

  void _toggle(String key) {
    setState(() {
      _collapsed[key] = !(_collapsed[key] ?? true);
    });
  }

  // ───────────────────── CARD CONTAINER ─────────────────────

  Widget _cardContainer({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.card.withAlpha(25),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  // ───────────────────── HEADER ─────────────────────

  Widget _cardHeader({
    required IconData icon,
    required String title,
    required Color accent,
    String? rightText,
  }) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (rightText != null) ...[
          const Spacer(),
          Text(
            rightText,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ],
    );
  }

  // ───────────────────── TOGGLE BUTTON ─────────────────────

  Widget _toggleButton(String key, Color accent) {
    final isCollapsed = _collapsed[key] ?? true;
    return GestureDetector(
      onTap: () => _toggle(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Icon(
          isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
          color: AppColors.muted,
          size: 20,
        ),
      ),
    );
  }

  // ───────────────────── COMPACT ROW ─────────────────────

  Widget _compactRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  Widget _compactItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ───────────────────── METRIC LABEL ─────────────────────

  Widget _metricLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 9,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ───────────────────── METRIC VALUE ─────────────────────

  Widget _metricValue(String text, Color color, {double fontSize = 32}) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ───────────────────── PROGRESS BAR ─────────────────────

  Widget _progressBar(double pct, Color color) {
    final clamped = pct.clamp(0.0, 100.0);
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.sec,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: clamped / 100,
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── FAN ROW ─────────────────────

  Widget _fanRow(FanInfo fan, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inset,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.card.withAlpha(25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, color: AppColors.muted, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fan.name,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${fan.rpm.toStringAsFixed(0)} RPM',
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────── FANS GRID ─────────────────────

  Widget _fansGrid(List<FanInfo> fans, Color accent) {
    if (fans.isEmpty) return const SizedBox.shrink();
    if (fans.length == 1) return _fanRow(fans.first, accent);
    final rows = <Widget>[];
    for (var i = 0; i < fans.length; i += 2) {
      final rowChildren = <Widget>[
        Expanded(child: _fanRow(fans[i], accent)),
      ];
      if (i + 1 < fans.length) {
        rowChildren.addAll([
          const SizedBox(width: 8),
          Expanded(child: _fanRow(fans[i + 1], accent)),
        ]);
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 6));
      rows.add(Row(children: rowChildren));
    }
    return Column(children: rows);
  }

  // ═══════════════════════ CPU CARD ═══════════════════════

  Widget _buildCpuCard(CpuStats cpu, List<FanInfo> allFans) {
    final isCollapsed = _collapsed['cpu'] ?? true;
    final cpuFans = allFans.where((f) {
      final name = f.name.toLowerCase();
      return name.contains('cpu') || name.contains('pump') || name.contains('aio');
    }).toList();
    final usage = _usageColor(cpu.usage, AppColors.cpu);
    final coreTempColor = _tempColor(cpu.coreTemp);
    final packageTempColor = _tempColor(cpu.packageTemp);

    if (isCollapsed) {
      return _cardContainer(
        child: Column(
          children: [
            Row(
              children: [
                _cardHeader(
                  icon: Icons.memory,
                  title: 'CPU',
                  accent: AppColors.cpu,
                  rightText: cpu.voltage > 0 ? '${cpu.voltage.toStringAsFixed(2)}V' : null,
                ),
                const Spacer(),
                _toggleButton('cpu', AppColors.cpu),
              ],
            ),
            const SizedBox(height: 8),
            _compactRow([
              _compactItem('USO', '${cpu.usage.toStringAsFixed(1)}%', usage),
              _compactItem('CORE', '${cpu.coreTemp.toStringAsFixed(0)}°C', coreTempColor),
              _compactItem('CLOCK', '${cpu.clockMhz.toStringAsFixed(0)} MHz', Colors.white),
            ]),
          ],
        ),
      );
    }

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHeader(
                  icon: Icons.memory,
                  title: 'CPU',
                  accent: AppColors.cpu,
                  rightText: cpu.voltage > 0 ? '${cpu.voltage.toStringAsFixed(2)}V  ${cpu.power.toStringAsFixed(0)}W' : null,
                ),
              ),
              _toggleButton('cpu', AppColors.cpu),
            ],
          ),
          if (cpu.model.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              cpu.model,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricLabel('USO'),
                  _metricValue('${cpu.usage.toStringAsFixed(0)}%', usage),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricLabel('CORE'),
                  _metricValue('${cpu.coreTemp.toStringAsFixed(0)}°', coreTempColor, fontSize: 18),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricLabel('PKG'),
                  _metricValue('${cpu.packageTemp.toStringAsFixed(0)}°', packageTempColor, fontSize: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _progressBar(cpu.usage, usage),
          if (cpuFans.isNotEmpty) ...[
            const SizedBox(height: 8),
            _fansGrid(cpuFans, AppColors.cpu),
          ],
          const SizedBox(height: 8),
          _detailSection('cpu', 'DETALHES', AppColors.cpu, [
            _detailRow('Nucleos / Threads', '${cpu.cores} / ${cpu.threads}'),
            if (cpu.clockMhz > 0) _detailRow('Clock', '${cpu.clockMhz.toStringAsFixed(0)} MHz'),
          ]),
        ],
      ),
    );
  }

  // ═══════════════════════ GPU CARD ═══════════════════════

  Widget _buildGpuCard(GpuStats gpu, List<FanInfo> allFans) {
    final isCollapsed = _collapsed['gpu'] ?? true;
    final gpuFans = allFans.where((f) =>
        f.name.toLowerCase().contains('gpu')).toList();
    final usage = _usageColor(gpu.usage, AppColors.gpu);
    final temp = _tempColor(gpu.temp);
    final vramPct = gpu.memoryTotalMb > 0 ? (gpu.memoryUsedMb / gpu.memoryTotalMb * 100) : 0.0;

    if (isCollapsed) {
      return _cardContainer(
        child: Column(
          children: [
            Row(
              children: [
                _cardHeader(
                  icon: Icons.videocam,
                  title: 'GPU',
                  accent: AppColors.gpu,
                  rightText: gpu.voltage > 0 ? '${gpu.voltage.toStringAsFixed(2)}V' : null,
                ),
                const Spacer(),
                _toggleButton('gpu', AppColors.gpu),
              ],
            ),
            const SizedBox(height: 8),
            _compactRow([
              _compactItem('USO', '${gpu.usage.toStringAsFixed(1)}%', usage),
              _compactItem('TEMP', '${gpu.temp.toStringAsFixed(0)}°C', temp),
              _compactItem('CLOCK', '${gpu.coreClockMhz.toStringAsFixed(0)} MHz', Colors.white),
            ]),
          ],
        ),
      );
    }

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHeader(
                  icon: Icons.videocam,
                  title: 'GPU',
                  accent: AppColors.gpu,
                  rightText: gpu.voltage > 0 ? '${gpu.voltage.toStringAsFixed(2)}V  ${gpu.power.toStringAsFixed(0)}W' : null,
                ),
              ),
              _toggleButton('gpu', AppColors.gpu),
            ],
          ),
          if (gpu.model.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              gpu.model,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricLabel('USO'),
                  _metricValue('${gpu.usage.toStringAsFixed(0)}%', usage),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricLabel('TEMPERATURA'),
                  _metricValue('${gpu.temp.toStringAsFixed(0)}°', temp, fontSize: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _progressBar(gpu.usage, usage),
          if (gpu.memoryTotalMb > 0) ...[
            const SizedBox(height: 8),
            _metricLabel('VRAM'),
            const SizedBox(height: 4),
            _progressBar(vramPct, const Color(0xFFA855F7)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_fmtSize(gpu.memoryUsedMb / 1024)} / ${_fmtSize(gpu.memoryTotalMb / 1024)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                Text(
                  '${vramPct.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ],
          if (gpuFans.isNotEmpty) ...[
            const SizedBox(height: 8),
            _fansGrid(gpuFans, AppColors.gpu),
          ],
          const SizedBox(height: 8),
          _detailSection('gpu', 'DETALHES', AppColors.gpu, [
            if (gpu.hotspotTemp > 0) _detailRow('Hotspot', '${gpu.hotspotTemp.toStringAsFixed(0)}°C'),
            if (gpu.coreClockMhz > 0) _detailRow('Clock Core', '${gpu.coreClockMhz.toStringAsFixed(0)} MHz'),
            if (gpu.memoryClockMhz > 0) _detailRow('Clock Memoria', '${gpu.memoryClockMhz.toStringAsFixed(0)} MHz'),
            if (gpu.driverVersion.isNotEmpty) _detailRow('Driver', gpu.driverVersion),
          ]),
        ],
      ),
    );
  }

  // ═══════════════════════ RAM CARD ═══════════════════════

  Widget _buildRamCard(RamStats ram) {
    final isCollapsed = _collapsed['ram'] ?? true;
    final usage = _usageColor(ram.percent, AppColors.ram);

    if (isCollapsed) {
      return _cardContainer(
        child: Column(
          children: [
            Row(
              children: [
                _cardHeader(
                  icon: Icons.sd_card,
                  title: 'RAM',
                  accent: AppColors.ram,
                ),
                const Spacer(),
                _toggleButton('ram', AppColors.ram),
              ],
            ),
            const SizedBox(height: 8),
            _compactRow([
              _compactItem('USO', '${ram.percent.toStringAsFixed(1)}%', usage),
              _compactItem('RAM', '${ram.usedGb.toStringAsFixed(1)} / ${ram.totalGb.toStringAsFixed(1)} GB', Colors.white),
            ]),
          ],
        ),
      );
    }

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHeader(
                  icon: Icons.sd_card,
                  title: 'RAM',
                  accent: AppColors.ram,
                ),
              ),
              _toggleButton('ram', AppColors.ram),
            ],
          ),
          if (ram.model.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              ram.model,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricLabel('USO'),
                  _metricValue('${ram.percent.toStringAsFixed(0)}%', usage),
                ],
              ),
              const Spacer(),
              Text(
                '${ram.usedGb.toStringAsFixed(1)} / ${ram.totalGb.toStringAsFixed(1)} GB',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _progressBar(ram.percent, usage),
          const SizedBox(height: 8),
          _detailSection('ram', 'DETALHES', AppColors.ram, [
            if (ram.type.isNotEmpty) _detailRow('Tipo', ram.type),
            if (ram.speed > 0) _detailRow('Velocidade', '${ram.speed.toStringAsFixed(0)} MHz'),
            _detailRow('Livre', _fmtSize(ram.freeGb)),
          ]),
        ],
      ),
    );
  }

  // ═══════════════════════ FPS CARD ═══════════════════════

  Widget _buildFpsCard(FpsStats fps) {
    Color fpsColor;
    if (fps.current >= 60) {
      fpsColor = const Color(0xFF22C55E);
    } else if (fps.current >= 30) {
      fpsColor = const Color(0xFFFBBF24);
    } else {
      fpsColor = const Color(0xFFEF4444);
    }

    if (fps.source == 'Off') {
      return _cardContainer(
        child: Column(
          children: [
            _cardHeader(
              icon: Icons.speed,
              title: 'FPS',
              accent: AppColors.fps,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Overlay desligado',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            icon: Icons.speed,
            title: 'FPS',
            accent: AppColors.fps,
            rightText: fps.source,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricValue('${fps.current}', fpsColor, fontSize: 48),
                  const SizedBox(height: 2),
                  _metricLabel('FRAMES PER SECOND'),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'MIN ${fps.min}  ·  AVG ${fps.avg.toStringAsFixed(0)}  ·  MAX ${fps.max}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _fpsStatColumn('1% LOW', fps.low1.toStringAsFixed(1)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _fpsStatColumn('0.1% LOW', fps.low01.toStringAsFixed(1)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _fpsStatColumn('FRAME TIME', '${fps.frameTimeMs.toStringAsFixed(1)} ms'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fpsStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569),
            fontSize: 9,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════ DISK CARD ═══════════════════════

  Widget _buildDiskCard(DiskStats disk) {
    final isCollapsed = _collapsed['disk'] ?? true;

    if (isCollapsed) {
      return _cardContainer(
        child: Column(
          children: [
            Row(
              children: [
                _cardHeader(
                  icon: Icons.storage,
                  title: 'DISCO',
                  accent: AppColors.disk,
                ),
                const Spacer(),
                _toggleButton('disk', AppColors.disk),
              ],
            ),
            const SizedBox(height: 8),
            _compactRow([
              _compactItem('↓', _fmtSpeed(disk.readKbps), AppColors.disk),
              _compactItem('↑', _fmtSpeed(disk.writeKbps), Colors.white),
              if (disk.usagePercent > 0)
                _compactItem('USO', '${disk.usagePercent.toStringAsFixed(0)}%', AppColors.disk),
            ]),
          ],
        ),
      );
    }

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHeader(
                  icon: Icons.storage,
                  title: 'DISCO',
                  accent: AppColors.disk,
                ),
              ),
              _toggleButton('disk', AppColors.disk),
            ],
          ),
          if (disk.usagePercent > 0) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _metricValue('${disk.usagePercent.toStringAsFixed(0)}%', AppColors.disk, fontSize: 24),
              ],
            ),
            const SizedBox(height: 8),
            _progressBar(disk.usagePercent, AppColors.disk),
          ],
          const SizedBox(height: 8),
          _detailSection('disk', 'DETALHES', AppColors.disk, [
            _detailRow('Leitura', _fmtSpeed(disk.readKbps)),
            _detailRow('Escrita', _fmtSpeed(disk.writeKbps)),
          ]),
        ],
      ),
    );
  }

  // ═══════════════════════ NETWORK CARD ═══════════════════════

  Widget _buildNetworkCard(NetworkStats net) {
    final isCollapsed = _collapsed['net'] ?? true;

    if (isCollapsed) {
      return _cardContainer(
        child: Column(
          children: [
            Row(
              children: [
                _cardHeader(
                  icon: Icons.wifi,
                  title: 'REDE',
                  accent: AppColors.net,
                ),
                const Spacer(),
                _toggleButton('net', AppColors.net),
              ],
            ),
            const SizedBox(height: 8),
            _compactRow([
              _compactItem('↓', _fmtSpeed(net.downloadSpeed), AppColors.net),
              _compactItem('↑', _fmtSpeed(net.uploadSpeed), Colors.white),
            ]),
          ],
        ),
      );
    }

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHeader(
                  icon: Icons.wifi,
                  title: 'REDE',
                  accent: AppColors.net,
                ),
              ),
              _toggleButton('net', AppColors.net),
            ],
          ),
          if (net.name.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              net.name,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metricLabel('DOWNLOAD'),
                    _metricValue(_fmtSpeed(net.downloadSpeed), AppColors.net, fontSize: 24),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _metricLabel('UPLOAD'),
                    _metricValue(_fmtSpeed(net.uploadSpeed), Colors.white, fontSize: 24),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════ MOTHERBOARD CARD ═══════════════════════

  Widget _buildMotherboardCard(MotherboardStats mb, List<FanInfo> allFans) {
    final isCollapsed = _collapsed['mb'] ?? true;
    final mbFans = allFans.where((f) {
      final name = f.name.toLowerCase();
      return !name.contains('cpu') &&
          !name.contains('gpu') &&
          !name.contains('pump') &&
          !name.contains('aio');
    }).toList();
    final temp = _tempColor(mb.temp);

    if (isCollapsed) {
      return _cardContainer(
        child: Column(
          children: [
            Row(
              children: [
                _cardHeader(
                  icon: Icons.developer_board,
                  title: 'PLACA MAE',
                  accent: AppColors.mb,
                ),
                const Spacer(),
                _toggleButton('mb', AppColors.mb),
              ],
            ),
            const SizedBox(height: 8),
            _compactRow([
              _compactItem('TEMP', '${mb.temp.toStringAsFixed(0)}°C', temp),
              if (mbFans.isNotEmpty)
                _compactItem('FAN', '${mbFans.first.rpm.toStringAsFixed(0)} RPM', Colors.white),
            ]),
          ],
        ),
      );
    }

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHeader(
                  icon: Icons.developer_board,
                  title: 'PLACA MAE',
                  accent: AppColors.mb,
                ),
              ),
              _toggleButton('mb', AppColors.mb),
            ],
          ),
          if (mb.model.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              mb.model,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metricLabel('TEMPERATURA'),
                  _metricValue('${mb.temp.toStringAsFixed(0)}°', temp),
                ],
              ),
            ],
          ),
          if (mbFans.isNotEmpty) ...[
            const SizedBox(height: 8),
            _fansGrid(mbFans, AppColors.mb),
          ],
          const SizedBox(height: 8),
          _detailSection('mb', 'DETALHES', AppColors.mb, [
            if (mb.biosVersion.isNotEmpty) _detailRow('BIOS', mb.biosVersion),
          ]),
        ],
      ),
    );
  }

  // ═══════════════════════ GAMEPAD CARD ═══════════════════════

  Widget _buildGamepadCard(List<GamepadInfo> gamepads) {
    final isCollapsed = _collapsed['gamepad'] ?? true;
    final gp = gamepads.isNotEmpty ? gamepads.first : null;
    final connected = gp?.isConnected ?? false;
    final accent = const Color(0xFF4ADE80);

    if (isCollapsed) {
      return _cardContainer(
        child: Column(
          children: [
            Row(
              children: [
                _cardHeader(
                  icon: Icons.gamepad,
                  title: 'CONTROLE',
                  accent: accent,
                  rightText: connected ? gp?.name : null,
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _shownOptional.remove('gamepad')),
                      child: const Icon(Icons.close, color: AppColors.muted, size: 16),
                    ),
                    const SizedBox(width: 6),
                    _toggleButton('gamepad', accent),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _compactRow([
              _compactItem('STATUS', connected ? 'Conectado' : 'Aguardando...', connected ? accent : AppColors.muted),
              if (connected && gp != null)
                _compactItem('TIPO', gp.batteryType, Colors.white),
              if (connected && gp != null && gp.batteryLevel != 'Empty')
                _compactItem('BATERIA', gp.batteryLevel, Colors.white),
            ]),
          ],
        ),
      );
    }

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _cardHeader(
                  icon: Icons.gamepad,
                  title: 'CONTROLE',
                  accent: accent,
                  rightText: connected ? gp?.name : null,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _shownOptional.remove('gamepad')),
                    child: const Icon(Icons.close, color: AppColors.muted, size: 16),
                  ),
                  const SizedBox(width: 6),
                  _toggleButton('gamepad', accent),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!connected)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.gamepad, color: AppColors.muted, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Nenhum controle conectado',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ],
              ),
            )
          else if (gp != null) ...[
            GamepadWidget(state: _gamepadState),
            const SizedBox(height: 8),
            _detailSection('gamepad', 'INFO', accent, [
              _detailRow('Nome', gp.name),
              _detailRow('Tipo', gp.batteryType),
              _detailRow('Bateria', gp.batteryLevel),
            ]),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════ ADD MODULE BUTTON ═══════════════════════

  static const Map<String, String> _addableCards = {
    'gamepad': 'Controle',
  };

  List<String> get _availableToAdd =>
      _addableCards.keys.where((k) => !_shownOptional.contains(k)).toList();

  Widget _buildAddModuleButton() {
    final available = _availableToAdd;
    if (available.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showAddModuleSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.muted, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: AppColors.muted, size: 16),
            const SizedBox(width: 8),
            Text(
              'Adicionar modulo',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddModuleSheet() {
    final available = _availableToAdd;
    if (available.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.sec,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Adicionar modulo',
              style: TextStyle(color: AppColors.fg, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            for (final key in available)
              ListTile(
                leading: Icon(
                  key == 'gamepad' ? Icons.gamepad : Icons.device_unknown,
                  color: AppColors.pri,
                ),
                title: Text(
                  _addableCards[key] ?? key,
                  style: const TextStyle(color: AppColors.fg),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _shownOptional.add(key));
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ───────────────────── DETAIL SECTION ─────────────────────

  Widget _detailSection(String key, String label, Color accent, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final expanded = _detailsExpanded[key] ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _detailsExpanded[key] = !expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.sec,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '  $label  ',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.muted,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 2,
            children: rows,
          ),
        ],
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.fg, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
