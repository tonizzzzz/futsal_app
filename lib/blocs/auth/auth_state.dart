// lib/blocs/auth/auth_state.dart
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Estado inicial de autenticación
class AuthInitial extends AuthState {}

// Estado cuando el usuario no está autenticado (deslogueado)
class Unauthenticated extends AuthState {}

// Estado cuando el usuario está autenticado (logueado)
class Authenticated extends AuthState {
  final String username;

  Authenticated({required this.username});

  @override
  List<Object?> get props => [username];
}
