import 'package:flutter/material.dart';
import 'main_navigation.dart';
import '../data/player_progress.dart';

class HomeScreen extends StatefulWidget {
  final bool showNavBar;
  final VoidCallback? onNavigateToLevels;

  const HomeScreen({
    super.key,
    this.showNavBar = true,
    this.onNavigateToLevels,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final points = await PlayerProgress.getTotalPoints();
    setState(() {
      totalPoints = points;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF0D2438),
              Color(0xFF102D48),
              Color(0xFF0F2D45),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COSMO&LUNA',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color(0xFF00D9FF),
                                    Color(0xFF00B8D4)
                                  ],
                                ).createShader(
                                    const Rect.fromLTWH(0, 0, 200, 70)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'AVENTURAS',
                            style: TextStyle(
                              color: Color(0xFF6B8A9E),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A52), Color(0xFF152D42)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '⭐',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$totalPoints',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de aventuras
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildAdventureCard(
                      context,
                      title: 'SALVAR A LUNA',
                      subtitle: 'Aventura 1',
                      icon: '💙',
                      color: const Color(0xFFFF6B9D),
                      isLocked: false,
                      progress: (totalPoints / 10000 * 100).toInt(),
                      onTap: () {
                        // Si hay callback, usarlo (navegación fluida)
                        // Si no, usar Navigator (fallback)
                        if (widget.onNavigateToLevels != null) {
                          widget.onNavigateToLevels!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MainNavigation(initialIndex: 1),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildAdventureCard(
                      context,
                      title: 'RESCATE ESPACIAL',
                      subtitle: 'Aventura 2',
                      icon: '🚀',
                      color: const Color(0xFF00D9FF),
                      isLocked: totalPoints < 10000,
                      progress: 0,
                      onTap: () {
                        // Próximamente
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildAdventureCard(
                      context,
                      title: 'GALAXIA PERDIDA',
                      subtitle: 'Aventura 3',
                      icon: '🌌',
                      color: const Color(0xFF9D4EDD),
                      isLocked: true,
                      progress: 0,
                      onTap: () {
                        // Próximamente
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showNavBar ? null : null,
    );
  }

  Widget _buildAdventureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required bool isLocked,
    required int progress,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLocked
                ? [
                    const Color(0xFF1A2332),
                    const Color(0xFF0F1A26),
                  ]
                : [
                    const Color(0xFF1E3A52),
                    const Color(0xFF152D42),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLocked ? const Color(0xFF2A3A4A) : color,
            width: 2.5,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLocked
                            ? [
                                const Color(0xFF2A3A4A),
                                const Color(0xFF1A2332),
                              ]
                            : [
                                color.withOpacity(0.3),
                                color.withOpacity(0.1),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isLocked ? const Color(0xFF3A4A5A) : color,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        isLocked ? '🔒' : icon,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: isLocked
                                ? const Color(0xFF4A5568)
                                : const Color(0xFF6B8A9E),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: TextStyle(
                            color: isLocked
                                ? const Color(0xFF4A5568)
                                : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!isLocked && progress > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progreso: $progress%',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  backgroundColor: const Color(0xFF1A2332),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(color),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        if (isLocked)
                          const Text(
                            'Completa la aventura anterior',
                            style: TextStyle(
                              color: Color(0xFF4A5568),
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de disponible
            if (!isLocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DISPONIBLE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
