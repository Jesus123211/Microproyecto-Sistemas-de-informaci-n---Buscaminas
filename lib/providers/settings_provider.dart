// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor de Estado para las Configuraciones Globales de la Aplicación.
///
/// Utiliza el patrón [ChangeNotifier] para notificar de manera reactiva a los widgets
/// dependientes sobre cambios en las preferencias del usuario. Además, encapsula la
/// persistencia local utilizando el paquete de almacenamiento [SharedPreferences].
class SettingsProvider extends ChangeNotifier {
  // Propiedades de estado internas y sus valores iniciales por defecto
  ThemeMode _themeMode = ThemeMode.system;
  bool _soundEnabled = true;
  bool _animationsEnabled = true;
  String _numberStyle =
      'Clásico'; // Opciones válidas: Clásico, Colorido, Retro, Minimalista

  // Getters públicos para exponer el estado actual de forma segura sin permitir mutaciones directas
  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  bool get animationsEnabled => _animationsEnabled;
  String get numberStyle => _numberStyle;

  /// Hidrata el estado del proveedor leyendo los datos guardados en el disco local.
  ///
  /// Se ejecuta normalmente durante el arranque de la aplicación. Si una configuración
  /// no existe en memoria persistente, se asigna el valor por defecto a través del operador `??`.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Recupera el índice entero correspondiente al ThemeMode (0=system, 1=light, 2=dark)
    int themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    // Recupera las banderas booleanas de efectos de sonido y animaciones visuales
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _animationsEnabled = prefs.getBool('animationsEnabled') ?? true;

    // Recupera la cadena de texto con el estilo de fuente/color de la numeración
    _numberStyle = prefs.getString('numberStyle') ?? 'Clásico';

    // Despierta el flujo de renderizado en todos los componentes escuchando este Provider
    notifyListeners();
  }

  /// Actualiza de manera síncrona el tema visual de la aplicación y lo persiste en disco.
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'themeMode',
      mode.index,
    ); // Guarda el índice del enumerador
    notifyListeners(); // Dispara el rediseño para reflejar el cambio de tema de inmediato
  }

  /// Activa o desactiva la reproducción de sonidos del sistema y persiste la preferencia.
  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    notifyListeners();
  }

  /// Habilita o deshabilita las transiciones y animaciones visuales en los componentes del juego.
  Future<void> setAnimationsEnabled(bool value) async {
    _animationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('animationsEnabled', value);
    notifyListeners();
  }

  /// Configura el tema estético para los números indicadores de minas adyacentes y lo persiste.
  Future<void> setNumberStyle(String style) async {
    _numberStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('numberStyle', style);
    notifyListeners(); // Propaga el nuevo estilo estético al GridView en pantalla
  }
}
