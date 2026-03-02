import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/nebula_game.dart';
import '../widgets/main_navigation_bar.dart';
import 'main_navigation.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: game),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: -1, // No hay índice seleccionado en el juego
        onRestartGame: () {
          setState(() {
            _initGame();
          });
        },
        onTap: (index) {
          if (index == 0) {
            // INICIO
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigation(initialIndex: 0),
              ),
              (route) => false,
            );
          } else if (index == 1) {
            // NIVELES
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigation(initialIndex: 1),
              ),
              (route) => false,
            );
          } else if (index == 2) {
            // LAB
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigation(initialIndex: 2),
              ),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
