// lib/models/high_score_model.dart
import 'dart:convert';

/// Modelo de Datos para los Registros de Puntuación (High Scores).
///
/// Define la estructura de los récords alcanzados por el jugador en el Buscaminas.
/// Incluye los métodos de serialización y deserialización necesarios para facilitar
/// el almacenamiento persistente local en formato JSON a través de `shared_preferences`.
class HighScoreRecord {
  /// Tiempo total empleado para resolver el tablero de forma exitosa, expresado en segundos.
  final int timeInSeconds;

  /// Cantidad de clics o interacciones totales realizadas durante la partida.
  final int attempts;

  /// Cadena de texto representativa de la fecha en la que se estableció el récord.
  final String date;

  /// Constructor principal que exige la inicialización estricta de todas las propiedades.
  HighScoreRecord({
    required this.timeInSeconds,
    required this.attempts,
    required this.date,
  });

  // Convierte el objeto a un Mapa para guardarlo en JSON
  ///
  /// Transforma las propiedades de la instancia actual en una estructura de clave-valor
  /// (`Map<String, dynamic>`), la cual es requerida para la correcta codificación estándar.
  Map<String, dynamic> toMap() {
    return {'timeInSeconds': timeInSeconds, 'attempts': attempts, 'date': date};
  }

  // Crea un objeto a partir de un Mapa leído de JSON
  ///
  /// Patrón [Factory] para instanciar un [HighScoreRecord] a partir de datos mapeados.
  /// Implementa validación de seguridad contra nulos (`??`) asignando valores neutros
  /// por defecto, previniendo caídas del sistema en caso de lectura de data corrupta.
  factory HighScoreRecord.fromMap(Map<String, dynamic> map) {
    return HighScoreRecord(
      timeInSeconds: map['timeInSeconds'] ?? 0,
      attempts: map['attempts'] ?? 0,
      date: map['date'] ?? '',
    );
  }

  /// Serializa la instancia directamente a un String codificado en formato JSON.
  String toJson() => json.encode(toMap());

  /// Deserializa un String de origen JSON e invoca al constructor factory para retornar el objeto.
  factory HighScoreRecord.fromJson(String source) =>
      HighScoreRecord.fromMap(json.decode(source));
}
