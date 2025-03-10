// lib/pages/player_detail_page.dart
import 'package:flutter/material.dart';
import '../models/player.dart';
import 'player_edit_page.dart';

class PlayerDetailPage extends StatelessWidget {
  final Player player;

  const PlayerDetailPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: player.imageUrl.isNotEmpty
                  ? NetworkImage(player.imageUrl)
                  : null,
              child:
                  player.imageUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
            ),
            const SizedBox(height: 16),
            Text(
              player.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              player.position,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final updatedPlayer = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerEditPage(player: player),
                  ),
                );
                if (updatedPlayer != null) {
                  // Aquí podrías actualizar la UI con el jugador actualizado
                  print('Jugador actualizado: ${updatedPlayer.name}');
                }
              },
              child: const Text('Editar Ficha'),
            ),
          ],
        ),
      ),
    );
  }
}
