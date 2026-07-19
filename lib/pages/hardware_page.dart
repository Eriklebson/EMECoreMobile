import 'dart:async';

import 'package:flutter/material.dart';

import '../models/hardware_stats.dart';
import '../services/websocket_service.dart';
import '../theme/app_colors.dart';

class HardwarePage extends StatefulWidget {
  final WebSocketService wsService;
  const HardwarePage({super.key, required this.wsService});

  @override
  State<HardwarePage> createState() => _HardwarePageState();
}

class _HardwarePageState extends State<HardwarePage> {
  HardwareStats? _stats;
  late StreamSubscription _sub;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _sub = widget.wsService.hardwareStats.listen((s) {
      if (mounted) setState(() => _stats = s);
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
          _buildCpuCard(s.cpu),
          const SizedBox(height: 8),
          _buildGpuCard(s.gpu),
          const SizedBox(height: 8),
          _buildRamCard(s.ram),
          const SizedBox(height: 8),
          _buildFpsCard(s.fps),
          const SizedBox(height: 8),
          _buildDiskCard(s.disk),
          const SizedBox(height: 8),
          _buildNetworkCard(s.network),
          const SizedBox(height: 8),
          _buildMotherboardCard(s.motherboard),
        ],
      ),
    );
  }

  Widget _buildCpuCard(CpuStats cpu) {
    return _card(
      title: 'CPU',
      icon: Icons.memory,
      color: AppColors.cpu,
      child: Column(
        children: [
          Text(cpu.model, style: const TextStyle(color: AppColors.fg, fontSize: 13)),
          const SizedBox(height: 8),
          _meter('Uso', cpu.usage, '%', AppColors.cpu),
          _meter('Temp', cpu.temp, '°C', _tempColor(cpu.temp)),
          _detailRow('Voltagem', '${cpu.voltage.toStringAsFixed(3)} V'),
          _detailRow('Potencia', '${cpu.power.toStringAsFixed(1)} W'),
        ],
      ),
    );
  }

  Widget _buildGpuCard(GpuStats gpu) {
    return _card(
      title: 'GPU',
      icon: Icons.videocam,
      color: AppColors.gpu,
      child: Column(
        children: [
          Text(gpu.model, style: const TextStyle(color: AppColors.fg, fontSize: 13)),
          const SizedBox(height: 8),
          _meter('Uso', gpu.usage, '%', AppColors.gpu),
          _meter('Temp', gpu.temp, '°C', _tempColor(gpu.temp)),
          if (gpu.hotspotTemp > 0)
            _detailRow('Hotspot', '${gpu.hotspotTemp.toStringAsFixed(0)}°C'),
          _detailRow('Voltagem', '${gpu.voltage.toStringAsFixed(3)} V'),
          _detailRow('Potencia', '${gpu.power.toStringAsFixed(1)} W'),
          if (gpu.coreClockMhz > 0)
            _detailRow('Core', '${gpu.coreClockMhz.toStringAsFixed(0)} MHz'),
          if (gpu.memoryClockMhz > 0)
            _detailRow('Memoria', '${gpu.memoryClockMhz.toStringAsFixed(0)} MHz'),
        ],
      ),
    );
  }

  Widget _buildRamCard(RamStats ram) {
    return _card(
      title: 'RAM',
      icon: Icons.sd_card,
      color: AppColors.ram,
      child: Column(
        children: [
          if (ram.totalGb > 0) _meter('Uso', ram.percent, '%', AppColors.ram),
          if (ram.totalGb > 0)
            _detailRow('Usado', '${ram.usedGb.toStringAsFixed(1)} / ${ram.totalGb.toStringAsFixed(1)} GB'),
          if (ram.model.isNotEmpty)
            Text(ram.model, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          if (ram.totalGb == 0)
            const Text('Dados indisponiveis', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFpsCard(FpsStats fps) {
    return _card(
      title: 'FPS',
      icon: Icons.speed,
      color: AppColors.fps,
      child: Column(
        children: [
          if (fps.source != 'Off')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${fps.current}',
                  style: const TextStyle(
                    color: AppColors.fg,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' FPS',
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ],
            ),
          if (fps.source != 'Off') ...[
            const SizedBox(height: 8),
            _detailRow('Min / Max', '${fps.min} / ${fps.max}'),
            _detailRow('Media', fps.avg.toStringAsFixed(1)),
            _detailRow('1% Low', fps.low1.toStringAsFixed(1)),
            _detailRow('0.1% Low', fps.low01.toStringAsFixed(1)),
            _detailRow('Frame Time', '${fps.frameTimeMs.toStringAsFixed(1)} ms'),
          ],
          if (fps.source == 'Off')
            const Text(
              'Overlay desligado',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildDiskCard(DiskStats disk) {
    return _card(
      title: 'Disco',
      icon: Icons.storage,
      color: AppColors.disk,
      child: Column(
        children: [
          _detailRow('Leitura', '${_formatSpeed(disk.readKbps)}'),
          _detailRow('Escrita', '${_formatSpeed(disk.writeKbps)}'),
          if (disk.usagePercent > 0)
            _meter('Uso', disk.usagePercent, '%', AppColors.disk),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(NetworkStats net) {
    return _card(
      title: 'Rede',
      icon: Icons.wifi,
      color: AppColors.net,
      child: Column(
        children: [
          _detailRow('Download', '${_formatSpeed(net.downloadSpeed)}'),
          _detailRow('Upload', '${_formatSpeed(net.uploadSpeed)}'),
          if (net.name.isNotEmpty)
            Text(net.name, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMotherboardCard(MotherboardStats mb) {
    return _card(
      title: 'Placa Mae',
      icon: Icons.developer_board,
      color: AppColors.mb,
      child: Column(
        children: [
          Text(mb.model, style: const TextStyle(color: AppColors.fg, fontSize: 13)),
          if (mb.temp > 0) _detailRow('Temp', '${mb.temp.toStringAsFixed(0)}°C'),
          if (mb.biosVersion.isNotEmpty)
            _detailRow('BIOS', mb.biosVersion),
        ],
      ),
    );
  }

  String _formatSpeed(double kbps) {
    if (kbps >= 1024) return '${(kbps / 1024).toStringAsFixed(1)} MB/s';
    return '${kbps.toStringAsFixed(0)} KB/s';
  }

  Color _tempColor(double temp) {
    if (temp >= 80) return AppColors.danger;
    if (temp >= 65) return AppColors.warn;
    return AppColors.cpu;
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _meter(String label, double value, String unit, Color color) {
    final pct = value.clamp(0, 100) / 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              Text(
                unit == '%' ? '${value.toStringAsFixed(1)}$unit' : '${value.toStringAsFixed(1)}$unit',
                style: const TextStyle(color: AppColors.fg, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.sec,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          Text(value, style: const TextStyle(color: AppColors.fg, fontSize: 11)),
        ],
      ),
    );
  }
}
