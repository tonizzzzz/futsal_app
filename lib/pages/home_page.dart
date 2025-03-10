import 'package:flutter/material.dart';
import 'package:futsal/pages/games_page.dart';
import 'package:futsal/pages/players_page.dart';
import 'package:futsal/pages/calendar_page.dart';
import '../services/token_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = await TokenService.getUsername();
    setState(() {
      username = user;
      isLoading = false;
    });
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
      key: _scaffoldKey, // 🔹 Agregamos la key del Scaffold
      appBar: AppBar(
        title: Text(username != null ? 'Bienvenido, $username' : 'Futsal App'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed:
              () =>
                  _scaffoldKey.currentState
                      ?.openDrawer(), // 🔹 Abre el Drawer correctamente
        ),
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
          ExpansionTile(
            leading: const Icon(Icons.sports_soccer),
            title: const Text('Partidos'),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Ver Partidos'),
                onTap: () async {
                  final token = await TokenService.getToken();
                  if (token != null && token.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GamesPage(token: token),
                      ),
                    );
                  } else {
                    _showSnackBar('Token de autenticación no encontrado.');
                  }
                },
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.group),
            title: const Text('Jugadores'),
            children: [
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Lista de Jugadores'),
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
                    _showSnackBar('Token de autenticación no encontrado.');
                  }
                },
              ),
            ],
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
          if (username != null)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión'),
              onTap: _logout,
            ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
