// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../models/cell_model.dart';

/// Pantalla Principal del Tablero de Juego.
///
/// Gestiona la grilla interactiva del Buscaminas, la barra de estadísticas en vivo
/// y la sincronización entre las interacciones del usuario y el estado global mediante Providers.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  /// Transforma un conteo de segundos a una cadena con formato cronométrico 'MM:SS'.
  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Consumo de los Providers de estado global del juego y configuración del usuario
    final gameProvider = Provider.of<GameProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    // CRÍTICO: Planifica la ejecución del diálogo después de que termine la fase de renderizado.
    // Esto previene fallos de ciclo de vida en Flutter al intentar abrir un Dialog interrumpiendo un Build en progreso.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameProvider.gameState == GameState.won ||
          gameProvider.gameState == GameState.lost) {
        _showGameOverDialog(context, gameProvider, settings);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TABLERO',
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // PANEL SUPERIOR DE ESTADÍSTICAS EN VIVO
            // Muestra en tiempo real el tiempo transcurrido, intentos y balance de banderas/minas
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Cronómetro en vivo
                  Text(
                    '⏱️ ${_formatTime(gameProvider.elapsedSeconds)}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: Colors.amber,
                    ),
                  ),
                  // Contador de clics efectuados
                  Text(
                    '🎯 CLICS: ${gameProvider.attempts}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  // Banderas colocadas / Minas totales
                  Text(
                    '🚩 ${gameProvider.flagsCount}/${gameProvider.minesCount}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            // GRILLA DE JUEGO RESPONSIVA
            // Se utiliza LayoutBuilder para calcular dimensiones dinámicas adaptables a Web/Mobile
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Ajusta el ancho del tablero tomando el 95% del espacio disponible, topado a un máximo de 600px
                  double boardWidth = constraints.maxWidth * 0.95;
                  if (boardWidth > 600) boardWidth = 600;

                  return Center(
                    child: SizedBox(
                      width: boardWidth,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gameProvider
                              .cols, // Número de columnas según dificultad
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                        ),
                        itemCount: gameProvider.rows * gameProvider.cols,
                        itemBuilder: (context, index) {
                          // Mapeo bidimensional del índice lineal del GridView
                          int row = index ~/ gameProvider.cols;
                          int col = index % gameProvider.cols;
                          CellModel cell = gameProvider.board[row][col];

                          // Captura de gestos táctiles y de periféricos de escritorio
                          return GestureDetector(
                            // Toque estándar: Revelar casilla
                            onTap: () {
                              if (settings.soundEnabled &&
                                  !cell.isRevealed &&
                                  !cell.isFlagged) {
                                SystemSound.play(SystemSoundType.click);
                              }
                              gameProvider.revealCell(row, col);
                            },
                            // Toque prolongado: Colocar/quitar bandera (Diseño Mobile)
                            onLongPress: () {
                              if (settings.soundEnabled && !cell.isRevealed) {
                                SystemSound.play(SystemSoundType.click);
                              }
                              gameProvider.toggleFlag(row, col);
                            },
                            // Clic derecho / secundario: Colocar/quitar bandera (Diseño PC/Web)
                            onSecondaryTap: () {
                              if (settings.soundEnabled && !cell.isRevealed) {
                                SystemSound.play(SystemSoundType.click);
                              }
                              gameProvider.toggleFlag(row, col);
                            },
                            child: _buildCell(cell, context, settings),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye visualmente la celda individual de acuerdo a sus propiedades de estado.
  ///
  /// Evalúa de forma jerárquica si la casilla está revelada, si detonó una mina,
  /// si está marcada con bandera o si cuenta con minas adyacentes.
  Widget _buildCell(
    CellModel cell,
    BuildContext context,
    SettingsProvider settings,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ESCENARIO A: Casilla ya descubierta por el jugador
    if (cell.isRevealed) {
      // Sub-escenario 1: Es una mina (Derrota)
      if (cell.isMine) {
        Widget mineWidget = Container(
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text('💥', style: TextStyle(fontSize: 22)),
          ),
        );
        // Aplica efecto de sacudida animada si las configuraciones globales lo permiten
        return settings.animationsEnabled
            ? ShakeX(child: mineWidget)
            : mineWidget;
      }

      // Sub-escenario 2: Casilla vacía segura (Muestra el número de proximidad si es > 0)
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Text(
            cell.adjacentMines > 0 ? cell.adjacentMines.toString() : '',
            style: _getCustomNumberStyle(
              cell.adjacentMines,
              settings.numberStyle,
              isDark,
            ),
          ),
        ),
      );
    }

    // ESCENARIO B: Casilla oculta (Por defecto)
    Widget unrevealedCell = Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade400,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
      ),
      child: Center(
        child: cell.isFlagged
            ? const Text(
                '🚩',
                style: TextStyle(fontSize: 20),
              ) // Dibuja la bandera si está señalada
            : null,
      ),
    );

    // Renderiza la celda oculta aplicando una animación sutil de entrada si está habilitada
    return settings.animationsEnabled
        ? FadeIn(
            duration: const Duration(milliseconds: 300),
            child: unrevealedCell,
          )
        : unrevealedCell;
  }

  /// Retorna la tipografía y paleta de colores de los números según las preferencias estéticas del juego.
  ///
  /// Da cumplimiento estricto al requerimiento funcional de soportar temas visuales personalizados:
  /// - Colorido: Tonos modernos de alto contraste.
  /// - Retro: Look arcade pixelado con [GoogleFonts.pressStart2p].
  /// - Minimalista: Estilo limpio, delgado y sobrio.
  /// - Clásico: Formato tradicional estilo Windows 95 mediante 'Courier New'.
  TextStyle _getCustomNumberStyle(int mines, String style, bool isDark) {
    if (mines == 0) return const TextStyle();

    switch (style) {
      case 'Colorido':
        List<Color> colorful = [
          Colors.transparent,
          Colors.pink,
          Colors.lime.shade700,
          Colors.cyan,
          Colors.purpleAccent,
          Colors.orange,
        ];
        return TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: mines < colorful.length ? colorful[mines] : Colors.teal,
        );
      case 'Retro':
        List<Color> retroColors = [
          Colors.transparent,
          Colors.blue,
          Colors.green,
          Colors.red,
          Colors.yellow.shade800,
          Colors.deepPurple,
        ];
        return GoogleFonts.pressStart2p(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: mines < retroColors.length ? retroColors[mines] : Colors.white,
        );
      case 'Minimalista':
        return TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300,
          color: isDark ? Colors.white70 : Colors.black87,
        );
      case 'Clásico':
      default:
        List<Color> classicColors = [
          Colors.transparent,
          Colors.blue.shade900,
          Colors.green.shade900,
          Colors.red.shade900,
          Colors.purple.shade900,
          Colors.brown,
        ];
        return TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier New',
          color: mines < classicColors.length
              ? classicColors[mines]
              : Colors.black,
        );
    }
  }

  /// Despliega el diálogo de fin de partida imposibilitando el cierre accidental.
  ///
  /// Informa sobre el resultado (`won` o `lost`) y ofrece flujos de redirección clara:
  /// reiniciar el tablero inmediatamente o volver al menú principal.
  void _showGameOverDialog(
    BuildContext context,
    GameProvider game,
    SettingsProvider settings,
  ) {
    bool isWin = game.gameState == GameState.won;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Bloquea interacciones externas obligando al usuario a responder
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          isWin ? '¡VICTORIA! 🏆' : '¡GAME OVER! 💥',
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: isWin ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        content: Text(
          isWin
              ? 'Record guardado en Marcadores.'
              : 'Detonaste una mina oculta.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // Opción 1: Re-inicializar el generador de matrices lógicas para un nuevo juego
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el Alert Dialog
              game.initializeGame(); // Reinicia el estado a través del Provider
            },
            child: Text(
              'REINTENTAR',
              style: TextStyle(
                color: Colors.amber,
                fontFamily: GoogleFonts.pressStart2p().fontFamily,
                fontSize: 10,
              ),
            ),
          ),
          // Opción 2: Efectuar pop doble para limpiar la pila de navegación y regresar a la Home
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Remueve diálogo
              Navigator.pop(context); // Remueve GameScreen
            },
            child: Text(
              'MENU',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: GoogleFonts.pressStart2p().fontFamily,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
