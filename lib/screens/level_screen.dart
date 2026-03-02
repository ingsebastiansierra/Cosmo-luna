import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/nebula_game.dart';
import 'galaxy_map.dart';

class LevelScreen extends StatefulWidget {
  final int galaxyId;
  final int levelId;

  const LevelScreen({
    super.key,
    required this.galaxyId,
    required this.levelId,
  });

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late NebulaGame game;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    game = NebulaGame(
      galaxyId: widget.galaxyId,
      levelId: widget.levelId,
      onLevelCompleted: (galaxyId, levelId) {
        // Ir al siguiente nivel
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LevelScreen(
              galaxyId: galaxyId,
              levelId: levelId + 1,
            ),
          ),
        );
      },
    );
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const GalaxyMap()),
      (route) => false,
    );
  }

  void _restartLevel() {
    setState(() {
      _initGame();
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2942),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: const Color(0xFF00D9FF).withAlpha(102), width: 1),
        ),
        title: const Text(
          'Ajustes',
          style: TextStyle(
            color: Color(0xFF00D9FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up, color: Colors.white),
              title:
                  const Text('Sonido', style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF00D9FF),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.white),
              title:
                  const Text('Música', style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: const Color(0xFF00D9FF),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: Color(0xFF00D9FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Juego
          GameWidget(game: game),

          // Barra de navegación inferior - Diseño mejorado
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628).withAlpha(242),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF00D9FF).withAlpha(51),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(128),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuButton(
                    icon: Icons.home,
                    label: 'INICIO',
                    color: const Color(0xFF00D9FF),
                    onTap: _goHome,
                  ),
                  _buildMenuButton(
                    icon: Icons.rocket_launch,
                    label: 'JUGAR',
                    color: const Color(0xFF00D9FF),
                    onTap: _restartLevel,
                  ),
                  _buildMenuButton(
                    icon: Icons.settings,
                    label: 'AJUSTES',
                    color: const Color(0xFF00D9FF),
                    onTap: _showSettings,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
