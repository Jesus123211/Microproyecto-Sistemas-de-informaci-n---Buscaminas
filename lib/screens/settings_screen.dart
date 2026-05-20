// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';

/// Pantalla de Configuración del juego Buscaminas.
///
/// Permite al usuario personalizar las opciones visuales (tema, animaciones,
/// efectos de sonido y estilo de números) [cite: 38, 40, 41, 42, 43] así como la dificultad del
/// tablero (Fácil, Medio, Difícil)[cite: 33]. Utiliza [SharedPreferences] para
/// la persistencia local de la dificultad[cite: 37, 51].
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Almacena la dificultad seleccionada actualmente en la interfaz.
  String _selectedDifficulty = 'Fácil';

  @override
  void initState() {
    super.initState();
    _loadDifficulty(); // Carga la configuración guardada al iniciar la pantalla.
  }

  /// Carga de manera asíncrona la dificultad almacenada en las preferencias locales.
  /// Si no existe un registro previo, se establece 'Fácil' por defecto[cite: 147].
  Future<void> _loadDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () => _selectedDifficulty = prefs.getString('difficulty') ?? 'Fácil',
    );
  }

  /// Guarda de manera asíncrona la nueva dificultad seleccionada.
  ///
  /// [difficulty] Cadena de texto que representa el nivel ('Fácil', 'Medio', 'Difícil').
  /// Además de persistir el dato, actualiza el estado del [GameProvider] para
  /// redimensionar el tablero de juego en consecuencia[cite: 83].
  Future<void> _saveDifficulty(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', difficulty);
    setState(() => _selectedDifficulty = difficulty);

    // Verifica si el widget sigue montado en el árbol antes de usar el BuildContext asíncrono
    if (!mounted) return;

    // Obtiene la instancia de GameProvider sin suscribirse a cambios de estado (listen: false)
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Vincula la selección de la interfaz con las enumeraciones lógicas de dificultad [cite: 34, 35, 36]
    if (difficulty == 'Fácil') gameProvider.setDifficulty(Difficulty.easy);
    if (difficulty == 'Medio') gameProvider.setDifficulty(Difficulty.medium);
    if (difficulty == 'Difícil') gameProvider.setDifficulty(Difficulty.hard);
  }

  @override
  Widget build(BuildContext context) {
    // Escucha activamente los cambios de estado en SettingsProvider para refrescar los temas y estilos [cite: 48, 112]
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚙ CONFIGURACIÓN',
          style: TextStyle(
            fontFamily:
                'Courier New', // Estilo tipográfico Retro/Retro-futurista [cite: 29]
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
                // Control del Tema de la Aplicación (Claro, Oscuro, Automático) [cite: 40]
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
                // Switch para habilitar/deshabilitar animaciones en la UI [cite: 42]
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
                // Switch para gestionar el estado de los efectos de sonido [cite: 41]
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
                // Selector del diseño de renderizado para los números de las casillas [cite: 43]
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
                      ), // Colores estándar (1=Azul, 2=Verde...) [cite: 44]
                      DropdownMenuItem(
                        value: 'Colorido',
                        child: Text('Colorido'),
                      ), // Paleta vibrante moderna [cite: 45]
                      DropdownMenuItem(
                        value: 'Retro',
                        child: Text('Retro'),
                      ), // Estilo pixel limitado [cite: 46]
                      DropdownMenuItem(
                        value: 'Minimalista',
                        child: Text('Minimalista'),
                      ), // Diseño limpio monocromático [cite: 47]
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
                // Opción Fácil: Configura la cuadrícula a 6x6 con 10 minas [cite: 34]
                RadioListTile(
                  title: const Text('Fácil (6x6)'),
                  value: 'Fácil',
                  groupValue: _selectedDifficulty,
                  onChanged: (val) => _saveDifficulty(val!),
                ),
                // Opción Medio: Configura la cuadrícula a 8x8 con 20 minas [cite: 35]
                RadioListTile(
                  title: const Text('Medio (8x8)'),
                  value: 'Medio',
                  groupValue: _selectedDifficulty,
                  onChanged: (val) => _saveDifficulty(val!),
                ),
                // Opción Difícil: Configura la cuadrícula a 10x10 con 30 minas [cite: 36]
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

  /// Construye un encabezado de sección estilizado con la fuente del sistema.
  ///
  /// [title] Texto descriptivo que se mostrará sobre la sección.
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
