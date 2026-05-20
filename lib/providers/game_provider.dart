// lib/providers/game_provider.dart
import 'dart:async';
import 'dart:math'; // Para la generación aleatoria de minas
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cell_model.dart';
import '../models/high_score_model.dart';

/// Define los niveles de dificultad del juego.
enum Difficulty { easy, medium, hard }

/// Representa el ciclo de vida de una partida en curso.
enum GameState { idle, playing, won, lost }

/// Proveedor de Estado Principal: Lógica de Negocio del Buscaminas.
///
/// Este [ChangeNotifier] maneja de forma centralizada todas las reglas matemáticas
/// del juego, desde la generación procedimental del tablero (con un algoritmo aleatorio)
/// hasta la detección recursiva de celdas adyacentes (`flood fill`). Implementa
/// una clara separación de responsabilidades desligando la UI de la lógica pura.
class GameProvider extends ChangeNotifier {
  // --- Estado Interno del Tablero ---
  late List<List<CellModel>> _board;
  late int _rows;
  late int _cols;
  late int _minesCount;
  int _flagsCount = 0;

  // --- Estado del Flujo de Juego ---
  GameState _gameState = GameState.idle;
  Difficulty _difficulty = Difficulty.easy;

  // --- Estadísticas y Cronometraje ---
  int _elapsedSeconds = 0;
  int _attempts = 0;
  Timer? _timer;
  bool _timerStarted = false;

  // --- Getters de Exposición Segura ---
  List<List<CellModel>> get board => _board;
  int get rows => _rows;
  int get cols => _cols;
  int get minesCount => _minesCount;
  int get flagsCount => _flagsCount;
  GameState get gameState => _gameState;
  Difficulty get difficulty => _difficulty;
  int get elapsedSeconds => _elapsedSeconds;
  int get attempts => _attempts;

