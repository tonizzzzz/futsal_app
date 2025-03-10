// lib/blocs/auth/auth_bloc.dart
import 'package:bloc/bloc.dart';
import '../../services/token_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LogoutRequested>((event, emit) async {
      await TokenService.clearSession();
      emit(Unauthenticated());
    });
  }
}
