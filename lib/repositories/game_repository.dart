import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class GameRepository {
  final String baseUrl = 'http://futsal.api/api';

  Future<List<Game>> getGamesWithPlayers(String token, int page) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games-with-players?page=$page'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> gameList = data['data'];

      return gameList.map((game) => Game.fromJson(game)).toList();
    } else {
      throw Exception('Error obteniendo los partidos: ${response.body}');
    }
  }
}
