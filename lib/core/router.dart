import 'package:flutter/material.dart';
import 'package:futsal/pages/home_page.dart';
import 'package:futsal/pages/games_page.dart';
import 'package:futsal/pages/players_page.dart';
import 'package:futsal/pages/login_page.dart';
import '../services/token_service.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/games':
        return MaterialPageRoute(
          builder:
              (_) => FutureBuilder<String?>(
                future:
                    TokenService.getToken(), // 🔹 Obtener el token antes de abrir la página
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ), // 🔹 Muestra loading mientras carga
                    );
                  }
                  final token = snapshot.data ?? '';
                  return GamesPage(token: token);
                },
              ),
        );
      case '/players':
        return MaterialPageRoute(
          builder:
              (_) => FutureBuilder<String?>(
                future: TokenService.getToken(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final token = snapshot.data ?? '';
                  return PlayersPage(token: token);
                },
              ),
        );
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text('No route defined'))),
    );
  }
}
