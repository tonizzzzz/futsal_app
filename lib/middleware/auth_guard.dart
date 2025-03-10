// lib/middleware/auth_guard.dart
import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../pages/login_page.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra un indicador de carga mientras se verifica el token
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Si el token existe, muestra la pantalla solicitada
          return child;
        } else {
          // Si no hay token, redirige al LoginPage
          return LoginPage();
        }
      },
    );
  }
}
