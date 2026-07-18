class Achievement {
  final String apiname;
  final String name;
  final String description;
  final bool achieved;
  final String icon;
  final String iconGray;
  final int progress;
  final int maxProgress;
  final bool hasProgress;
  final double progressPercentage;

  Achievement({
    required this.apiname,
    required this.name,
    required this.description,
    required this.achieved,
    required this.icon,
    required this.iconGray,
    required this.progress,
    required this.maxProgress,
    required this.hasProgress,
    required this.progressPercentage,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        apiname: json['apiname'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        achieved: json['achieved'] ?? false,
        icon: json['icon'] ?? '',
        iconGray: json['iconGray'] ?? '',
        progress: json['progress'] ?? 0,
        maxProgress: json['maxProgress'] ?? 0,
        hasProgress: json['hasProgress'] ?? false,
        progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      );

  String get displayIcon => achieved ? icon : (iconGray.isNotEmpty ? iconGray : icon);
}
