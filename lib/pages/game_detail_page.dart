import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/achievement.dart';
import '../services/websocket_service.dart';

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
      backgroundColor: const Color(0xFF161719),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1B2838),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.game.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              background: widget.game.coverImage.isNotEmpty
                  ? Image.network(
                      widget.game.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2A475E),
                        child: const Icon(Icons.gamepad, size: 60, color: Color(0xFF8F98A0)),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF2A475E),
                      child: const Icon(Icons.gamepad, size: 60, color: Color(0xFF8F98A0)),
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
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (widget.game.genre.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A475E),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.game.genre,
                            style: const TextStyle(color: Color(0xFF8F98A0)),
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
                            backgroundColor: const Color(0xFF107C10),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Jogar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66C0F4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFE8A735), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Conquistas',
                        style: TextStyle(
                          color: const Color(0xFFE8A735),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (total > 0) ...[
                        const Spacer(),
                        Text(
                          '$achieved / $total',
                          style: const TextStyle(color: Color(0xFF8F98A0), fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_loadingAchievements)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Color(0xFFE8A735)),
                      ),
                    )
                  else if (_achievements.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Nenhuma conquista encontrada',
                          style: TextStyle(color: Color(0xFF8F98A0)),
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
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(8),
        border: ach.achieved ? Border.all(color: const Color(0xFFE8A735).withOpacity(0.3)) : null,
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
                      color: ach.achieved ? const Color(0xFFE8A735) : const Color(0xFF8F98A0),
                    ),
                  )
                : Icon(
                    ach.achieved ? Icons.emoji_events : Icons.emoji_events_outlined,
                    color: ach.achieved ? const Color(0xFFE8A735) : const Color(0xFF8F98A0),
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
                    color: ach.achieved ? Colors.white : const Color(0xFF8F98A0),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ach.description.isNotEmpty)
                  Text(
                    ach.description,
                    style: TextStyle(
                      color: ach.achieved ? const Color(0xFF8F98A0) : Colors.grey.shade600,
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
                              backgroundColor: const Color(0xFF2A475E),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFFE8A735)),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${ach.progress}/${ach.maxProgress}',
                          style: const TextStyle(color: Color(0xFF8F98A0), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (ach.achieved)
            const Icon(Icons.check_circle, color: Color(0xFFE8A735), size: 20)
          else
            Icon(Icons.lock_outline, color: Colors.grey.shade600, size: 20),
        ],
      ),
    );
  }

  Color _platformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'steam':
        return const Color(0xFF1B2838);
      case 'xbox':
        return const Color(0xFF107C10);
      default:
        return const Color(0xFF66C0F4);
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8F98A0), fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }
}