  /// Cambia el nivel de dificultad global y reinicia el estado del tablero
  /// automáticamente para acomodar las nuevas dimensiones.
  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    initializeGame();
  }

  /// Arranca un nuevo ciclo de juego.
  ///
  /// Limpia los contadores, detiene timers en ejecución, dimensiona la matriz
  /// bidimensional según la dificultad activa y distribuye las minas aleatoriamente.
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

    // Creación estructural de la matriz de celdas
    _board = List.generate(
      _rows,
      (r) => List.generate(_cols, (c) => CellModel(row: r, col: c)),
    );

    // Inyección de minas y cálculo matemático perimetral
    _generateMines();
    _countAdjacentMines();
    notifyListeners();
  }

  /// Instancia y arranca un temporizador asíncrono que suma segundos a la partida.
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

  /// Algoritmo procedimental para esparcir minas aleatoriamente.
  ///
  /// Emplea un ciclo [while] y un generador [Random] para garantizar que siempre
  /// se ubique la cantidad exacta de minas, omitiendo celdas ya ocupadas.
  void _generateMines() {
    int minesPlaced = 0;
    final random = Random();
    while (minesPlaced < _minesCount) {
      int r = random.nextInt(_rows);
      int c = random.nextInt(_cols);
      // Solo sobreescribe la celda si previamente no tenía bomba
      if (!_board[r][c].isMine) {
        _board[r][c] = CellModel(row: r, col: c, isMine: true);
        minesPlaced++;
      }
    }
  }

  /// Recorre el tablero analizando las zonas colindantes de cada casilla segura.
  ///
  /// Utiliza un doble bucle iterativo (Offset de -1 a 1 en filas/columnas) para
  /// calcular y registrar cuántas minas comparten vértice o arista con una celda.
  void _countAdjacentMines() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        if (_board[r][c].isMine) continue; // Si es bomba, ignora el cálculo
        int count = 0;

        // Iteración sobre los 8 vecinos inmediatos
        for (int i = -1; i <= 1; i++) {
          for (int j = -1; j <= 1; j++) {
            int nr = r + i;
            int nc = c + j;
            // Validación de fronteras para evitar errores (Index Out Of Bounds)
            if (nr >= 0 &&
                nr < _rows &&
                nc >= 0 &&
                nc < _cols &&
                _board[nr][nc].isMine) {
              count++;
            }
          }
        }
        // Sobreescribe la celda integrando el peso numérico de proximidad
        _board[r][c] = CellModel(row: r, col: c, adjacentMines: count);
      }
    }
  }

  /// Lógica de impacto al interactuar / destapar una celda de la grilla.
  ///
  /// [r] Fila de la matriz.
  /// [c] Columna de la matriz.
  void revealCell(int r, int c) {
    // Reglas de bloqueo: no accionar si el juego acabó, o si la celda está revelada/marcada
    if (_gameState != GameState.playing ||
        _board[r][c].isRevealed ||
        _board[r][c].isFlagged)
      return;

    // Solo al primer destape se arranca el cronómetro
    if (!_timerStarted) {
      _startTimer();
    }

    _attempts++; // Suma al registro de interacciones del usuario
    _board[r][c] = CellModel(
      row: r,
      col: c,
      isMine: _board[r][c].isMine,
      adjacentMines: _board[r][c].adjacentMines,
      isRevealed: true,
    );

    // Condición de derrota: destapó bomba
    if (_board[r][c].isMine) {
      _gameState = GameState.lost;
      _timer?.cancel();
      _revealAllMines(); // ← NUEVO: Revela el mapa completo de bombas al perder
    } else {
      // Condición expansiva: si la casilla no tiene minas cerca (valor 0), lanza algoritmo de área libre
      if (_board[r][c].adjacentMines == 0) {
        _revealAdjacentCells(r, c);
      }
      _checkVictory(); // Analiza si este último movimiento resolvió el tablero completo
    }
    notifyListeners(); // Notifica el cambio drástico del árbol de estados a la UI
  }

  /// ALGORITMO NUEVO: Descubre la ubicación de todas las minas restantes al fallar.
  /// Forzará la renderización visual de los sprites de las bombas en toda la cuadrícula.
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

  /// Algoritmo Recursivo Flood Fill para despeje masivo de zonas sin peligro.
  ///
  /// Cuando una celda '0' es destapada, este método "expande" la revelación a sus
  /// 8 vecinos inmediatos. Si alguno de estos también es 0, la función se llama
  /// a sí misma de manera recursiva hasta topar con celdas que poseen advertencias numéricas.
  void _revealAdjacentCells(int r, int c) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int nr = r + i;
        int nc = c + j;

        // Verifica límites del array multidimensional
        if (nr >= 0 && nr < _rows && nc >= 0 && nc < _cols) {
          if (!_board[nr][nc].isMine &&
              !_board[nr][nc].isRevealed &&
              !_board[nr][nc].isFlagged) {
            _board[nr][nc] = CellModel(
              row: nr,
              col: nc,
              isMine: _board[nr][nc].isMine,
              adjacentMines: _board[nr][nc].adjacentMines,
              isRevealed: true, // Revela a los vecinos
            );

            // Recursividad: Si el vecino es '0', repite el proceso para crear un área grande
            if (_board[nr][nc].adjacentMines == 0) {
              _revealAdjacentCells(nr, nc);
            }
          }
        }
      }
    }
  }

  /// Intercambia el estado de una bandera en una casilla dada y ajusta el contador.
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

    // Impacta reactivamente el indicador matemático del Header del tablero UI
    _flagsCount += newFlagged ? 1 : -1;
    notifyListeners();
  }

  /// Escanea iterativamente toda la matriz verificando la condición final de victoria.
  ///
  /// La condición técnica es: Toda celda que NO es bomba, DEBE estar revelada.
  /// Al confirmarse, finaliza la partida y salva las marcas locales [SharedPrefs].
  void _checkVictory() {
    bool win = true;
    for (var row in _board) {
      for (var cell in row) {
        if (!cell.isMine && !cell.isRevealed) {
          win =
              false; // Se interrumpe si existe al menos una casilla segura cubierta
          break;
        }
      }
    }

    if (win) {
      _gameState = GameState.won;
      _timer?.cancel();
      _saveHighScore(); // Invoca la capa de persistencia de datos
    }
  }

  /// Persiste los registros ganadores (Récords de Victoria) bajo la plataforma elegida.
  ///
  /// Recupera el historial serializado de [SharedPreferences], parsea el JSON, anexa el
  /// intento actual, ordena la lista (Prioridad: 1. Tiempo 2. Intentos) y almacena un Top 10.
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

    // Mapea la cadena a un objeto fuertemente tipado
    List<HighScoreRecord> records = currentRecordsJson
        .map((item) => HighScoreRecord.fromJson(item))
        .toList();

    records.add(newRecord);

    // Lógica de ordenamiento para lideres
    records.sort((a, b) {
      int cmp = a.timeInSeconds.compareTo(b.timeInSeconds);
      if (cmp == 0)
        return a.attempts.compareTo(
          b.attempts,
        ); // Desempate por eficiencia (clics)
      return cmp;
    });

    // Filtra la lista para mantener un máximo estricto de las 10 mejores marcas
    if (records.length > 10) {
      records = records.sublist(0, 10);
    }

    // Retorna la data en formato JSON a la unidad persistente local
    List<String> updatedRecordsJson = records.map((r) => r.toJson()).toList();
    await prefs.setStringList(key, updatedRecordsJson);
  }
}
