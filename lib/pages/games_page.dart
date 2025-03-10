// lib/pages/games_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../repositories/game_repository.dart';
import '../repositories/player_repository.dart';
import '../services/token_service.dart';
import 'package:collection/collection.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  Game? nextGame;
  List<Game> pastGames = [];
  bool isLoading = true;
  bool isLoadingMore = false; // 🔹 Indica si se está cargando más partidos
  int currentPage = 1; // 🔹 Página actual de la paginación
  bool hasMoreGames = true; // 🔹 Controla si hay más partidos para cargar
  Map<int, List<Player>> gamePlayers = {}; // Mapeo de jugadores por partido

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    final token = await TokenService.getToken();
    if (token != null && hasMoreGames) {
      try {
        setState(() {
          isLoadingMore = true;
        });

        final newGames = await GameRepository().getGamesWithPlayers(
          token,
          currentPage,
        );

        setState(() {
          isLoading = false;
          isLoadingMore = false;

          if (newGames.isEmpty) {
            hasMoreGames = false;
          } else {
            for (var game in newGames) {
              gamePlayers[game.id] =
                  game.players; // ✅ Asignar jugadores a cada partido
            }

            pastGames.addAll(newGames);
            currentPage++;
          }
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
        print('❌ Error obteniendo los partidos: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Partidos")),
      body: Column(
        children: [
          _buildNextGame(),
          const SizedBox(height: 20),
          Expanded(
            // 🔹 Permite que la lista se expanda correctamente sin overflow
            child: _buildPastGames(),
          ),
        ],
      ),
    );
  }

  Widget _buildNextGame() {
    if (nextGame == null || nextGame!.id == 0) {
      return const Center(child: Text("No hay próximos partidos."));
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "📅 Próximo Partido",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat(
                'EEEE, d MMMM yyyy • HH:mm',
                'es_ES',
              ).format(nextGame!.date),
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildPlayerIcons(nextGame!.id),
          ],
        ),
      ),
    );
  }

  Widget _buildPastGames() {
    if (pastGames.isEmpty) {
      return const Center(child: Text("No hay partidos anteriores."));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoadingMore &&
            hasMoreGames &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.9) {
          _fetchGames();
        }
        return false;
      },
      child: ListView.builder(
        itemCount:
            pastGames.length + (isLoadingMore ? 1 : 0), // 🔹 +1 para el loader
        itemBuilder: (context, index) {
          if (index == pastGames.length) {
            return isLoadingMore
                ? const Center(
                  child: CircularProgressIndicator(),
                ) // 🔄 Loader de carga adicional
                : const SizedBox.shrink();
          }
          final game = pastGames[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: _buildPlayerIcons(game.id),
              // trailing: _gameResult(game),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerIcons(int gameId) {
    final players = gamePlayers[gameId] ?? [];

    // 🔹 Separar jugadores por equipo basándose en `pivot.team`
    final teamAPlayers = players.where((p) => p.team == "A").toList();
    final teamBPlayers = players.where((p) => p.team == "B").toList();

    print("🛠 Renderizando jugadores para el partido $gameId");
    print("✅ Equipo A: ${teamAPlayers.length} jugadores");
    print("✅ Equipo B: ${teamBPlayers.length} jugadores");

    return Column(
      children: [
        // 📅 FECHA DEL PARTIDO (CENTRADO)
        Text(
          DateFormat(
            'd MMM yyyy • HH:mm',
            'es_ES',
          ).format(pastGames.firstWhere((g) => g.id == gameId).date),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),

        // 🎭 JUGADORES VS JUGADORES (Avatares más pequeños)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.center,
              children:
                  teamAPlayers
                      .map((player) => _buildPlayerAvatar(player))
                      .toList(),
            ),
            const SizedBox(width: 8),
            const Text(
              "VS",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.center,
              children:
                  teamBPlayers
                      .map((player) => _buildPlayerAvatar(player))
                      .toList(),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 🏆 RESULTADO (Centrado, con solo los números en color)
        _styledGameResult(pastGames.firstWhere((g) => g.id == gameId)),
      ],
    );
  }

  // 🔹 Función para generar avatares más pequeños
  Widget _buildPlayerAvatar(Player player) {
    String imageUrl =
        (player.imageUrl.isNotEmpty &&
                Uri.tryParse(player.imageUrl)?.hasAbsolutePath == true)
            ? player.imageUrl
            : 'assets/images/avatar0.png';

    return CircleAvatar(
      radius: 12, // 🔹 Reducido a 12px para que quepan mejor
      backgroundColor: Colors.grey[300],
      backgroundImage:
          imageUrl.startsWith('http')
              ? NetworkImage(imageUrl) // 🔹 Si es URL, cargar de Internet
              : AssetImage(imageUrl)
                  as ImageProvider, // 🔹 Si no, cargar de assets
      onBackgroundImageError: (_, __) {
        print(
          '❌ Error cargando la imagen de ${player.name}, usando avatar0.png',
        );
      },
    );
  }

  // 🎯 Función para mostrar solo los números del resultado en verde/rojo/amarillo
  Widget _styledGameResult(Game game) {
    bool isDraw = game.teamAScore == game.teamBScore;
    bool teamAWins = game.teamAScore > game.teamBScore;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${game.teamAScore}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                isDraw
                    ? Colors.amber
                    : (teamAWins ? Colors.green : Colors.red), // 🟢🔴🟡
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          "-",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          "${game.teamBScore}",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color:
                isDraw
                    ? Colors.amber
                    : (teamAWins ? Colors.red : Colors.green), // 🟢🔴🟡
          ),
        ),
      ],
    );
  }
}
