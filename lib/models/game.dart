class Game {
  final String id;
  final String name;
  final String platform;
  final String coverImage;
  final String genre;
  final int playTime;
  final String? lastPlayed;
  final String steamAppId;

  Game({
    required this.id,
    required this.name,
    required this.platform,
    required this.coverImage,
    required this.genre,
    required this.playTime,
    this.lastPlayed,
    required this.steamAppId,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        platform: json['platform'] ?? '',
        coverImage: json['coverImage'] ?? '',
        genre: json['genre'] ?? '',
        playTime: json['playTime'] ?? 0,
        lastPlayed: json['lastPlayed'],
        steamAppId: json['steamAppId'] ?? '',
      );

  String get playTimeFormatted {
    if (playTime <= 0) return 'Nunca jogado';
    final hours = playTime ~/ 3600;
    final minutes = (playTime % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String get platformBadge {
    switch (platform.toLowerCase()) {
      case 'steam':
        return 'Steam';
      case 'xbox':
        return 'Xbox';
      default:
        return 'Outro';
    }
  }
}
