// lib/blocs/player/player_event.dart
import 'package:equatable/equatable.dart';

abstract class PlayerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchPlayers extends PlayerEvent {
  final String token;

  FetchPlayers({required this.token});

  @override
  List<Object> get props => [token];
}
