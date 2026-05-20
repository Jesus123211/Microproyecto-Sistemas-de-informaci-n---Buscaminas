// lib/providers/game_provider.dart
import 'dart:async';
import 'dart:math'; // Para la generación aleatoria de minas
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cell_model.dart';
import '../models/high_score_model.dart';

enum Difficulty { easy, medium, hard }

enum GameState { idle, playing, won, lost }

class GameProvider extends ChangeNotifier {
  late List<List<CellModel>> _board;
  late int _rows;
  late int _cols;
  late int _minesCount;
  int _flagsCount = 0;
  GameState _gameState = GameState.idle;
  Difficulty _difficulty = Difficulty.easy;

  int _elapsedSeconds = 0;
  int _attempts = 0;
  Timer? _timer;
  bool _timerStarted = false;

  List<List<CellModel>> get board => _board;
  int get rows => _rows;
  int get cols => _cols;
  int get minesCount => _minesCount;
  int get flagsCount => _flagsCount;
  GameState get gameState => _gameState;
  Difficulty get difficulty => _difficulty;
  int get elapsedSeconds => _elapsedSeconds;
  int get attempts => _attempts;

  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    initializeGame();
  }

  void initializeGame() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _attempts = 0;
    _timerStarted = false;

    // CORREGIDO: Cantidades exactas según el requerimiento del PDF
    switch (_difficulty) {
      case Difficulty.easy:
        _rows = 6;
        _cols = 6;
        _minesCount = 10; // 10 Minas
        break;
      case Difficulty.medium:
        _rows = 8;
        _cols = 8;
        _minesCount = 20; // 20 Minas
        break;
      case Difficulty.hard:
        _rows = 10;
        _cols = 10;
        _minesCount = 30; // 30 Minas
        break;
    }

    _flagsCount = 0;
    _gameState = GameState.playing;

    _board = List.generate(
      _rows,
      (r) => List.generate(_cols, (c) => CellModel(row: r, col: c)),
    );
    _generateMines();
    _countAdjacentMines();
    notifyListeners();
  }

  void _startTimer() {
    _timerStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing) {
        _elapsedSeconds++;
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _generateMines() {
    int minesPlaced = 0;
    final random = Random();
    while (minesPlaced < _minesCount) {
      int r = random.nextInt(_rows);
      int c = random.nextInt(_cols);
      if (!_board[r][c].isMine) {
        _board[r][c] = CellModel(row: r, col: c, isMine: true);
        minesPlaced++;
      }
    }
  }

  void _countAdjacentMines() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_board[r][c].isMine) continue;
        int count = 0;
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            int nr = r + i;
            int nc = c + j;
            if (nr >= 0 &&
                nr < _rows &&
                nc >= 0 &&
                nc < _cols &&
                _board[nr][nc].isMine) {
              count++;
            }
          }
        }
        _board[r][c] = CellModel(row: r, col: c, adjacentMines: count);
      }
    }
  }

  void revealCell(int r, int c) {
    if (_gameState != GameState.playing ||
        _board[r][c].isRevealed ||
        _board[r][c].isFlagged)
      return;

    if (!_timerStarted) {
      _startTimer();
    }

    _attempts++;
    _board[r][c] = CellModel(
      row: r,
      col: c,
      isMine: _board[r][c].isMine,
      adjacentMines: _board[r][c].adjacentMines,
      isRevealed: true,
    );

    if (_board[r][c].isMine) {
      _gameState = GameState.lost;
      _timer?.cancel();
      _revealAllMines(); // ← NUEVO: Revela el mapa completo de bombas al perder
    } else {
      if (_board[r][c].adjacentMines == 0) {
        _revealAdjacentCells(r, c);
      }
      _checkVictory();
    }
    notifyListeners();
  }

  // ALGORITMO NUEVO: Descubre la ubicación de todas las minas restantes al fallar
  void _revealAllMines() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_board[r][c].isMine) {
          _board[r][c] = CellModel(
            row: r,
            col: c,
            isMine: true,
            adjacentMines: _board[r][c].adjacentMines,
            isRevealed: true, // Forzamos el renderizado visual
            isFlagged: _board[r][c].isFlagged,
          );
        }
      }
    }
  }

  void _revealAdjacentCells(int r, int c) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int nr = r + i;
        int nc = c + j;
        if (nr >= 0 && nr < _rows && nc >= 0 && nc < _cols) {
          if (!_board[nr][nc].isMine &&
              !_board[nr][nc].isRevealed &&
              !_board[nr][nc].isFlagged) {
            _board[nr][nc] = CellModel(
              row: nr,
              col: nc,
              isMine: _board[nr][nc].isMine,
              adjacentMines: _board[nr][nc].adjacentMines,
              isRevealed: true,
            );
            if (_board[nr][nc].adjacentMines == 0) {
              _revealAdjacentCells(nr, nc);
            }
          }
        }
      }
    }
  }

  void toggleFlag(int r, int c) {
    if (_gameState != GameState.playing || _board[r][c].isRevealed) return;
    bool newFlagged = !_board[r][c].isFlagged;
    _board[r][c] = CellModel(
      row: r,
      col: c,
      isMine: _board[r][c].isMine,
      adjacentMines: _board[r][c].adjacentMines,
      isFlagged: newFlagged,
    );
    _flagsCount += newFlagged ? 1 : -1;
    notifyListeners();
  }

  void _checkVictory() {
    bool win = true;
    for (var row in _board) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) {
          win = false;
          break;
        }
      }
    }
    if (win) {
      _gameState = GameState.won;
      _timer?.cancel();
      _saveHighScore();
    }
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'high_scores_${_difficulty.name}';
    List<String> currentRecordsJson = prefs.getStringList(key) ?? [];

    final now = DateTime.now();
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    final newRecord = HighScoreRecord(
      timeInSeconds: _elapsedSeconds,
      attempts: _attempts,
      date: dateStr,
    );

    List<HighScoreRecord> records = currentRecordsJson
        .map((item) => HighScoreRecord.fromJson(item))
        .toList();

    records.add(newRecord);

    records.sort((a, b) {
      int cmp = a.timeInSeconds.compareTo(b.timeInSeconds);
      if (cmp == 0) return a.attempts.compareTo(b.attempts);
      return cmp;
    });

    if (records.length > 10) {
      records = records.sublist(0, 10);
    }

    List<String> updatedRecordsJson = records.map((r) => r.toJson()).toList();
    await prefs.setStringList(key, updatedRecordsJson);
  }
}
