// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:futsal/pages/games_page.dart';
import '../services/token_service.dart';
import 'login_page.dart';
import 'players_page.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = await TokenService.getUsername();
    final role = await TokenService.getRole();
    final token = await TokenService.getToken();
    setState(() {
      username = user;
      isLoading = false;
    });

    print('Usuario actual: $username ($role) - $token');
  }

  Future<void> _logout() async {
    await TokenService.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username != null ? 'Bienvenido, $username' : 'Futsal App'),
        actions: [
          if (username != null)
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
            ),
        ],
      ),
      drawer: _buildDrawer(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Text(
                  username != null
                      ? 'Estás logueado como $username'
                      : 'No se pudo cargar el usuario.',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username ?? 'Usuario'),
            accountEmail: Text(username ?? ''),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          if (username != null) // Solo mostrar si está logueado
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Fichas de Jugadores'),
              onTap: () async {
                final token = await TokenService.getToken();
                if (token != null && token.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayersPage(token: token),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Token de autenticación no encontrado.'),
                    ),
                  );
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.sports_soccer),
            title: const Text('Partidos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GamesPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendario de Partidos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarPage()),
              );
            },
          ),
          const Divider(),
          if (username != null) // Solo mostrar si está logueado
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión'),
              onTap: _logout,
            ),
        ],
      ),
    );
  }
}
