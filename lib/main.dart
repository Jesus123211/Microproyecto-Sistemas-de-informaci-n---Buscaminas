import 'package:flutter/material.dart';

void main() {
  runApp(const BuscaminasApp());
}

class BuscaminasApp extends StatelessWidget {
  const BuscaminasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buscaminas Flutter',
      debugShowCheckedModeBanner: false,
      // Configuración del tema claro, oscuro y automático
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Aquí luego aplicaremos la tipografía retro [cite: 29]
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Scaffold temporal hasta crear nuestra SplashScreen [cite: 17, 18]
      home: const Scaffold(body: Center(child: Text('Cargando Buscaminas...'))),
    );
  }
}
