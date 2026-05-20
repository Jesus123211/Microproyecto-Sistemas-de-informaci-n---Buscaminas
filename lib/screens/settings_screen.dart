// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedDifficulty = 'Fácil';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Carga la configuración guardada al abrir la pantalla
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDifficulty = prefs.getString('difficulty') ?? 'Fácil';
    });
  }

  // Guarda la nueva configuración y actualiza el Provider global
  Future<void> _saveDifficulty(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', difficulty);

    setState(() {
      _selectedDifficulty = difficulty;
    });

    if (!mounted) return;

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (difficulty == 'Fácil') gameProvider.setDifficulty(Difficulty.easy);
    if (difficulty == 'Medio') gameProvider.setDifficulty(Difficulty.medium);
    if (difficulty == 'Difícil') gameProvider.setDifficulty(Difficulty.hard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚙ CONFIGURACIÓN',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.amber,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'DIFICULTAD DEL TABLERO',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier New',
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text(
                    'Fácil (6x6, 10 minas)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: 'Fácil',
                  groupValue: _selectedDifficulty,
                  onChanged: (val) => _saveDifficulty(val!),
                ),
                RadioListTile<String>(
                  title: const Text(
                    'Medio (8x8, 20 minas)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: 'Medio',
                  groupValue: _selectedDifficulty,
                  onChanged: (val) => _saveDifficulty(val!),
                ),
                RadioListTile<String>(
                  title: const Text(
                    'Difícil (10x10, 30 minas)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: 'Difícil',
                  groupValue: _selectedDifficulty,
                  onChanged: (val) => _saveDifficulty(val!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
