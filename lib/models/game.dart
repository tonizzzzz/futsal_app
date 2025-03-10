import 'player.dart';

class Game {
  final int id;
  final String teamAName;
  final String teamBName;
  final int teamAScore;
  final int teamBScore;
  final DateTime date;
  final List<Player> teamAPlayers;
  final List<Player> teamBPlayers;

  Game({
    required this.id,
    required this.teamAName,
    required this.teamBName,
    required this.teamAScore,
    required this.teamBScore,
    required this.date,
    required this.teamAPlayers,
    required this.teamBPlayers,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Procesando partido con datos: $json');

      return Game(
        id: _safeInt(json, 'id'),
        teamAName: json['team_a_name'] ?? 'Equipo A',
        teamBName: json['team_b_name'] ?? 'Equipo B',
        teamAScore: _safeInt(json, 'team_a_score'),
        teamBScore: _safeInt(json, 'team_b_score'),
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        teamAPlayers: _safePlayerList(json['team_a']),
        teamBPlayers: _safePlayerList(json['team_b']),
      );
    } catch (e, stackTrace) {
      print('❌ Error en Game.fromJson(): $e\n$stackTrace');
      throw Exception('Error al procesar un partido: $e');
    }
  }

  /// 🔹 Función para manejar conversiones seguras de `int`
  static int _safeInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// 🔹 Función para manejar la lista de jugadores
  static List<Player> _safePlayerList(dynamic jsonPlayers) {
    if (jsonPlayers is List) {
      return jsonPlayers.map((player) {
        try {
          return Player.fromJson(player);
        } catch (e) {
          print('❌ Error procesando un jugador: $e\nDatos: $player');
          return Player(
            id: 0,
            name: 'Desconocido',
            position: 'N/A',
            imageUrl: '',
            rating: 0.0,
            gamesPlayed: [],
          );
        }
      }).toList();
    }
    return [];
  }
}
