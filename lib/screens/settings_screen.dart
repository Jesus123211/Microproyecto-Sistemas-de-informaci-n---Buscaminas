// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';

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
    _loadDifficulty();
  }

  Future<void> _loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () => _selectedDifficulty = prefs.getString('difficulty') ?? 'Fácil',
    );
  }

  Future<void> _saveDifficulty(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', difficulty);
    setState(() => _selectedDifficulty = difficulty);

    if (!mounted) return;
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    if (difficulty == 'Fácil') gameProvider.setDifficulty(Difficulty.easy);
    if (difficulty == 'Medio') gameProvider.setDifficulty(Difficulty.medium);
    if (difficulty == 'Difícil') gameProvider.setDifficulty(Difficulty.hard);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

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
          _buildHeader('OPCIONES VISUALES'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Tema de la App',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier New',
                    ),
                  ),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('Automático'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Claro'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Oscuro'),
                      ),
                    ],
                    onChanged: (val) => settings.setThemeMode(val!),
                  ),
                ),
                SwitchListTile(
                  title: const Text(
                    'Animaciones',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier New',
                    ),
                  ),
                  value: settings.animationsEnabled,
                  onChanged: (val) => settings.setAnimationsEnabled(val),
                ),
                SwitchListTile(
                  title: const Text(
                    'Efectos de Sonido',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier New',
                    ),
                  ),
                  value: settings.soundEnabled,
                  onChanged: (val) => settings.setSoundEnabled(val),
                ),
                ListTile(
                  title: const Text(
                    'Estilo de Números',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier New',
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: settings.numberStyle,
                    items: const [
                      DropdownMenuItem(
                        value: 'Clásico',
                        child: Text('Clásico'),
                      ),
                      DropdownMenuItem(
                        value: 'Colorido',
                        child: Text('Colorido'),
                      ),
                      DropdownMenuItem(value: 'Retro', child: Text('Retro')),
                      DropdownMenuItem(
                        value: 'Minimalista',
                        child: Text('Minimalista'),
                      ),
                    ],
                    onChanged: (val) => settings.setNumberStyle(val!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildHeader('DIFICULTAD DEL TABLERO'),
          Card(
            child: Column(
              children: [
                RadioListTile(
                  title: const Text('Fácil (6x6)'),
                  value: 'Fácil',
                  groupValue: _selectedDifficulty,
                  onChanged: (val) => _saveDifficulty(val!),
                ),
                RadioListTile(
                  title: const Text('Medio (8x8)'),
                  value: 'Medio',
                  groupValue: _selectedDifficulty,
                  onChanged: (val) => _saveDifficulty(val!),
                ),
                RadioListTile(
                  title: const Text('Difícil (10x10)'),
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

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier New',
        ),
      ),
    );
  }
}
