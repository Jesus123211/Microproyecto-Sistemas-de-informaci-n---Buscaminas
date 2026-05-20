// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()..initializeGame()),
        // Inyectamos el nuevo provider y cargamos los ajustes guardados
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
      ],
      child: const BuscaminasApp(),
    ),
  );
}

class BuscaminasApp extends StatelessWidget {
  const BuscaminasApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el SettingsProvider para cambiar el tema en tiempo real
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'Buscaminas Flutter',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode, // ¡Tema dinámico conectado!
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
