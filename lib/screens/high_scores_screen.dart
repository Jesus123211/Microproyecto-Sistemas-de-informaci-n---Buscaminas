// lib/screens/high_scores_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/high_score_model.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  Map<String, List<HighScoreRecord>> _scoresMap = {
    'easy': [],
    'medium': [],
    'hard': [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllScores();
  }

  Future<void> _loadAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<HighScoreRecord>> freshScores = {};

    for (String diff in ['easy', 'medium', 'hard']) {
      List<String> listJson = prefs.getStringList('high_scores_$diff') ?? [];
      freshScores[diff] = listJson
          .map((item) => HighScoreRecord.fromJson(item))
          .toList();
    }

    setState(() {
      _scoresMap = freshScores;
      _isLoading = false;
    });
  }

  // BOTÓN CON DIÁLOGO DE CONFIRMACIÓN OBLIGATORIO
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'BORRAR TODO',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (accept == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('high_scores_easy');
      await prefs.remove('high_scores_medium');
      await prefs.remove('high_scores_hard');
      _loadAllScores();
    }
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: records.length + 1, // +1 para la cabecera
      itemBuilder: (context, index) {
        if (index == 0) {
          // FILA DE CABECERA DE LA TABLA
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

        final record = records[index - 1];
        final position = index;

        // FORMATO VISUAL CLARO: Filas alternas y decoraciones
        Color rowColor = (position % 2 == 0)
            ? (isDark
                  ? Colors.grey.shade800.withOpacity(0.4)
                  : Colors.grey.shade100)
            : (isDark ? Colors.transparent : Colors.white);

        // Resaltar el primer lugar
        if (position == 1) {
          rowColor = Colors.amber.withOpacity(isDark ? 0.2 : 0.4);
        }

        // Iconos de medallas para el Top 3
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
              posWidget,
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
