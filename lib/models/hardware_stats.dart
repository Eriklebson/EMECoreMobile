class HardwareStats {
  final CpuStats cpu;
  final GpuStats gpu;
  final RamStats ram;
  final FpsStats fps;
  final DiskStats disk;
  final NetworkStats network;
  final MotherboardStats motherboard;
  final List<FanInfo> fans;
  final List<GamepadInfo> gamepads;
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
    required this.gamepads,
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
      gamepads: (data['gamepads'] as List?)?.map((g) => GamepadInfo.fromJson(g)).toList() ?? [],
      timestamp: json['timestamp'] ?? 0,
    );
  }
}

class CpuStats {
  final double usage;
  final double coreTemp;
  final double packageTemp;
  final double voltage;
  final double power;
  final String model;
  final int cores;
  final int threads;
  final double clockMhz;

  CpuStats({
    required this.usage,
    required this.coreTemp,
    required this.packageTemp,
    required this.voltage,
    required this.power,
    required this.model,
    required this.cores,
    required this.threads,
    required this.clockMhz,
  });

  factory CpuStats.fromJson(Map<String, dynamic> json) => CpuStats(
        usage: (json['usage'] ?? 0).toDouble(),
        coreTemp: (json['coreTemp'] ?? json['temp'] ?? 0).toDouble(),
        packageTemp: (json['packageTemp'] ?? json['temp'] ?? 0).toDouble(),
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

class GamepadInfo {
  final String name;
  final bool isConnected;
  final String batteryType;
  final String batteryLevel;

  GamepadInfo({
    required this.name,
    required this.isConnected,
    required this.batteryType,
    required this.batteryLevel,
  });

  factory GamepadInfo.fromJson(Map<String, dynamic> json) => GamepadInfo(
        name: json['name'] ?? 'Gamepad',
        isConnected: json['isConnected'] ?? false,
        batteryType: json['batteryType'] ?? 'Disconnected',
        batteryLevel: json['batteryLevel'] ?? 'Empty',
      );
}

class GamepadState {
  final int buttons;
  final int leftTrigger;
  final int rightTrigger;
  final int thumbLX;
  final int thumbLY;
  final int thumbRX;
  final int thumbRY;
  final int packetNumber;

  GamepadState({
    required this.buttons,
    required this.leftTrigger,
    required this.rightTrigger,
    required this.thumbLX,
    required this.thumbLY,
    required this.thumbRX,
    required this.thumbRY,
    required this.packetNumber,
  });

  bool isPressed(int button) => (buttons & button) != 0;

  factory GamepadState.empty() => GamepadState(
        buttons: 0,
        leftTrigger: 0,
        rightTrigger: 0,
        thumbLX: 0,
        thumbLY: 0,
        thumbRX: 0,
        thumbRY: 0,
        packetNumber: 0,
      );

  factory GamepadState.fromJson(Map<String, dynamic> json) => GamepadState(
        buttons: json['buttons'] ?? 0,
        leftTrigger: json['leftTrigger'] ?? 0,
        rightTrigger: json['rightTrigger'] ?? 0,
        thumbLX: json['thumbLX'] ?? 0,
        thumbLY: json['thumbLY'] ?? 0,
        thumbRX: json['thumbRX'] ?? 0,
        thumbRY: json['thumbRY'] ?? 0,
        packetNumber: json['packetNumber'] ?? 0,
      );

  static const int dpadUp = 0x0001;
  static const int dpadDown = 0x0002;
  static const int dpadLeft = 0x0004;
  static const int dpadRight = 0x0008;
  static const int start = 0x0010;
  static const int back = 0x0020;
  static const int leftThumb = 0x0040;
  static const int rightThumb = 0x0080;
  static const int leftShoulder = 0x0100;
  static const int rightShoulder = 0x0200;
  static const int a = 0x1000;
  static const int b = 0x2000;
  static const int x = 0x4000;
  static const int y = 0x8000;
}
