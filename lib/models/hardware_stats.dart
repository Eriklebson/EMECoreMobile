class HardwareStats {
  final CpuStats cpu;
  final GpuStats gpu;
  final RamStats ram;
  final FpsStats fps;
  final DiskStats disk;
  final NetworkStats network;
  final MotherboardStats motherboard;
  final List<FanInfo> fans;
  final int timestamp;

  HardwareStats({
    required this.cpu,
    required this.gpu,
    required this.ram,
    required this.fps,
    required this.disk,
    required this.network,
    required this.motherboard,
    required this.fans,
    required this.timestamp,
  });

  factory HardwareStats.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return HardwareStats(
      cpu: CpuStats.fromJson(data['cpu'] ?? {}),
      gpu: GpuStats.fromJson(data['gpu'] ?? {}),
      ram: RamStats.fromJson(data['ram'] ?? {}),
      fps: FpsStats.fromJson(data['fps'] ?? {}),
      disk: DiskStats.fromJson(data['disk'] ?? {}),
      network: NetworkStats.fromJson(data['network'] ?? {}),
      motherboard: MotherboardStats.fromJson(data['motherboard'] ?? {}),
      fans: (data['fans'] as List?)?.map((f) => FanInfo.fromJson(f)).toList() ?? [],
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class CpuStats {
  final double usage;
  final double temp;
  final double voltage;
  final double power;
  final String model;
  final int cores;
  final int threads;
  final double clockMhz;

  CpuStats({
    required this.usage,
    required this.temp,
    required this.voltage,
    required this.power,
    required this.model,
    required this.cores,
    required this.threads,
    required this.clockMhz,
  });

  factory CpuStats.fromJson(Map<String, dynamic> json) => CpuStats(
        usage: (json['usage'] ?? 0).toDouble(),
        temp: (json['temp'] ?? 0).toDouble(),
        voltage: (json['voltage'] ?? 0).toDouble(),
        power: (json['power'] ?? 0).toDouble(),
        model: json['model'] ?? 'N/A',
        cores: json['cores'] ?? 0,
        threads: json['threads'] ?? 0,
        clockMhz: (json['clockMhz'] ?? 0).toDouble(),
      );
}

class GpuStats {
  final double usage;
  final double temp;
  final double hotspotTemp;
  final double voltage;
  final double power;
  final String model;
  final double coreClockMhz;
  final double memoryClockMhz;
  final double memoryTotalMb;
  final double memoryUsedMb;
  final String driverVersion;

  GpuStats({
    required this.usage,
    required this.temp,
    required this.hotspotTemp,
    required this.voltage,
    required this.power,
    required this.model,
    required this.coreClockMhz,
    required this.memoryClockMhz,
    required this.memoryTotalMb,
    required this.memoryUsedMb,
    required this.driverVersion,
  });

  factory GpuStats.fromJson(Map<String, dynamic> json) => GpuStats(
        usage: (json['usage'] ?? 0).toDouble(),
        temp: (json['temp'] ?? 0).toDouble(),
        hotspotTemp: (json['hotspotTemp'] ?? 0).toDouble(),
        voltage: (json['voltage'] ?? 0).toDouble(),
        power: (json['power'] ?? 0).toDouble(),
        model: json['model'] ?? 'N/A',
        coreClockMhz: (json['coreClockMhz'] ?? 0).toDouble(),
        memoryClockMhz: (json['memoryClockMhz'] ?? 0).toDouble(),
        memoryTotalMb: (json['memoryTotalMb'] ?? 0).toDouble(),
        memoryUsedMb: (json['memoryUsedMb'] ?? 0).toDouble(),
        driverVersion: json['driverVersion'] ?? '',
      );
}

class RamStats {
  final double usedGb;
  final double totalGb;
  final double freeGb;
  final double percent;
  final double speed;
  final String model;
  final String type;

  RamStats({
    required this.usedGb,
    required this.totalGb,
    required this.freeGb,
    required this.percent,
    required this.speed,
    required this.model,
    required this.type,
  });

  factory RamStats.fromJson(Map<String, dynamic> json) => RamStats(
        usedGb: (json['usedGb'] ?? 0).toDouble(),
        totalGb: (json['totalGb'] ?? 0).toDouble(),
        freeGb: (json['freeGb'] ?? 0).toDouble(),
        percent: (json['percent'] ?? 0).toDouble(),
        speed: (json['speed'] ?? 0).toDouble(),
        model: json['model'] ?? '',
        type: json['type'] ?? '',
      );
}

class FpsStats {
  final int current;
  final int min;
  final int max;
  final double avg;
  final double low1;
  final double low01;
  final double frameTimeMs;
  final String source;

  FpsStats({
    required this.current,
    required this.min,
    required this.max,
    required this.avg,
    required this.low1,
    required this.low01,
    required this.frameTimeMs,
    required this.source,
  });

  factory FpsStats.fromJson(Map<String, dynamic> json) => FpsStats(
        current: json['current'] ?? 0,
        min: json['min'] ?? 0,
        max: json['max'] ?? 0,
        avg: (json['avg'] ?? 0).toDouble(),
        low1: (json['low1'] ?? 0).toDouble(),
        low01: (json['low01'] ?? 0).toDouble(),
        frameTimeMs: (json['frameTimeMs'] ?? 0).toDouble(),
        source: json['source'] ?? 'Off',
      );
}

class DiskStats {
  final double readKbps;
  final double writeKbps;
  final double usagePercent;

  DiskStats({
    required this.readKbps,
    required this.writeKbps,
    required this.usagePercent,
  });

  factory DiskStats.fromJson(Map<String, dynamic> json) => DiskStats(
        readKbps: (json['readKbps'] ?? 0).toDouble(),
        writeKbps: (json['writeKbps'] ?? 0).toDouble(),
        usagePercent: (json['usagePercent'] ?? 0).toDouble(),
      );
}

class NetworkStats {
  final double downloadSpeed;
  final double uploadSpeed;
  final String name;

  NetworkStats({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.name,
  });

  factory NetworkStats.fromJson(Map<String, dynamic> json) => NetworkStats(
        downloadSpeed: (json['downloadSpeed'] ?? 0).toDouble(),
        uploadSpeed: (json['uploadSpeed'] ?? 0).toDouble(),
        name: json['name'] ?? '',
      );
}

class MotherboardStats {
  final String model;
  final double temp;
  final String biosVersion;

  MotherboardStats({
    required this.model,
    required this.temp,
    required this.biosVersion,
  });

  factory MotherboardStats.fromJson(Map<String, dynamic> json) =>
      MotherboardStats(
        model: json['model'] ?? 'N/A',
        temp: (json['temp'] ?? 0).toDouble(),
        biosVersion: json['biosVersion'] ?? '',
      );
}

class FanInfo {
  final String name;
  final double rpm;
  final double dutyPercent;

  FanInfo({
    required this.name,
    required this.rpm,
    required this.dutyPercent,
  });

  factory FanInfo.fromJson(Map<String, dynamic> json) => FanInfo(
        name: json['name'] ?? '',
        rpm: (json['rpm'] ?? 0).toDouble(),
        dutyPercent: (json['dutyPercent'] ?? 0).toDouble(),
      );
}
