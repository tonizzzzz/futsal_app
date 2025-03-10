// lib/repositories/player_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';

class PlayerRepository {
  final String baseUrl = 'http://futsal.api/api';

  Future<List<Player>> getPlayers(String token) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/players?include=games',
      ), // 🔹 Incluir partidos en la respuesta
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los jugadores: ${response.body}');
    }
  }

  Future<void> createPlayer(String token, Player player) async {
    final response = await http.post(
      Uri.parse('$baseUrl/players'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(player.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Error al crear el jugador: ${response.body}');
    }
  }

  Future<void> updatePlayer(String token, Player player) async {
    final response = await http.put(
      Uri.parse('$baseUrl/players/${player.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(player.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el jugador: ${response.body}');
    }
  }

  Future<int> getGamesPlayed(String token, int playerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/players/$playerId/games'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['games_played'] ??
          0; // ✅ Accediendo correctamente a la clave correcta
    } else {
      throw Exception(
        'Error al obtener los partidos jugados: ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> getPlayerStats(
    String token,
    int playerId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/players/$playerId/stats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Error al obtener estadísticas del jugador: ${response.body}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getPlayerRatings(
    String token,
    int playerId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/players/$playerId/ratings'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Error al obtener la evolución del rating');
    }
  }

  Future<List<Player>> getPlayersForGame(
    String token,
    int gameId,
    String team,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/$gameId/players?team=$team'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Player.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al obtener los jugadores del partido: ${response.body}',
      );
    }
  }
}
