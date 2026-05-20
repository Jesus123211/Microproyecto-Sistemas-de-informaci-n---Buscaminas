// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/cell_model.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BUSCAMINAS',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // Contador de minas restantes (Minas totales - Banderas puestas)
          Consumer<GameProvider>(
            builder: (context, game, child) {
              int remaining = game.minesCount - game.flagsCount;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Text(
                    '💣 $remaining',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          // Escuchamos si el jugador ganó o perdió para mostrar un mensaje
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (gameProvider.gameState == GameState.won ||
                gameProvider.gameState == GameState.lost) {
              _showGameOverDialog(context, gameProvider);
            }
          });

          // USO DE LAYOUTBUILDER PARA RESPONSIVIDAD (Bonus del proyecto)
          return LayoutBuilder(
            builder: (context, constraints) {
              // Calculamos un tamaño máximo para que no se deforme en Desktop
              double boardWidth = constraints.maxWidth * 0.95;
              if (boardWidth > 600) boardWidth = 600;

              return Center(
                child: SizedBox(
                  width: boardWidth,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gameProvider.cols,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                    ),
                    itemCount: gameProvider.rows * gameProvider.cols,
                    itemBuilder: (context, index) {
                      int row = index ~/ gameProvider.cols;
                      int col = index % gameProvider.cols;
                      CellModel cell = gameProvider.board[row][col];

                      return GestureDetector(
                        // Clic normal para abrir celda
                        onTap: () => gameProvider.revealCell(row, col),
                        // Dejar presionado para poner bandera (Móvil)
                        onLongPress: () => gameProvider.toggleFlag(row, col),
                        // Clic derecho para poner bandera (Desktop/Web)
                        onSecondaryTap: () => gameProvider.toggleFlag(row, col),
                        child: _buildCell(cell, context),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Diseño individual de cada celda
  Widget _buildCell(CellModel cell, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (cell.isRevealed) {
      if (cell.isMine) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text('💥', style: TextStyle(fontSize: 24)),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Text(
            cell.adjacentMines > 0 ? cell.adjacentMines.toString() : '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Courier New', // Estilo de número retro
              color: _getNumberColor(cell.adjacentMines, isDark),
            ),
          ),
        ),
      );
    }

    // Celda sin revelar
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade400,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 2),
        ],
      ),
      child: Center(
        child: cell.isFlagged
            ? const Text('🚩', style: TextStyle(fontSize: 22))
            : null,
      ),
    );
  }

  // Colores clásicos del buscaminas para los números
  Color _getNumberColor(int mines, bool isDark) {
    List<Color> lightColors = [
      Colors.transparent,
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.red.shade700,
      Colors.purple.shade700,
      Colors.orange.shade700,
    ];
    List<Color> darkColors = [
      Colors.transparent,
      Colors.lightBlueAccent,
      Colors.lightGreenAccent,
      Colors.redAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
    ];

    if (mines < 0 || mines >= lightColors.length)
      return isDark ? Colors.white : Colors.black;
    return isDark ? darkColors[mines] : lightColors[mines];
  }

  // Dialogo temporal de Fin de Partida (Game Over / Victoria)
  void _showGameOverDialog(BuildContext context, GameProvider game) {
    bool isWin = game.gameState == GameState.won;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(isWin ? '¡VICTORIA! 🏆' : '¡GAME OVER! 💥'),
        content: Text(
          isWin ? 'Has limpiado el campo de minas.' : 'Pisaste una mina.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra el dialogo
              game.initializeGame(); // Reinicia el tablero
            },
            child: const Text('Jugar de nuevo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Vuelve al menú principal
            },
            child: const Text('Salir al Menú'),
          ),
        ],
      ),
    );
  }
}
