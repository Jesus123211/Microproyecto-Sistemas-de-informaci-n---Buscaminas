// lib/models/cell_model.dart

class CellModel {
  final int row;
  final int col;
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;

  CellModel({
    required this.row,
    required this.col,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}
