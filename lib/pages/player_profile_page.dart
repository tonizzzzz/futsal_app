import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // 📌 Para el gráfico de evolución
import 'package:futsal/pages/player_edit_page.dart';
import 'package:futsal/services/token_service.dart';
import '../models/player.dart';
import '../repositories/player_repository.dart';

class PlayerProfilePage extends StatefulWidget {
  final Player player;

  const PlayerProfilePage({super.key, required this.player});

  @override
  _PlayerProfilePageState createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  String? userRole;
  String? username;
  late Player currentPlayer;
  int gamesPlayed = 0;
  String? lastGame;
  String? createdAt;
  int totalWins = 0;
  int totalLosses = 0;
  int winsInLast10Results = 0;
  int lossesInLast10Results = 0;
  List<Map<String, dynamic>> last10Results = [];
  List<double> ratingEvolution = []; // 📈 Evolución de puntuación
  bool isLoading = true;
  double currentRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchPlayerStats();
    currentPlayer = widget.player;
  }

  Future<void> _loadUserInfo() async {
    final role = await TokenService.getRole();
    final user = await TokenService.getUsername();
    setState(() {
      userRole = role;
      username = user;
    });
  }

  Future<void> _fetchPlayerStats() async {
    final token = await TokenService.getToken();
    if (token != null) {
      try {
        final stats = await PlayerRepository().getPlayerStats(
          token,
          currentPlayer.id,
        );

        setState(() {
          isLoading = false;
          gamesPlayed = stats['games_played'] ?? 0;
          lastGame = stats['last_game'] ?? "No disponible";
          createdAt = stats['created_at'] ?? "No disponible";
          totalWins = stats['total_wins'] ?? 0;
          totalLosses = stats['total_losses'] ?? 0;
          winsInLast10Results = stats['wins_in_last_10_results'] ?? 0;
          lossesInLast10Results = stats['losses_in_last_10_results'] ?? 0;
          last10Results = List<Map<String, dynamic>>.from(
            stats['last_10_results'] ?? [],
          );

          // ✅ Convertimos correctamente `current_rating` a double
          currentRating =
              double.tryParse(stats['current_rating'].toString()) ?? 0.0;

          // ✅ Convertimos cada rating en `rating_evolution` a double
          ratingEvolution =
              (stats['rating_evolution'] as List?)
                  ?.map<double>(
                    (item) => double.tryParse(item['rating'].toString()) ?? 0.0,
                  )
                  .toList() ??
              [];

          print("✅ Puntuación actual: $currentRating");
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('❌ Error obteniendo estadísticas del jugador: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('❌ Error: Token de autenticación no encontrado.');
    }
  }

  void _navigateToEditPage() async {
    final updatedPlayer = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerEditPage(player: currentPlayer),
      ),
    );

    if (updatedPlayer != null) {
      setState(() {
        currentPlayer = updatedPlayer;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ficha del jugador actualizada')),
      );
    }
  }

  bool _canEditProfile() {
    return userRole == 'admin' ||
        userRole == 'moderator' ||
        username == currentPlayer.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPlayer.name),
        actions: [
          if (_canEditProfile())
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.amber),
              onPressed: _navigateToEditPage,
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          currentPlayer.imageUrl.isNotEmpty
                              ? NetworkImage(currentPlayer.imageUrl)
                              : null,
                      child:
                          currentPlayer.imageUrl.isEmpty
                              ? const Icon(Icons.image_not_supported, size: 60)
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentPlayer.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Posición: ${currentPlayer.position}',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // 📌 Tarjeta con estadísticas principales
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatRow("Jugador desde:", createdAt),
                            _buildStatRow("Último partido:", lastGame),
                            _buildStatRow(
                              "Partidos jugados:",
                              gamesPlayed.toString(),
                            ),
                            _buildStatRow(
                              "Victorias totales:",
                              totalWins.toString(),
                            ),
                            _buildStatRow(
                              "Derrotas totales:",
                              totalLosses.toString(),
                            ),
                            _buildStatRow(
                              "Victorias (Últimos 10):",
                              winsInLast10Results.toString(),
                            ),
                            _buildStatRow(
                              "Derrotas (Últimos 10):",
                              lossesInLast10Results.toString(),
                            ),
                            _buildStatRow(
                              "Puntuación actual:",
                              currentRating.toStringAsFixed(2),
                            ),
                            const SizedBox(height: 16),
                            _buildLast10Results(),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Evolución de la puntuación en los últimos 10 partidos:",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildRatingChart(
                                      ratingEvolution
                                          .map((e) => e.toDouble())
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
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

  /// 📌 Widget para mostrar cada estadística en fila
  Widget _buildStatRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            value ?? "No disponible",
            style: const TextStyle(fontSize: 18, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  /// 📌 Widget para mostrar los últimos 10 resultados con V/D
  Widget _buildLast10Results() {
    return Column(
      children: [
        const Text(
          "Últimos 10 partidos:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              last10Results.map((game) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: game['result'] == 'W' ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      game['result'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// 📈 Widget para mostrar el gráfico de evolución de puntuación
  Widget _buildRatingChart(List<double> ratingEvolution) {
    return ratingEvolution.isNotEmpty
        ? SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    ratingEvolution.length,
                    (index) => FlSpot(index.toDouble(), ratingEvolution[index]),
                  ),
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.blue, // ✅ Color correcto
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        )
        : const Center(
          child: Text(
            "No hay datos de evolución de puntuación.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
  }
}
