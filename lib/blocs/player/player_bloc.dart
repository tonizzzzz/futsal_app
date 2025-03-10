// lib/blocs/player/player_bloc.dart
import 'package:bloc/bloc.dart';
import 'player_event.dart';
import 'player_state.dart';
import '../../repositories/player_repository.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final PlayerRepository repository;

  PlayerBloc({required this.repository}) : super(PlayerInitial()) {
    on<FetchPlayers>((event, emit) async {
      emit(PlayerLoading());

      try {
        final String token = event.token;

        if (token.isEmpty) {
          emit(PlayerError(
            message: 'Token de autenticación no encontrado.',
            error: 'Token vacío o nulo',
          ));
          return;
        }

        print('Token enviado al PlayerRepository: $token');

        final players = await repository.getPlayers(token);
        emit(PlayerLoaded(players: players));
      } catch (e) {
        print('Error en PlayerBloc: $e');
        emit(PlayerError(
          message: 'Error al obtener los jugadores.',
          error: e.toString(),
        ));
      }
    });
  }
}
