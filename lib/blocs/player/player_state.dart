// lib/blocs/player/player_state.dart
import 'package:equatable/equatable.dart';
import '../../models/player.dart';

abstract class PlayerState extends Equatable {
  @override
  List<Object> get props => [];
}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerLoaded extends PlayerState {
  final List<Player> players;

  PlayerLoaded({required this.players});

  @override
  List<Object> get props => [players];
}

class PlayerError extends PlayerState {
  final String message;
  final String error;

  PlayerError({required this.message, required this.error});

  @override
  List<Object> get props => [message, error];
}
