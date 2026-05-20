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

/// Pantalla de Menú Principal del Buscaminas.
///
/// Diseñada como un [StatelessWidget] para optimizar el rendimiento al tratarse
/// de una interfaz estática con navegación fija[cite: 155]. Cumple con los requerimientos
/// estéticos clásicos inspirados en el estilo retro de Super Mario[cite: 16, 21, 22].
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detecta si el sistema o la configuración se encuentra en modo oscuro
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Escucha el estado global de las preferencias (animaciones y sonidos)
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: Container(
        // Fondo temático inspirado en Mario (Cielo de día o de noche)
        // Se adapta dinámicamente según el brillo del tema seleccionado [cite: 21, 22, 40]
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
                              // Renderizado de tipografía retro a través de Google Fonts [cite: 29]
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

                      // Botones del menú principal [cite: 23]

                      // Opción: Jugar - Inicializa y lanza una nueva partida [cite: 24]
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

                      // Opción: Marcadores - Pantalla de mejores puntuaciones [cite: 25]
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

                      // Opción: Configuración - Panel de personalización [cite: 25]
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

                      // Opción: Cómo Jugar - Despliegue de instrucciones [cite: 26]
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

              // Créditos obligatorios en la parte inferior [cite: 27]
              // Posicionamiento absoluto para asegurar visibilidad constante sin romper el scroll
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Equipo: Abraham Zerpa / Jesus Bethencourt\nPeriodo: 2526-3',
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

  /// Wrapper de animación condicional.
  ///
  /// Evalúa si el parámetro [enabled] provisto por las configuraciones globales
  /// está activo[cite: 42, 150]. Si es falso, salta el envoltorio de `animate_do` y retorna
  /// directamente el widget hijo interno para anular el efecto visual de entrada.
  Widget _animate(bool enabled, Widget animatedWidget) {
    return enabled ? animatedWidget : (animatedWidget as dynamic).child;
  }

  /// Generador centralizado de botones del menú principal.
  ///
  /// Automatiza el diseño consistente de los botones del menú[cite: 23], integrando
  /// la tipografía pixel art [cite: 29][cite_start], efectos de retroalimentación de audio nativo[cite: 28],
  /// escalado secuencial por delays [cite: 30] [cite_start]y el callback de navegación personalizado[cite: 131].
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
            // Lee el estado actual de las configuraciones de sonido sin suscribir el widget a rediseños
            final settings = Provider.of<SettingsProvider>(
              context,
              listen: false,
            );
            // Si los efectos están habilitados, reproduce el clic del sistema háptico/nativo [cite: 28, 41]
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

    // Retorna el botón envuelto en la animación direccional si está permitida
    return _animate(
      animEnabled,
      FadeInLeft(
        delay: Duration(milliseconds: delayMs),
        child: btn,
      ),
    );
  }
}
