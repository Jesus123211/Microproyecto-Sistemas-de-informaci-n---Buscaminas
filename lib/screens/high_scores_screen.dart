// lib/screens/high_scores_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/high_score_model.dart';

/// Pantalla de Clasificación y Mejores Puntuaciones (Líderes).
///
/// Implementada como un [StatefulWidget] debido a que requiere gestionar la carga
/// asíncrona de datos desde el almacenamiento local y actualizar la interfaz
/// reactivamente tras la lectura o el reinicio de los registros.
class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  // Mapa estructurado para agrupar los registros de puntuación por nivel de dificultad
  Map<String, List<HighScoreRecord>> _scoresMap = {
    'easy': [],
    'medium': [],
    'hard': [],
  };

  // Flag de control para manejar la interfaz de carga mientras se leen los SharedPreferences
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Dispara la lectura de persistencia inmediatamente al insertar el widget en el árbol de estados
    _loadAllScores();
  }

  /// Recupera los récords almacenados localmente de forma asíncrona.
  ///
  /// Obtiene las listas serializadas en JSON para cada categoría, las deserializa
  /// mediante el modelo [HighScoreRecord] y actualiza el estado interno de la pantalla.
  Future<void> _loadAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<HighScoreRecord>> freshScores = {};

    // Itera sobre las llaves de dificultad configuradas en el sistema de almacenamiento
    for (String diff in ['easy', 'medium', 'hard']) {
      List<String> listJson = prefs.getStringList('high_scores_$diff') ?? [];
      // Mapeo y conversión de strings formateados en JSON a instancias de objetos en memoria
      freshScores[diff] = listJson
          .map((item) => HighScoreRecord.fromJson(item))
          .toList();
    }

    // Actualiza el árbol visual notificando el fin del flujo asíncrono
    setState(() {
      _scoresMap = freshScores;
      _isLoading = false;
    });
  }

  /// Despliega un diálogo de confirmación obligatorio antes de purgar los datos.
  ///
  /// Garantiza una experiencia de usuario segura evitando la pérdida accidental
  /// de récords locales mediante una alerta bloqueante ([showDialog]).
  Future<void> _confirmResetScores() async {
    bool? accept = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          '¿BORRAR HISTORIAL?',
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: Colors.redAccent,
          ),
        ),
        content: const Text(
          'Esta acción eliminará de forma permanente todas tus marcas en todas las dificultades.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false), // Retorna falso al flujo
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, true), // Retorna verdadero al flujo
            child: const Text(
              'BORRAR TODO',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    // Si el usuario confirmó la acción, purga las llaves asociadas en disco y recarga el estado
    if (accept == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('high_scores_easy');
      await prefs.remove('high_scores_medium');
      await prefs.remove('high_scores_hard');
      _loadAllScores(); // Reestablece la pantalla a su estado vacío
    }
  }

  /// Convierte una cantidad de segundos enteros a un formato clásico de reloj 'MM:SS'.
  ///
  /// Utiliza división entera [~/] para extraer minutos y operador residuo [%] para los segundos.
  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length:
          3, // Tres pestañas correspondientes a las tres dificultades reglamentarias
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '🏆 LIDERES',
            style: GoogleFonts.pressStart2p(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.orange.shade800,
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            // Acción en AppBar para realizar el reset general de puntuaciones
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, size: 28),
              tooltip: 'Reiniciar todo',
              onPressed: _confirmResetScores,
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.amber,
            labelStyle: GoogleFonts.pressStart2p(
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'FÁCIL'),
              Tab(text: 'MEDIO'),
              Tab(text: 'DIFÍCIL'),
            ],
          ),
        ),
        // Renderizado condicional: Muestra spinner si está cargando o el TabBarView con los datos reales
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildScoreTable(_scoresMap['easy']!),
                  _buildScoreTable(_scoresMap['medium']!),
                  _buildScoreTable(_scoresMap['hard']!),
                ],
              ),
      ),
    );
  }

  /// Genera dinámicamente la tabla de posiciones o el estado vacío.
  ///
  /// Recibe un [List<HighScoreRecord>] de la dificultad seleccionada por el Tab.
  Widget _buildScoreTable(List<HighScoreRecord> records) {
    // COMPORTAMIENTO: Si está vacío, muestra el mensaje amigable requerido
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('😭', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              Text(
                'Aún no tienes registros.\n¡Juega tu primera partida!',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  fontSize: 10,
                  height: 1.8,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Lista optimizada con reciclaje de celdas para renderizar la tabla de marcas
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount:
          records.length +
          1, // +1 para inyectar de manera integrada la fila de cabecera
      itemBuilder: (context, index) {
        if (index == 0) {
          // FILA DE CABECERA DE LA TABLA - Define los nombres de las columnas
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    'POS',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'TIEMPO',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: Alignment.center.x == 0
                        ? TextAlign.start
                        : TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'CLICS',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'FECHA',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }

        // Recupera el registro desplazando el índice para compensar la cabecera
        final record = records[index - 1];
        final position = index;

        // FORMATO VISUAL CLARO: Filas alternas y decoraciones cromáticas
        Color rowColor = (position % 2 == 0)
            ? (isDark
                  ? Colors.grey.shade800.withOpacity(0.4)
                  : Colors.grey.shade100)
            : (isDark ? Colors.transparent : Colors.white);

        // Resaltar el primer lugar con una tonalidad ámbar distintiva (Efecto Campeón)
        if (position == 1) {
          rowColor = Colors.amber.withOpacity(isDark ? 0.2 : 0.4);
        }

        // Lógica de asignación de íconos de medallas para el Top 3 de la clasificación
        Widget posWidget;
        if (position == 1) {
          posWidget = const SizedBox(
            width: 40,
            child: Text('🥇', style: TextStyle(fontSize: 18)),
          );
        } else if (position == 2) {
          posWidget = const SizedBox(
            width: 40,
            child: Text('🥈', style: TextStyle(fontSize: 18)),
          );
        } else if (position == 3) {
          posWidget = const SizedBox(
            width: 40,
            child: Text('🥉', style: TextStyle(fontSize: 18)),
          );
        } else {
          // Posición numérica estándar para registros del 4 en adelante
          posWidget = SizedBox(
            width: 40,
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                '#$position',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        // Fila de datos del récord mapeada e impresa con alineación proporcional
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: rowColor,
            border: const Border(
              bottom: BorderSide(color: Colors.black12, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              posWidget, // Componente de podio / posición
              Expanded(
                child: Text(
                  _formatTime(record.timeInSeconds),
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: Alignment.center.x == 0
                      ? TextAlign.start
                      : TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  '${record.attempts}',
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  record.date,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
