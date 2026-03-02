import 'package:shared_preferences/shared_preferences.dart';

class PlayerProgress {
  static const String _keyCurrentGalaxy = 'current_galaxy';
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyMaxUnlockedLevel = 'max_unlocked_level';
  static const String _keyTotalPoints = 'total_points';

  // Guardar progreso cuando completa un nivel
  static Future<void> saveProgress(int galaxy, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentGalaxy, galaxy);
    await prefs.setInt(_keyCurrentLevel, level);
    
    // Actualizar el nivel máximo desbloqueado
    final currentMax = prefs.getInt(_keyMaxUnlockedLevel) ?? 1;
    if (level > currentMax) {
      await prefs.setInt(_keyMaxUnlockedLevel, level);
    }
  }

  // Cargar progreso
  static Future<Map<String, int>> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'galaxy': prefs.getInt(_keyCurrentGalaxy) ?? 1,
      'level': prefs.getInt(_keyCurrentLevel) ?? 1,
      'maxUnlockedLevel': prefs.getInt(_keyMaxUnlockedLevel) ?? 1,
    };
  }

  // Marcar nivel como completado
  static Future<void> markLevelCompleted(int galaxy, int level, int points) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${galaxy}_$level';
    await prefs.setBool(key, true);
    
    // Guardar puntos del nivel
    final pointsKey = 'points_${galaxy}_$level';
    await prefs.setInt(pointsKey, points);
    
    // Actualizar puntos totales
    final totalPoints = prefs.getInt(_keyTotalPoints) ?? 0;
    await prefs.setInt(_keyTotalPoints, totalPoints + points);
    
    // Desbloquear el siguiente nivel
    await saveProgress(galaxy, level + 1);
  }

  // Verificar si un nivel está completado
  static Future<bool> isLevelCompleted(int galaxy, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${galaxy}_$level';
    return prefs.getBool(key) ?? false;
  }

  // Verificar si un nivel está desbloqueado
  static Future<bool> isLevelUnlocked(int galaxy, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final maxUnlocked = prefs.getInt(_keyMaxUnlockedLevel) ?? 1;
    return level <= maxUnlocked;
  }

  // Obtener puntos de un nivel específico
  static Future<int> getLevelPoints(int galaxy, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final pointsKey = 'points_${galaxy}_$level';
    return prefs.getInt(pointsKey) ?? 0;
  }

  // Obtener puntos totales
  static Future<int> getTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalPoints) ?? 0;
  }

  // Resetear progreso (para testing)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
