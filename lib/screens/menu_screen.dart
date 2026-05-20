// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importante para los sonidos nativos
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Importante para la fuente pixel

import '../providers/settings_provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';
import 'high_scores_screen.dart';
import 'settings_screen.dart';
import 'instructions_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: Container(
        // Fondo temático inspirado en Mario (Cielo de día o de noche)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B)]
                : [const Color(0xFF5CB8FF), const Color(0xFFE0F7FA)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título con fuente Pixel Art real
                      _animate(
                        settings.animationsEnabled,
                        FadeInDown(
                          duration: const Duration(milliseconds: 1000),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber, width: 4),
                            ),
                            child: Text(
                              '👾 BUSCAMINAS 👾',
                              // ¡FUENTE RETO ACTIVADA!
                              style: GoogleFonts.pressStart2p(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Botones del menú
                      _buildMenuButton(
                        context,
                        '▶ JUGAR',
                        Colors.green,
                        200,
                        settings.animationsEnabled,
                        () {
                          Provider.of<GameProvider>(
                            context,
                            listen: false,
                          ).initializeGame();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GameScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuButton(
                        context,
                        '🏆 MARCADORES',
                        Colors.orange,
                        400,
                        settings.animationsEnabled,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HighScoresScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuButton(
                        context,
                        '⚙ CONFIGURACION',
                        Colors.blue.shade700,
                        600,
                        settings.animationsEnabled,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuButton(
                        context,
                        '📖 COMO JUGAR',
                        Colors.purple,
                        800,
                        settings.animationsEnabled,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const InstructionsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 60), // Espacio para los créditos
                    ],
                  ),
                ),
              ),
              // Créditos obligatorios en la parte inferior
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Equipo: Abraham Zerpa y Jesus Bethencourt\nPeriodo: 2526-3',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8, // Letra pequeña para que quepa bien
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        const Shadow(color: Colors.black, blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wrapper para desactivar animaciones si el usuario lo prefiere
  Widget _animate(bool enabled, Widget animatedWidget) {
    return enabled ? animatedWidget : (animatedWidget as dynamic).child;
  }

  // Generador de botones con SONIDO y FUENTE pixel integrados
  Widget _buildMenuButton(
    BuildContext context,
    String label,
    Color color,
    int delayMs,
    bool animEnabled,
    VoidCallback accionAlPulsar,
  ) {
    Widget btn = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.white, width: 3),
            ),
          ),
          onPressed: () {
            // AQUÍ ESTÁ EL TRUCO DEL SONIDO:
            final settings = Provider.of<SettingsProvider>(
              context,
              listen: false,
            );
            if (settings.soundEnabled) {
              SystemSound.play(
                SystemSoundType.click,
              ); // Ejecuta el clic sutil del sistema
            }
            accionAlPulsar(); // Luego hace la navegación normal
          },
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );

    return _animate(
      animEnabled,
      FadeInLeft(
        delay: Duration(milliseconds: delayMs),
        child: btn,
      ),
    );
  }
}
