// lib/models/high_score_model.dart
import 'dart:convert';

class HighScoreRecord {
  final int timeInSeconds;
  final int attempts;
  final String date;

  HighScoreRecord({
    required this.timeInSeconds,
    required this.attempts,
    required this.date,
  });

  // Convierte el objeto a un Mapa para guardarlo en JSON
  Map<String, dynamic> toMap() {
    return {'timeInSeconds': timeInSeconds, 'attempts': attempts, 'date': date};
  }

  // Crea un objeto a partir de un Mapa leído de JSON
  factory HighScoreRecord.fromMap(Map<String, dynamic> map) {
    return HighScoreRecord(
      timeInSeconds: map['timeInSeconds'] ?? 0,
      attempts: map['attempts'] ?? 0,
      date: map['date'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory HighScoreRecord.fromJson(String source) =>
      HighScoreRecord.fromMap(json.decode(source));
}
