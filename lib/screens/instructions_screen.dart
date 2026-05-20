// lib/screens/instructions_screen.dart
import 'package:flutter/material.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📖 CÓMO JUGAR',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildInstructionCard(
            icon: '🎯',
            title: 'Objetivo del Juego',
            description:
                'El objetivo es despejar todo el tablero sin detonar ninguna mina oculta.',
          ),
          _buildInstructionCard(
            icon: '👆',
            title: 'Revelar Casillas',
            description:
                'Toca una casilla para revelarla. Si esconde una mina, pierdes el juego inmediatamente. Si está vacía, mostrará un número.',
          ),
          _buildInstructionCard(
            icon: '🔢',
            title: 'Los Números',
            description:
                'El número en una casilla indica exactamente cuántas minas hay en las 8 casillas adyacentes (arriba, abajo, lados y diagonales). Usa esta información para deducir qué casillas son seguras.',
          ),
          _buildInstructionCard(
            icon: '🚩',
            title: 'Colocar Banderas',
            description:
                'Si crees saber dónde hay una mina, coloca una bandera para no tocarla por accidente.\n• En Móvil: Mantén presionada la casilla.\n• En PC/Web: Haz clic derecho.',
          ),
          _buildInstructionCard(
            icon: '🏆',
            title: 'Victoria',
            description:
                'Ganas la partida cuando has revelado todas las casillas seguras del tablero. ¡Las banderas no son obligatorias para ganar, pero ayudan mucho!',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier New',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
