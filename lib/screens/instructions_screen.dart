// lib/screens/instructions_screen.dart
import 'package:flutter/material.dart';

/// Pantalla estática de Instrucciones / Cómo Jugar.
///
/// Muestra al usuario las reglas básicas del Buscaminas mediante una lista
/// de tarjetas informativas. Al ser contenido que no cambia de estado dinámicamente,
/// se implementa extendiendo [StatelessWidget] para garantizar un rendimiento óptimo.
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de navegación superior con el título de la pantalla
      appBar: AppBar(
        title: const Text(
          '📖 CÓMO JUGAR',
          style: TextStyle(
            fontFamily:
                'Courier New', // Tipografía consistente con el diseño retro del juego
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors
            .purple
            .shade800, // Color característico asignado a esta sección
        foregroundColor: Colors.white,
      ),
      // Se utiliza un ListView para permitir el desplazamiento fluido si el contenido excede la pantalla
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Módulo 1: Explicación del objetivo principal de la partida
          _buildInstructionCard(
            icon: '🎯',
            title: 'Objetivo del Juego',
            description:
                'El objetivo es despejar todo el tablero sin detonar ninguna mina oculta.',
          ),
          // Módulo 2: Mecánica de interacción básica para descubrir celdas
          _buildInstructionCard(
            icon: '👆',
            title: 'Revelar Casillas',
            description:
                'Toca una casilla para revelarla. Si esconde una mina, pierdes el juego inmediatamente. Si está vacía, mostrará un número.',
          ),
          // Módulo 3: Explicación de la lógica matemática del tablero
          _buildInstructionCard(
            icon: '🔢',
            title: 'Los Números',
            description:
                'El número en una casilla indica exactamente cuántas minas hay en las 8 casillas adyacentes (arriba, abajo, lados y diagonales). Usa esta información para deducir qué casillas son seguras.',
          ),
          // Módulo 4: Controles adaptativos según la plataforma (Mobile vs Web/Desktop)
          _buildInstructionCard(
            icon: '🚩',
            title: 'Colocar Banderas',
            description:
                'Si crees saber dónde hay una mina, coloca una bandera para no tocarla por accidente.\n• En Móvil: Mantén presionada la casilla.\n• En PC/Web: Haz clic derecho.',
          ),
          // Módulo 5: Condición de victoria esperada por el sistema
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

  /// Construye una tarjeta visual estandarizada para cada regla del juego.
  ///
  /// [icon] Emoji o símbolo representativo de la instrucción.
  /// [title] Título principal de la regla.
  /// [description] Explicación detallada de la mecánica.
  ///
  /// Utiliza un widget [Expanded] en el texto para garantizar que la descripción
  /// se adapte correctamente a múltiples tamaños de pantalla sin desbordamientos.
  Widget _buildInstructionCard({
    required String icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4, // Sombra para darle profundidad y separación al diseño
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono a la izquierda de la tarjeta
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            // Bloque de texto principal
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
