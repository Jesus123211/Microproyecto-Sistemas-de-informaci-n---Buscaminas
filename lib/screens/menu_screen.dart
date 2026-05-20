// lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';
import '/providers/game_provider.dart';
import 'game_screen.dart';
import 'instructions_screen.dart';
import 'high_scores_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        // Fondo temático adaptable al modo del sistema
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.blueGrey.shade900, Colors.black]
                : [
                    Colors.blue.shade300,
                    Colors.blue.shade100,
                  ], // Simulación de cielo/nubes de Mario
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Título animado flotante
                  FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 3),
                      ),
                      child: const Text(
                        '👾 MENU PRINCIPAL 👾',
                        style: TextStyle(
                          fontFamily: 'Courier New',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Grupo de botones del juego con animaciones escalonadas
                  _buildMenuButton(
                    context: context,
                    label: '▶ JUGAR',
                    color: Colors.green,
                    delayMs: 200,
                    onPressed: () {
                      Provider.of<GameProvider>(
                        context,
                        listen: false,
                      ).initializeGame();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      );
                    },
                  ),
                  _buildMenuButton(
                    context: context,
                    label: '🏆 MARCADORES',
                    color: Colors.orange,
                    delayMs: 400,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HighScoresScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    context: context,
                    label: '⚙ CONFIGURACIÓN',
                    color: Colors.blue.shade700,
                    delayMs: 600,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuButton(
                    context: context,
                    label: '📖 CÓMO JUGAR',
                    color: Colors.purple,
                    delayMs: 800,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InstructionsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Generador de botones grandes, claros y animados tal como pide el PDF
  Widget _buildMenuButton({
    required BuildContext context,
    required String label,
    required Color color,
    required int delayMs,
    required VoidCallback onPressed,
  }) {
    return FadeInLeft(
      delay: Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 600),
      child: Padding(
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
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Courier New',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
