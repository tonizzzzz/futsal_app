import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';
import '../services/token_service.dart';

class GameRepository {
  final String baseUrl = 'http://futsal.api/api';

  Future<List<Game>> getGames() async {
    final token = await TokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token de autenticación no encontrado.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/games'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print(
      '📡 Respuesta de la API (Código ${response.statusCode}): ${response.body}',
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> gameList = json.decode(response.body);
        if (gameList.isNotEmpty) {
          print('🔍 Ejemplo de partido recibido: ${gameList.first}');
        }

        return gameList.map((game) => Game.fromJson(game)).toList();
      } catch (e) {
        print('❌ Error procesando JSON: $e');
        throw Exception('Error al procesar los datos de la API.');
      }
    } else {
      throw Exception('Error obteniendo los partidos: ${response.body}');
    }
  }
}
