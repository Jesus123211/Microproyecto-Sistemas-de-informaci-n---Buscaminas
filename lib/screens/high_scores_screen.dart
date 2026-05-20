// lib/screens/high_scores_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  int _easyWins = 0;
  int _mediumWins = 0;
  int _hardWins = 0;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _easyWins = prefs.getInt('victories_easy') ?? 0;
      _mediumWins = prefs.getInt('victories_medium') ?? 0;
      _hardWins = prefs.getInt('victories_hard') ?? 0;
    });
  }

  // Permite borrar el historial de victorias
  Future<void> _resetScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('victories_easy');
    await prefs.remove('victories_medium');
    await prefs.remove('victories_hard');
    _loadScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🏆 MARCADORES',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Borrar historial',
            onPressed: _resetScores,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'VICTORIAS TOTALES',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier New',
              ),
            ),
            const SizedBox(height: 30),
            _buildScoreCard('Nivel Fácil (6x6)', _easyWins, Colors.green),
            _buildScoreCard('Nivel Medio (8x8)', _mediumWins, Colors.orange),
            _buildScoreCard('Nivel Difícil (10x10)', _hardWins, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String level, int wins, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color, width: 2),
      ),
      child: ListTile(
        leading: Icon(Icons.star, color: color, size: 30),
        title: Text(level, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          '$wins',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Courier New',
          ),
        ),
      ),
    );
  }
}
