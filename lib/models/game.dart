import 'player.dart';

class Game {
  final int id;
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;
  final DateTime date;
  final List<Player> players; // 🔹 Agregar esta propiedad

  Game({
    required this.id,
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
    required this.date,
    required this.players, // 🔹 Agregar aquí
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      teamAName: json['team_a_name'],
      teamBName: json['team_b_name'],
      teamAScore: json['team_a_score'],
      teamBScore: json['team_b_score'],
      date: DateTime.parse(json['date']),
      players:
          (json['players'] as List<dynamic>) // 🔹 Convertir jugadores
              .map((player) => Player.fromJson(player))
              .toList(),
    );
  }
}
