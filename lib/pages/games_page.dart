import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/achievement.dart';
import '../services/websocket_service.dart';
import 'game_detail_page.dart';

class GamesPage extends StatefulWidget {
  final WebSocketService wsService;
  const GamesPage({super.key, required this.wsService});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  List<Game> _games = [];
  String _filter = 'Todos';
  String _search = '';
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.wsService.games.listen((g) {
      if (mounted) setState(() => _games = g);
    });
    widget.wsService.requestGames();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _games.where((g) {
      if (_filter != 'Todos' && g.platform.toLowerCase() != _filter.toLowerCase()) return false;
      if (_search.isNotEmpty && !g.name.toLowerCase().contains(_search.toLowerCase())) return false;
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Buscar jogos...',
              hintStyle: const TextStyle(color: Color(0xFF8F98A0)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF8F98A0), size: 18),
              filled: true,
              fillColor: const Color(0xFF1B2838),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: ['Todos', 'Steam', 'Xbox', 'Outro']
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f, style: const TextStyle(fontSize: 12)),
                        selected: _filter == f,
                        selectedColor: const Color(0xFF66C0F4),
                        backgroundColor: const Color(0xFF1B2838),
                        labelStyle: TextStyle(
                          color: _filter == f ? Colors.white : const Color(0xFF8F98A0),
                        ),
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('Nenhum jogo encontrado', style: TextStyle(color: Color(0xFF8F98A0))),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _buildGameCard(filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildGameCard(Game game) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameDetailPage(game: game, wsService: widget.wsService),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B2838),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: game.coverImage.isNotEmpty
                  ? Image.network(
                      game.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2A475E),
                        child: const Icon(Icons.gamepad, color: Color(0xFF8F98A0), size: 40),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF2A475E),
                      child: const Icon(Icons.gamepad, color: Color(0xFF8F98A0), size: 40),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _platformColor(game.platform),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            game.platformBadge,
                            style: const TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          game.playTimeFormatted,
                          style: const TextStyle(color: Color(0xFF8F98A0), fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
}
