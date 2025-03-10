import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../repositories/game_repository.dart';
import '../../services/token_service.dart';
import '../widgets/game_card.dart';

class GamesPage extends StatefulWidget {
  final String? token;

  const GamesPage({super.key, this.token});

  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  List<Game> games = [];
  bool isLoading = true;
  late String token;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    token = widget.token ?? await TokenService.getToken() ?? '';
    if (token.isEmpty) {
      print('❌ Error: Token no válido o no recibido.');
      setState(() {
        isLoading = false;
      });
      return;
    }
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    try {
      final gameList = await GameRepository().getGames();
      setState(() {
        games = gameList;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error obteniendo los partidos: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Partidos"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // 🔹 Permitir volver atrás
        ),
      ),
      drawer: _buildDrawer(), // 🔹 Añadimos acceso al menú lateral
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : games.isEmpty
              ? const Center(child: Text("No hay partidos disponibles."))
              : ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return GameCard(
                    game: game,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/gameDetail',
                        arguments: game,
                      );
                    },
                  );
                },
              ),
    );
  }

  /// 🔹 Método para construir el menú lateral (Drawer)
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Menú",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Inicio"),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: const Text("Partidos"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Jugadores"),
            onTap: () => Navigator.pushNamed(context, '/players'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar Sesión"),
            onTap: () async {
              await TokenService.clearSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
