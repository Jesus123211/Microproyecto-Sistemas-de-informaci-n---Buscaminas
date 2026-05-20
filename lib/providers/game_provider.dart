// lib/providers/game_provider.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cell_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameState { idle, playing, won, lost }

enum Difficulty { easy, medium, hard }

class GameProvider extends ChangeNotifier {
  // Configuración de tamaños según las especificaciones del enunciado [cite: 34, 35, 36]
  Difficulty _difficulty = Difficulty.easy;
  int _rows = 6;
  int _cols = 6;
  int _minesCount = 10;

  List<List<CellModel>> _board = [];
  GameState _gameState = GameState.idle;
  int _flagsCount = 0;

  // Getters para que la UI pueda leer los datos de forma segura
  List<List<CellModel>> get board => _board;
  GameState get gameState => _gameState;
  Difficulty get difficulty => _difficulty;
  int get rows => _rows;
  int get cols => _cols;
  int get minesCount => _minesCount;
  int get flagsCount => _flagsCount;

  // Cambiar dificultad y resetear el juego [cite: 37]
  void setDifficulty(Difficulty diff) {
    _difficulty = diff;
    switch (diff) {
      case Difficulty.easy:
        _rows = 6;
        _cols = 6;
        _minesCount = 10;
        break;
      case Difficulty.medium:
        _rows = 8;
        _cols = 8;
        _minesCount = 20;
        break;
      case Difficulty.hard:
        _rows = 10;
        _cols = 10;
        _minesCount = 30;
        break;
    }
    initializeGame();
  }

  // Inicializa o reinicia el tablero completamente limpio [cite: 82]
  void initializeGame() {
    _gameState = GameState.idle;
    _flagsCount = 0;

    _board = List.generate(_rows, (r) {
      return List.generate(_cols, (c) => CellModel(row: r, col: c));
    });

    notifyListeners();
  }

  // Se ejecuta al hacer el primer clic para asegurar que nunca se pierda en el primer intento [cite: 86]
  void _generateMinesAndNumbers(int firstRow, int firstCol) {
    int placedMines = 0;
    final random = Random();

    while (placedMines < _minesCount) {
      int r = random.nextInt(_rows);
      int c = random.nextInt(_cols);

      // Evita poner una mina donde ya hay una, o en la primera celda presionada [cite: 84, 86]
      if (!_board[r][c].isMine && !(r == firstRow && c == firstCol)) {
        _board[r][c].isMine = true;
        placedMines++;
      }
    }

    // Calcular números adyacentes a las minas
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (!_board[r][c].isMine) {
          _board[r][c].adjacentMines = _countAdjacentMines(r, c);
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        int nr = row + dr;
        int nc = col + dc;
        if (nr >= 0 && nr < _rows && nc >= 0 && nc < _cols) {
          if (_board[nr][nc].isMine) count++;
        }
      }
    }
    return count;
  }

  // Acción principal: Revelar una celda [cite: 89]
  void revealCell(int row, int col) {
    if (_gameState == GameState.won || _gameState == GameState.lost) return;

    CellModel cell = _board[row][col];
    if (cell.isRevealed || cell.isFlagged) return;

    // Si es el primer movimiento, genera el tablero de forma segura [cite: 86]
    if (_gameState == GameState.idle) {
      _gameState = GameState.playing;
      _generateMinesAndNumbers(row, col);
    }

    // Si toca una mina -> PIERDE [cite: 90]
    if (cell.isMine) {
      cell.isRevealed = true;
      _gameState = GameState.lost;
      _revealAllMines(); // Muestra todas las minas al perder [cite: 103]
      notifyListeners();
      return;
    }

    // Si está vacía -> Algoritmo Flood Fill
    if (cell.adjacentMines == 0) {
      _floodFill(row, col);
    } else {
      cell.isRevealed = true;
    }

    _checkVictory();
    notifyListeners();
  }

  // Algoritmo recursivo Flood Fill para abrir celdas vacías conectadas
  void _floodFill(int row, int col) {
    if (row < 0 || row >= _rows || col < 0 || col >= _cols) return;
    CellModel cell = _board[row][col];
    if (cell.isRevealed || cell.isMine || cell.isFlagged) return;

    cell.isRevealed = true;

    if (cell.adjacentMines == 0) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          _floodFill(row + dr, col + dc);
        }
      }
    }
  }

  // Alternar bandera (Flag) [cite: 93]
  void toggleFlag(int row, int col) {
    if (_gameState != GameState.playing && _gameState != GameState.idle) return;
    CellModel cell = _board[row][col];
    if (cell.isRevealed) return;

    cell.isFlagged = !cell.isFlagged;
    _flagsCount += cell.isFlagged ? 1 : -1;
    notifyListeners();
  }

  void _revealAllMines() {
    for (var row in _board) {
      for (var cell in row) {
        if (cell.isMine) cell.isRevealed = true;
      }
    }
  }

  void _checkVictory() {
    bool win = true;
    for (var row in _board) {
      for (var cell in row) {
        // Si hay una celda segura que aún no se ha revelado, no ha ganado
        if (!cell.isMine && !cell.isRevealed) {
          win = false;
          break;
        }
      }
    }
    if (win) {
      _gameState = GameState.won; // Victoria total
      _saveHighScore(); // Guardamos la victoria localmente
    }
  }

  // Método para persistir la victoria según la dificultad
  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'victories_${_difficulty.name}';
    int currentVictories = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, currentVictories + 1);
  }
}
