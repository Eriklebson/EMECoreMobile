import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/achievement.dart';
import '../services/websocket_service.dart';
import '../theme/app_colors.dart';

class GameDetailPage extends StatefulWidget {
  final Game game;
  final WebSocketService wsService;

  const GameDetailPage({super.key, required this.game, required this.wsService});

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  List<Achievement> _achievements = [];
  bool _loadingAchievements = false;
  late StreamSubscription _achSub;

  @override
  void initState() {
    super.initState();
    _achSub = widget.wsService.achievements.listen((a) {
      if (mounted) setState(() { _achievements = a; _loadingAchievements = false; });
    });
    _loadAchievements();
  }

  @override
  void dispose() {
    _achSub.cancel();
    super.dispose();
  }

  void _loadAchievements() {
    setState(() => _loadingAchievements = true);
    widget.wsService.requestAchievements(widget.game.id);
  }

  @override
  Widget build(BuildContext context) {
    final achieved = _achievements.where((a) => a.achieved).length;
    final total = _achievements.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.card,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.game.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.fg),
              ),
              background: widget.game.coverImage.isNotEmpty
                  ? Image.network(
                      widget.game.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.sec,
                        child: const Icon(Icons.gamepad, size: 60, color: AppColors.muted),
                      ),
                    )
                  : Container(
                      color: AppColors.sec,
                      child: const Icon(Icons.gamepad, size: 60, color: AppColors.muted),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _platformColor(widget.game.platform),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.game.platformBadge,
                          style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (widget.game.genre.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.sec,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.game.genre,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow('Tempo de jogo', widget.game.playTimeFormatted),
                  if (widget.game.lastPlayed != null)
                    _infoRow('Ultimo acesso', widget.game.lastPlayed!),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.wsService.launchGame(widget.game.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lancando ${widget.game.name}...'),
                            backgroundColor: AppColors.pri,
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Jogar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pri,
                        foregroundColor: AppColors.fg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: AppColors.warn, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Conquistas',
                        style: TextStyle(
                          color: AppColors.warn,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (total > 0) ...[
                        const Spacer(),
                        Text(
                          '$achieved / $total',
                          style: const TextStyle(color: AppColors.muted, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loadingAchievements)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: AppColors.warn),
                      ),
                    )
                  else if (_achievements.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Nenhuma conquista encontrada',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    )
                  else
                    ..._achievements.map((a) => _buildAchievementTile(a)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile(Achievement ach) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: ach.achieved ? Border.all(color: AppColors.priRing) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: ach.displayIcon.isNotEmpty
                ? Image.network(
                    ach.displayIcon,
                    errorBuilder: (_, __, ___) => Icon(
                      ach.achieved ? Icons.emoji_events : Icons.emoji_events_outlined,
                      color: ach.achieved ? AppColors.warn : AppColors.muted,
                    ),
                  )
                : Icon(
                    ach.achieved ? Icons.emoji_events : Icons.emoji_events_outlined,
                    color: ach.achieved ? AppColors.warn : AppColors.muted,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ach.name.isNotEmpty ? ach.name : ach.apiname,
                  style: TextStyle(
                    color: ach.achieved ? AppColors.fg : AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ach.description.isNotEmpty)
                  Text(
                    ach.description,
                    style: TextStyle(
                      color: ach.achieved ? AppColors.muted70 : AppColors.muted,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (ach.hasProgress && ach.maxProgress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: ach.progressPercentage / 100,
                              backgroundColor: AppColors.sec,
                              valueColor: const AlwaysStoppedAnimation(AppColors.warn),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${ach.progress}/${ach.maxProgress}',
                          style: const TextStyle(color: AppColors.muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (ach.achieved)
            const Icon(Icons.check_circle, color: AppColors.warn, size: 20)
          else
            const Icon(Icons.lock_outline, color: AppColors.muted70, size: 20),
        ],
      ),
    );
  }

  Color _platformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'steam':
        return AppColors.steamBg;
      case 'xbox':
        return AppColors.xboxBg;
      default:
        return AppColors.pri10;
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.fg, fontSize: 13)),
        ],
      ),
    );
  }
}
