// lib/models/cell_model.dart

/// Modelo de Datos que representa una celda individual en el tablero del Buscaminas.
///
/// Encapsula tanto las coordenadas espaciales de la casilla dentro de la matriz
/// bidimensional, como sus variables de estado lógico (si contiene una mina, si
/// ha sido descubierta por el usuario o si tiene una bandera encima).
class CellModel {
  /// Índice de la fila en la que se posiciona la celda dentro de la grilla (coordenada Y).
  final int row;

  /// Índice de la columna en la que se posiciona la celda dentro de la grilla (coordenada X).
  final int col;

  /// Indica si la casilla alberga una mina oculta.
  bool isMine;

  /// Define si el jugador ya descubrió la celda de forma que su contenido sea visible.
  bool isRevealed;

  /// Determina si la casilla ha sido señalada preventivamente con una bandera de peligro.
  bool isFlagged;

  /// Contador entero que registra la cantidad de minas presentes en los 8 vecinos colindantes.
  int adjacentMines;

  /// Constructor de la clase [CellModel].
  ///
  /// Requiere obligatoriamente las coordenadas posicionales [row] y [col].
  /// Por defecto, inicializa las banderas de estado en `false` y el contador
  /// de minas adyacentes en `0`, facilitando la generación limpia del tablero.
  CellModel({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}
