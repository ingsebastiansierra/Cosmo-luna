import 'package:flutter/material.dart';

class MainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final VoidCallback? onRestartGame;

  const MainNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.onRestartGame,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1F2D),
            Color(0xFF0A1628),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'INICIO',
                context: context,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.map_rounded,
                label: 'NIVELES',
                context: context,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.science_rounded,
                label: 'LAB',
                context: context,
              ),
              // Si hay callback de reiniciar, mostrar REINICIAR, sino PERFIL
              onRestartGame != null
                  ? _buildNavItem(
                      index: 3,
                      icon: Icons.refresh_rounded,
                      label: 'REINICIAR',
                      context: context,
                    )
                  : _buildNavItem(
                      index: 3,
                      icon: Icons.person_rounded,
                      label: 'PERFIL',
                      context: context,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 3 && onRestartGame != null) {
          // Si es el botón de reiniciar y hay callback, ejecutarlo
          onRestartGame!();
        } else if (onTap != null) {
          // Si hay callback de navegación, usarlo
          onTap!(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF00D9FF),
                    Color(0xFF00B8D4),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF4A5568),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4A5568),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
