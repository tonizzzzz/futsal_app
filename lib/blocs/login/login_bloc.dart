// lib/blocs/login/login_bloc.dart
import 'package:bloc/bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../repositories/auth_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        // Ahora login devuelve el token como String, no 'void'
        final token = await authRepository.login(event.email, event.password);

        if (token.isNotEmpty) {
          emit(LoginSuccess());
        } else {
          emit(LoginFailure(error: 'Token vacío o no válido.'));
        }
      } catch (e) {
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}
