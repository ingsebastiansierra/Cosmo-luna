import 'package:shared_preferences/shared_preferences.dart';

class PlayerProgress {
  static const String _keyCurrentGalaxy = 'current_galaxy';
  static const String _keyCurrentLevel = 'current_level';
  static const String _keyMaxUnlockedLevel = 'max_unlocked_level';
  static const String _keyTotalPoints = 'total_points';
  static const String _keyCurrentLives = 'current_lives';
  static const String _keyLastCheckpoint = 'last_checkpoint';

  // Sistema de vidas y checkpoints
  static const double maxLives = 10.0;
  static const double hintCost = 0.5; // Media vida por pista
  static const double errorCost = 0.2; // 0.2 vidas por error
  static const List<int> checkpoints = [3, 6, 9]; // Niveles de guardado

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
  static Future<void> markLevelCompleted(
      int galaxy, int level, int points) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'level_${galaxy}_$level';
    await prefs.setBool(key, true);

    // Guardar puntos del nivel
    final pointsKey = 'points_${galaxy}_$level';
    await prefs.setInt(pointsKey, points);

    // Actualizar puntos totales
    final totalPoints = prefs.getInt(_keyTotalPoints) ?? 0;
    await prefs.setInt(_keyTotalPoints, totalPoints + points);

    // Verificar si es un checkpoint y actualizar
    if (checkpoints.contains(level)) {
      await prefs.setInt(_keyLastCheckpoint, level);
      // Restaurar vidas al asegurar nivel
      await prefs.setDouble(_keyCurrentLives, maxLives);
    }

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

  // SISTEMA DE VIDAS

  // Obtener vidas actuales
  static Future<double> getCurrentLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyCurrentLives) ?? maxLives;
  }

  // Establecer vidas
  static Future<void> setLives(double lives) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyCurrentLives, lives.clamp(0.0, maxLives));
  }

  // Usar pista (cuesta media vida)
  static Future<bool> useHint() async {
    final currentLives = await getCurrentLives();
    if (currentLives >= hintCost) {
      await setLives(currentLives - hintCost);
      return true;
    }
    return false;
  }

  // Perder una vida por error
  static Future<void> loseLife() async {
    final currentLives = await getCurrentLives();
    await setLives(currentLives - errorCost);
  }

  // Verificar si Cosmo murió (sin vidas)
  static Future<bool> isDead() async {
    final lives = await getCurrentLives();
    return lives <= 0;
  }

  // Obtener último checkpoint
  static Future<int> getLastCheckpoint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastCheckpoint) ?? 1;
  }

  // Regresar al último checkpoint (cuando muere)
  static Future<void> returnToCheckpoint() async {
    final checkpoint = await getLastCheckpoint();
    final prefs = await SharedPreferences.getInstance();

    // Regresar al checkpoint
    await prefs.setInt(_keyMaxUnlockedLevel, checkpoint);
    await saveProgress(1, checkpoint);

    // Restaurar vidas
    await prefs.setDouble(_keyCurrentLives, maxLives);
  }

  // Resetear progreso (para testing)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
