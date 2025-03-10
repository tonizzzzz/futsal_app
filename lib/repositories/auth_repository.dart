// lib/repositories/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_service.dart';

class AuthRepository {
  final String baseUrl = 'http://futsal.api/api';

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final String? token = data['token'] as String?;
      final String? role = data['role'] as String?;

      // Asegurarse de que el username nunca sea nulo, usando el email como predeterminado
      final String username = (data['name'] as String?) ?? email;

      if (token != null && role != null) {
        await TokenService.saveToken(token);
        await TokenService.saveRole(role);
        await TokenService.saveUsername(
          username,
        ); // Se asegura que username sea un String no nulo
        print('Usuario logueado: $username');
        return token;
      } else {
        throw Exception('Error de autenticación: Token o rol no válidos.');
      }
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }
}
