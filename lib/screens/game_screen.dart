// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../models/cell_model.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameProvider.gameState == GameState.won ||
          gameProvider.gameState == GameState.lost) {
        _showGameOverDialog(context, gameProvider, settings);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BUSCAMINAS',
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Center(
              child: Text(
                '💣 ${gameProvider.minesCount - gameProvider.flagsCount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
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
                    onTap: () {
                      if (settings.soundEnabled &&
                          !cell.isRevealed &&
                          !cell.isFlagged) {
                        SystemSound.play(SystemSoundType.click);
                      }
                      gameProvider.revealCell(row, col);
                    },
                    onLongPress: () {
                      if (settings.soundEnabled && !cell.isRevealed) {
                        SystemSound.play(SystemSoundType.click);
                      }
                      gameProvider.toggleFlag(row, col);
                    },
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
    );
  }

  Widget _buildCell(
    CellModel cell,
    BuildContext context,
    SettingsProvider settings,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (cell.isRevealed) {
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
        return settings.animationsEnabled
            ? ShakeX(child: mineWidget)
            : mineWidget;
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
            style: _getCustomNumberStyle(
              cell.adjacentMines,
              settings.numberStyle,
              isDark,
            ),
          ),
        ),
      );
    }

    Widget unrevealedCell = Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade700 : Colors.blue.shade400,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
      ),
      child: Center(
        child: cell.isFlagged
            ? const Text('🚩', style: TextStyle(fontSize: 20))
            : null,
      ),
    );

    return settings.animationsEnabled
        ? FadeIn(
            duration: const Duration(milliseconds: 300),
            child: unrevealedCell,
          )
        : unrevealedCell;
  }

  // CORREGIDO: Eliminados Colors.magenta y Colors.maroon que daban error
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

  void _showGameOverDialog(
    BuildContext context,
    GameProvider game,
    SettingsProvider settings,
  ) {
    bool isWin = game.gameState == GameState.won;

    showDialog(
      context: context,
      barrierDismissible: false,
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
              ? 'Has limpiado el campo con éxito.'
              : 'Detonaste una mina oculta.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              game.initializeGame();
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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
