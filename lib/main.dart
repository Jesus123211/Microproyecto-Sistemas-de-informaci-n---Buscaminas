// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    // Inyectamos el proveedor en la raíz para cumplir con el manejo de estados limpio
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()..initializeGame()),
      ],
      child: const BuscaminasApp(),
    ),
  );
}

class BuscaminasApp extends StatelessWidget {
  const BuscaminasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscaminas Flutter',
      debugShowCheckedModeBanner: false,
      // Configuración obligatoria de temas claro, oscuro y automático
      themeMode: ThemeMode.system,
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
      // Scaffold temporal que cambiaremos por la SplashScreen animada
      home: const SplashScreen(),
    );
  }
}

class TempHomeScreen extends StatelessWidget {
  const TempHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado del juego para verificar que la inyección funciona
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscaminas Base'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tablero listo: ${gameProvider.rows}x${gameProvider.cols}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Estado actual: ${gameProvider.gameState.name.toUpperCase()}'),
          ],
        ),
      ),
    );
  }
}
