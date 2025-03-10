// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsal/theme.dart';
import 'blocs/login/login_bloc.dart';
import 'repositories/auth_repository.dart';
import 'middleware/auth_guard.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/players_page.dart';
import 'pages/calendar_page.dart';
import 'services/token_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  final token = await TokenService.getToken();

  runApp(FutsalApp(initialRoute: token != null ? '/home' : '/login'));
}

class FutsalApp extends StatelessWidget {
  final String initialRoute;

  const FutsalApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(authRepository: AuthRepository()),
      child: MaterialApp(
        title: 'Futsal App',
        theme: AppTheme.lightTheme, // 🔹 Aplicamos el tema global aquí
        initialRoute: initialRoute,
        routes: {
          '/login':
              (context) => BlocProvider(
                create: (_) => LoginBloc(authRepository: AuthRepository()),
                child: LoginPage(),
              ),
          '/home': (context) => const AuthGuard(child: HomePage()),

          // Obtiene el token dinámicamente para la página de jugadores
          '/players':
              (context) => FutureBuilder<String?>(
                future: TokenService.getToken(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return AuthGuard(
                      child: PlayersPage(
                        token: snapshot.data!,
                      ), // Parámetro 'token' correctamente definido
                    );
                  } else {
                    return LoginPage();
                  }
                },
              ),

          '/calendar': (context) => const AuthGuard(child: CalendarPage()),
        },
      ),
    );
  }
}
