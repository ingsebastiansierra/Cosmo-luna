import 'package:flutter/material.dart';
import 'level_screen.dart';
import '../data/player_progress.dart';

class GalaxyMap extends StatefulWidget {
  const GalaxyMap({super.key});

  @override
  State<GalaxyMap> createState() => _GalaxyMapState();
}

class _GalaxyMapState extends State<GalaxyMap> {
  int maxUnlockedLevel = 1;
  int totalPoints = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await PlayerProgress.loadProgress();
    final points = await PlayerProgress.getTotalPoints();
    setState(() {
      maxUnlockedLevel = progress['maxUnlockedLevel'] ?? 1;
      totalPoints = points;
    });
  }

  String _getLevelTitle(int levelNumber) {
    const titles = [
      'Binary Basics',
      'Logic Gates',
      'Signal Routing',
      'Data Packets',
      'Kernel Panic',
      'Quantum Encryption',
      'Neural Networks',
      'Cache Memory',
      'Stack Overflow',
      'Heap Sort',
      'Binary Trees',
      'Hash Tables',
      'Graph Theory',
      'Dynamic Programming',
      'Recursion Depth',
      'Parallel Processing',
      'Thread Safety',
      'Memory Leaks',
      'Race Conditions',
      'Deadlock Detection',
    ];
    return titles[levelNumber - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Color(0xFF00D9FF)),
          onPressed: () {},
        ),
        title: Text(
          'NEBULA CODE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF1A2942),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFFFD700), width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                SizedBox(width: 6),
                Text(
                  '$totalPoints pts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'GALAXY MAP • SECTOR 01',
              style: TextStyle(
                color: Color(0xFF00D9FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProgress,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: 20,
                itemBuilder: (context, index) {
                  final levelNumber = index + 1;
                  final isUnlocked = levelNumber <= maxUnlockedLevel;
                  final isActive = levelNumber == maxUnlockedLevel;

                  return FutureBuilder<bool>(
                    future: PlayerProgress.isLevelCompleted(1, levelNumber),
                    builder: (context, snapshot) {
                      final isCompleted = snapshot.data ?? false;

                      return LevelCard(
                        levelNumber: levelNumber,
                        levelTitle: _getLevelTitle(levelNumber),
                        isLocked: !isUnlocked,
                        isCompleted: isCompleted,
                        isActive: isActive,
                        onTap: isUnlocked
                            ? () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LevelScreen(
                                      galaxyId: 1,
                                      levelId: levelNumber,
                                    ),
                                  ),
                                );
                                _loadProgress();
                              }
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Color(0xFF0A1628),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF00D9FF),
        unselectedItemColor: Color(0xFF4A5568),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'MAP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch),
            label: 'SHIPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'LAB',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  final int levelNumber;
  final String levelTitle;
  final bool isLocked;
  final bool isCompleted;
  final bool isActive;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.levelNumber,
    required this.levelTitle,
    required this.isLocked,
    required this.isCompleted,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1A2942),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Color(0xFF00D9FF) : Colors.transparent,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Color(0xFF00D9FF).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono del nivel
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Color(0xFF00FF88)
                        : isLocked
                            ? Color(0xFF2D3748)
                            : Color(0xFF00D9FF),
                  ),
                  child: Center(
                    child: isLocked
                        ? Icon(Icons.lock, color: Color(0xFF4A5568), size: 24)
                        : isCompleted
                            ? Icon(Icons.check,
                                color: Color(0xFF0A1628), size: 28)
                            : isActive
                                ? Icon(Icons.rocket_launch,
                                    color: Color(0xFF0A1628), size: 28)
                                : Text(
                                    '${levelNumber.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Color(0xFF0A1628),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                  ),
                ),
                SizedBox(width: 16),
                // Información del nivel
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${levelNumber.toString().padLeft(2, '0')}: $levelTitle',
                        style: TextStyle(
                          color: isLocked ? Color(0xFF4A5568) : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isCompleted
                            ? 'SCORE: 250 PTS'
                            : isActive
                                ? 'ACTIVE LEVEL • 500 XP'
                                : isLocked
                                    ? 'LOCKED'
                                    : 'READY TO PLAY',
                        style: TextStyle(
                          color: isCompleted
                              ? Color(0xFF00FF88)
                              : isActive
                                  ? Color(0xFF00D9FF)
                                  : isLocked
                                      ? Color(0xFF4A5568)
                                      : Color(0xFF718096),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón de acción
                if (isActive)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2D3748),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                else if (isCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF00FF88).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PASSED',
                      style: TextStyle(
                        color: Color(0xFF00FF88),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
