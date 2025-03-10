// lib/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Evento para solicitar el deslogueo
class LogoutRequested extends AuthEvent {}
