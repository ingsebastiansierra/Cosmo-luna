import 'package:flutter/material.dart';
import 'galaxy_map.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GalaxyMap()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF1A1A6E),
              Color(0xFF0A1628),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Estrellas de fondo
            ...List.generate(50, (index) => _buildStar(size)),

            // Contenido principal con scroll
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isTablet ? 40 : 20),

                          // Logo del cohete
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Icon(
                              Icons.rocket_launch,
                              size: isTablet ? 100 : 60,
                              color: Color(0xFF00B4D8),
                            ),
                          ),

                          SizedBox(height: isTablet ? 30 : 15),

                          // Título NEBULA CODE
                          Text(
                            'NEBULA CODE',
                            style: TextStyle(
                              fontSize: isTablet ? 56 : 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF00B4D8).withOpacity(0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),

                          // Línea decorativa
                          Container(
                            width: isTablet ? 250 : 150,
                            height: 4,
                            margin: EdgeInsets.symmetric(
                                vertical: isTablet ? 20 : 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF00B4D8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isTablet ? 30 : 15),

                          // Imagen de Cosmo & Luna
                          Container(
                            width: isTablet ? 400 : 240,
                            height: isTablet ? 300 : 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Color(0xFF00B4D8).withOpacity(0.5),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF00B4D8).withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(27),
                              child: Container(
                                color: Color(0xFF1A1A6E).withOpacity(0.5),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.favorite,
                                        size: isTablet ? 80 : 50,
                                        color: Color(0xFFFFB3C6),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '👨‍🚀 💙 👩‍🚀',
                                        style: TextStyle(
                                            fontSize: isTablet ? 50 : 35),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isTablet ? 25 : 15),

                          // Subtítulo
                          Text(
                            'Cosmo & Luna',
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00B4D8),
                            ),
                          ),

                          SizedBox(height: isTablet ? 12 : 8),

                          Text(
                            'Amor a Través del Tiempo',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),

                          SizedBox(height: isTablet ? 40 : 25),

                          // Botón START GAME
                          GestureDetector(
                            onTap: _startGame,
                            child: Container(
                              width: isTablet ? 350 : 260,
                              height: isTablet ? 70 : 55,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF00B4D8),
                                    Color(0xFF00D4FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF00B4D8).withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'START GAME',
                                    style: TextStyle(
                                      fontSize: isTablet ? 24 : 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0A1628),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.play_arrow,
                                    color: Color(0xFF0A1628),
                                    size: isTablet ? 32 : 24,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: isTablet ? 30 : 20),

                          // Botones OPTIONS y GALLERY
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildBottomButton(
                                icon: Icons.settings,
                                label: 'OPTIONS',
                                isTablet: isTablet,
                              ),
                              SizedBox(width: isTablet ? 40 : 25),
                              _buildBottomButton(
                                icon: Icons.photo_library,
                                label: 'GALLERY',
                                isTablet: isTablet,
                              ),
                            ],
                          ),

                          SizedBox(height: isTablet ? 30 : 20),

                          // Footer
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 30 : 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'V1.0.4-ALPHA',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 10,
                                    color: Colors.white30,
                                  ),
                                ),
                                Text(
                                  '© 2024 NEBULA STUDIOS',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 10,
                                    color: Colors.white30,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isTablet ? 20 : 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(Size size) {
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final left = ((random * 0.7) % size.width).clamp(0.0, size.width - 4);
    final top = ((random * 1.3) % size.height).clamp(0.0, size.height - 4);

    return Positioned(
      left: left.isFinite ? left : 0,
      top: top.isFinite ? top : 0,
      child: Container(
        width: 2,
        height: 2,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3 + (random % 7) / 10),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white60,
          size: isTablet ? 24 : 18,
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 12,
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
