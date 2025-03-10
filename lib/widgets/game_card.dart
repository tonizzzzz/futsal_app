import 'package:flutter/material.dart';
import 'package:futsal/models/player.dart';
import '../../models/game.dart';
import 'player_avatar.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({super.key, required this.game, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDraw = game.teamAScore == game.teamBScore;
    bool isTeamAWinner = game.teamAScore > game.teamBScore;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 📆 Fecha Centrada
              Text(
                "${game.date.day.toString().padLeft(2, '0')}-${game.date.month.toString().padLeft(2, '0')}-${game.date.year}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 🏆 Jugadores (miniaturas)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPlayersAvatars(
                    game.teamAPlayers,
                  ), // 🔹 Ahora sin limitación
                  const SizedBox(width: 8),
                  const Text(
                    "VS",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  _buildPlayersAvatars(
                    game.teamBPlayers,
                  ), // 🔹 Ahora sin limitación
                ],
              ),
              const SizedBox(height: 8),

              // 🏆 Resultado con colores dinámicos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${game.teamAScore}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          isDraw
                              ? Colors.amber
                              : (isTeamAWinner ? Colors.green : Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "-",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${game.teamBScore}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          isDraw
                              ? Colors.amber
                              : (isTeamAWinner ? Colors.red : Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Genera una fila de avatares de jugadores **(Muestra todos)**
  Widget _buildPlayersAvatars(List<Player> players) {
    return Wrap(
      // 🔹 Usa `Wrap` en lugar de `Row` para manejar muchas miniaturas
      spacing: 3,
      runSpacing: 3,
      alignment: WrapAlignment.center,
      children:
          players.map((player) {
            return PlayerAvatar(
              imageUrl: player.imageUrl,
              size: 18,
            ); // 🔹 Miniaturas pequeñas
          }).toList(),
    );
  }
}
