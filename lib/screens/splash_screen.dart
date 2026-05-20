// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Redirecciona automáticamente al menú después de 3.5 segundos
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) _navigateToMenu();
    });
  }

  void _navigateToMenu() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MenuScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro para el estilo retro
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animación de entrada con rebote para el título principal
                BounceInDown(
                  duration: const Duration(milliseconds: 1500),
                  child: const Text(
                    'BUSCAMINAS\nFLUTTER',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily:
                          'Courier New', // Tipografía de ancho fijo estilo pixel
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Animación de parpadeo continuo para simular las máquinas arcade clásicas
                Flash(
                  infinite: true,
                  duration: const Duration(seconds: 2),
                  child: const Text(
                    'CARGANDO AVANCE...',
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botón obligatorio para saltar la animación e ir directo al juego
          Positioned(
            bottom: 40,
            right: 20,
            child: FadeIn(
              delay: const Duration(milliseconds: 800),
              child: TextButton(
                onPressed: _navigateToMenu,
                child: const Row(
                  children: [
                    Text(
                      'SALTAR',
                      style: TextStyle(
                        color: Colors.amber,
                        fontFamily: 'Courier New',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.skip_next, color: Colors.amber),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
