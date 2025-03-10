import 'package:flutter/material.dart';
import 'core/router.dart';
import 'core/theme.dart';

void main() {
  runApp(const FutsalApp());
}

class FutsalApp extends StatelessWidget {
  const FutsalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute, // 🔹 Se mantiene sin cambios
    );
  }
}
