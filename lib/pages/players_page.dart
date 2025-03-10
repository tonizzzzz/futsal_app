// lib/pages/players_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsal/pages/player_profile_page.dart';
import '../blocs/player/player_bloc.dart';
import '../blocs/player/player_event.dart';
import '../blocs/player/player_state.dart';
import '../repositories/player_repository.dart';
import '../services/token_service.dart';
import 'player_create_page.dart';

class PlayersPage extends StatefulWidget {
  final String token;

  const PlayersPage({super.key, required this.token});

  @override
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  String? userRole;
  late PlayerBloc _playerBloc;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _playerBloc = PlayerBloc(repository: PlayerRepository());
    _playerBloc.add(FetchPlayers(token: widget.token));
  }

  Future<void> _loadUserRole() async {
    final role = await TokenService.getRole();
    setState(() {
      userRole = role;
    });
    print('Rol del usuario: $userRole');
  }

  Future<void> _navigateToCreatePlayerPage() async {
    final bool? playerCreated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerCreatePage(),
      ),
    );

    if (playerCreated == true) {
      _playerBloc.add(FetchPlayers(token: widget.token));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jugador creado con éxito')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _playerBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Fichas de Jugadores"),
          actions: [
            if (userRole == 'admin' || userRole == 'moderator')
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Añadir nuevo jugador',
                onPressed: _navigateToCreatePlayerPage,
              ),
          ],
        ),
        body: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            if (state is PlayerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PlayerLoaded) {
              return ListView.builder(
                itemCount: state.players.length,
                itemBuilder: (context, index) {
                  final player = state.players[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: ClipOval(
                        child: player.imageUrl.isNotEmpty
                            ? Image.network(
                                player.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported);
                                },
                              )
                            : const Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text(player.name),
                    subtitle: Text(player.position),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerProfilePage(player: player),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (state is PlayerError) {
              return Center(child: Text(state.error));
            }
            return Container();
          },
        ),
      ),
    );
  }
}
