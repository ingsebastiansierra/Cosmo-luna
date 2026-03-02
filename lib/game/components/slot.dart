import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../nebula_game.dart';

class Slot extends PositionComponent with TapCallbacks {
  final int slotId;
  final Color expectedColor;
  final double slotSize;
  bool isFilled = false;
  bool isCorrect = false;
  bool isActive = false;

  double pulseTimer = 0.0;
  double pulseScale = 1.0;

  Slot({
    required this.slotId,
    required this.expectedColor,
    required Vector2 position,
    required this.slotSize,
  }) : super(position: position, size: Vector2.all(slotSize));

  @override
  void onTapDown(TapDownEvent event) {
    // Cuando se toca un slot, intentar colocar la pieza seleccionada
    if (parent is NebulaGame) {
      final game = parent as NebulaGame;
      game.placeSelectedPieceInSlot(this);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Animación de pulsación suave
    if (!isCorrect) {
      pulseTimer += dt * 2;
      pulseScale = 1.0 + (math.sin(pulseTimer) * 0.03);
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = (size.x / 2 - 6) * pulseScale;

    if (isCorrect) {
      // Slot completado - Círculo sólido con el color
      final fillPaint = Paint()
        ..color = expectedColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, fillPaint);

      // Borde blanco brillante
      final borderPaint = Paint()
        ..color = Colors.white.withAlpha(220)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, radius, borderPaint);

      // Checkmark elegante
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final checkPath = Path()
        ..moveTo(size.x * 0.35, size.y * 0.5)
        ..lineTo(size.x * 0.45, size.y * 0.6)
        ..lineTo(size.x * 0.65, size.y * 0.4);

      canvas.drawPath(checkPath, checkPaint);
    } else if (isActive) {
      // Slot activo - Fondo oscuro con borde brillante
      final bgPaint = Paint()
        ..color = const Color(0xFF0D2B3E).withAlpha(180)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, bgPaint);

      final activeBorderPaint = Paint()
        ..color = const Color(0xFF00D9FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;

      canvas.drawCircle(center, radius, activeBorderPaint);

      // Brillo cyan suave
      final glowPaint = Paint()
        ..color = const Color(0xFF00D9FF).withAlpha(60)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12);

      canvas.drawCircle(center, radius + 6, glowPaint);

      _drawNumber(canvas, center);
    } else {
      // Slot normal - Fondo oscuro con borde punteado
      final bgPaint = Paint()
        ..color = const Color(0xFF0D2B3E).withAlpha(120)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, bgPaint);

      _drawDashedCircle(
        canvas,
        center,
        radius,
        const Color(0xFF2A5266),
        2.5,
        dashWidth: 8,
        dashSpace: 6,
      );

      _drawNumber(canvas, center);
    }
  }

  void _drawNumber(Canvas canvas, Offset center) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${slotId + 1}',
        style: TextStyle(
          color: isActive ? const Color(0xFF00D9FF) : const Color(0xFF4A6B7C),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
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
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double strokeWidth, {
    double dashWidth = 10,
    double dashSpace = 5,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const pi = 3.14159265359;
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final actualDashWidth = dashWidth / radius;
    final actualDashSpace = dashSpace / radius;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (actualDashWidth + actualDashSpace);
      final sweepAngle = actualDashWidth;

      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
        );

      canvas.drawPath(path, paint);
    }
  }

  bool isNearby(Vector2 position) {
    final slotCenter = this.position + Vector2(slotSize / 2, slotSize / 2);
    final distance = (slotCenter - position).length;
    return distance < (slotSize * 1.1);
  }
}
