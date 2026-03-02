import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HintButton extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  double pulseTimer = 0.0;
  double pulseScale = 1.0;

  HintButton({
    required this.onTap,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(60),
          anchor: Anchor.center,
          priority: 150,
        );

  @override
  void update(double dt) {
    super.update(dt);
    // Animación de pulsación
    pulseTimer += dt * 3;
    pulseScale = 1.0 + (math.sin(pulseTimer) * 0.15);
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = (size.x / 2) * pulseScale;

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(
      Offset(center.dx + 2, center.dy + 2),
      radius,
      shadowPaint,
    );

    // Fondo del botón con degradado
    final rect = Rect.fromCircle(center: center, radius: radius);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFD700),
          Color(0xFFFFA500),
        ],
      ).createShader(rect);

    canvas.drawCircle(center, radius, bgPaint);

    // Borde brillante
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, borderPaint);

    // Icono de bombillo
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '💡',
        style: TextStyle(fontSize: 30),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Brillo pulsante
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3 * pulseScale)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, radius + 5, glowPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
