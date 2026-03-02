import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class VictoryOverlay extends PositionComponent with TapCallbacks {
  final VoidCallback onNextLevel;
  final int pointsEarned;
  final int totalPoints;
  final int pointsToFreeLuna;
  final int progressPercent;
  double animationTimer = 0;
  double modalScale = 0.0;
  final Random random = Random();
  List<Confetti> confettiList = [];

  VictoryOverlay({
    required Vector2 size,
    required this.onNextLevel,
    this.pointsEarned = 0,
    this.totalPoints = 0,
    this.pointsToFreeLuna = 10000,
    this.progressPercent = 0,
  }) : super(size: size, position: Vector2.zero(), priority: 100);

  @override
  Future<void> onLoad() async {
    // Generar confeti
    for (int i = 0; i < 40; i++) {
      confettiList.add(Confetti(
        position: Vector2(
          random.nextDouble() * size.x,
          -random.nextDouble() * 300,
        ),
        velocity: Vector2(
          random.nextDouble() * 100 - 50,
          random.nextDouble() * 150 + 100,
        ),
        color: _randomColor(),
        rotation: random.nextDouble() * 6.28,
        rotationSpeed: random.nextDouble() * 8 - 4,
      ));
    }
  }

  Color _randomColor() {
    const colors = [
      Color(0xFFFFD700),
      Color(0xFF00FF88),
      Color(0xFF00D9FF),
      Color(0xFFFF6B9D),
      Color(0xFF9D4EDD),
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void update(double dt) {
    super.update(dt);
    animationTimer += dt;

    // Animación de entrada del modal más rápida y simple
    if (modalScale < 1.0) {
      modalScale = min(1.0, modalScale + dt * 5.0); // Más rápido
    }

    // Actualizar confeti (menos frecuente para mejor rendimiento)
    for (var confetti in confettiList) {
      confetti.position += confetti.velocity * dt;
      confetti.velocity.y += 180 * dt; // Gravedad
      confetti.rotation += confetti.rotationSpeed * dt;

      if (confetti.position.y > size.y + 50) {
        confetti.position = Vector2(
          random.nextDouble() * size.x,
          -50,
        );
        confetti.velocity = Vector2(
          random.nextDouble() * 100 - 50,
          random.nextDouble() * 150 + 100,
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Fondo oscuro semi-transparente
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.75);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    // Dibujar confeti
    for (var confetti in confettiList) {
      canvas.save();
      canvas.translate(confetti.position.x, confetti.position.y);
      canvas.rotate(confetti.rotation);

      final confettiPaint = Paint()..color = confetti.color;
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 6, height: 10),
        confettiPaint,
      );

      canvas.restore();
    }

    // Calcular tamaño del modal MÁS GRANDE
    final modalWidth = (size.x * 0.90).clamp(300.0, 500.0);
    final modalHeight = (size.y * 0.65).clamp(400.0, 600.0);
    final modalX = (size.x - modalWidth) / 2;
    final modalY = (size.y - modalHeight) / 2;

    // Aplicar escala de animación
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(modalScale);
    canvas.translate(-size.x / 2, -size.y / 2);

    // Sombra del modal
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            modalX - 5, modalY - 5, modalWidth + 10, modalHeight + 10),
        const Radius.circular(25),
      ),
      shadowPaint,
    );

    // Fondo del modal con degradado
    final modalPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A3A52),
          Color(0xFF0D2438),
          Color(0xFF0A1628),
        ],
      ).createShader(Rect.fromLTWH(modalX, modalY, modalWidth, modalHeight));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(modalX, modalY, modalWidth, modalHeight),
        const Radius.circular(20),
      ),
      modalPaint,
    );

    // Borde del modal con gradiente
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00D9FF),
          Color(0xFF00FF88),
        ],
      ).createShader(Rect.fromLTWH(modalX, modalY, modalWidth, modalHeight))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(modalX, modalY, modalWidth, modalHeight),
        const Radius.circular(20),
      ),
      borderPaint,
    );

    // Icono de éxito MÁS GRANDE
    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '🎉',
        style: TextStyle(fontSize: 80),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        modalX + modalWidth / 2 - iconPainter.width / 2,
        modalY + modalHeight * 0.10,
      ),
    );

    // Título MÁS GRANDE
    final titleSize = (modalWidth * 0.10).clamp(24.0, 38.0);
    final titlePainter = TextPainter(
      text: TextSpan(
        text: '¡NIVEL COMPLETADO!',
        style: TextStyle(
          color: const Color(0xFF00FF88),
          fontSize: titleSize,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Color(0xFF00FF88), blurRadius: 15),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(
        modalX + modalWidth / 2 - titlePainter.width / 2,
        modalY + modalHeight * 0.28,
      ),
    );

    // Mensaje MÁS GRANDE
    final messageSize = (modalWidth * 0.050).clamp(16.0, 22.0);
    final messagePainter = TextPainter(
      text: TextSpan(
        text: '¡Excelente trabajo!\n💙 Luna está más cerca',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: messageSize,
          height: 1.6,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    messagePainter.layout();
    messagePainter.paint(
      canvas,
      Offset(
        modalX + modalWidth / 2 - messagePainter.width / 2,
        modalY + modalHeight * 0.42,
      ),
    );

    // Puntos ganados MÁS GRANDE
    final pointsSize = (modalWidth * 0.060).clamp(18.0, 26.0);
    final pointsPainter = TextPainter(
      text: TextSpan(
        text: '⭐ +$pointsEarned puntos',
        style: TextStyle(
          color: const Color(0xFFFFD700),
          fontSize: pointsSize,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Color(0xFFFFD700), blurRadius: 10),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pointsPainter.layout();
    pointsPainter.paint(
      canvas,
      Offset(
        modalX + modalWidth / 2 - pointsPainter.width / 2,
        modalY + modalHeight * 0.56,
      ),
    );

    // Progreso total para liberar a Luna
    final progressSize = (modalWidth * 0.038).clamp(12.0, 16.0);
    final progressTextPainter = TextPainter(
      text: TextSpan(
        text: 'Progreso total: $totalPoints / $pointsToFreeLuna',
        style: TextStyle(
          color: const Color(0xFFFFB3C6),
          fontSize: progressSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    progressTextPainter.layout();
    progressTextPainter.paint(
      canvas,
      Offset(
        modalX + modalWidth / 2 - progressTextPainter.width / 2,
        modalY + modalHeight * 0.66,
      ),
    );

    // Barra de progreso mini
    final miniBarWidth = modalWidth * 0.7;
    const miniBarHeight = 8.0;
    final miniBarX = modalX + (modalWidth - miniBarWidth) / 2;
    final miniBarY = modalY + modalHeight * 0.70;

    // Fondo de la barra
    final barBgPaint = Paint()..color = const Color(0xFF0D2438);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(miniBarX, miniBarY, miniBarWidth, miniBarHeight),
        const Radius.circular(4),
      ),
      barBgPaint,
    );

    // Progreso de la barra
    final progressBarWidth = miniBarWidth * (progressPercent / 100);
    final barProgressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF6B9D),
          Color(0xFFFFB3C6),
        ],
      ).createShader(
          Rect.fromLTWH(miniBarX, miniBarY, progressBarWidth, miniBarHeight));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(miniBarX, miniBarY, progressBarWidth, miniBarHeight),
        const Radius.circular(4),
      ),
      barProgressPaint,
    );

    // Botón MÁS GRANDE con animación de pulso
    final buttonPulse = 1.0 + sin(animationTimer * 4) * 0.04;
    final buttonWidth = (modalWidth * 0.80 * buttonPulse).clamp(240.0, 380.0);
    final buttonHeight = (modalHeight * 0.14 * buttonPulse).clamp(55.0, 75.0);
    final buttonX = modalX + (modalWidth - buttonWidth) / 2;
    final buttonY = modalY + modalHeight * 0.76;

    // Sombra del botón
    final buttonShadowPaint = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            buttonX - 5, buttonY - 5, buttonWidth + 10, buttonHeight + 10),
        const Radius.circular(35),
      ),
      buttonShadowPaint,
    );

    // Botón con degradado
    final buttonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00FF88),
          Color(0xFF00D9FF),
        ],
      ).createShader(
          Rect.fromLTWH(buttonX, buttonY, buttonWidth, buttonHeight));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(buttonX, buttonY, buttonWidth, buttonHeight),
        const Radius.circular(30),
      ),
      buttonPaint,
    );

    // Texto del botón MÁS GRANDE
    final buttonTextSize = (buttonHeight * 0.38).clamp(18.0, 24.0);
    final buttonTextPainter = TextPainter(
      text: TextSpan(
        text: 'SIGUIENTE NIVEL →',
        style: TextStyle(
          color: Colors.white,
          fontSize: buttonTextSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 3),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    buttonTextPainter.layout();
    buttonTextPainter.paint(
      canvas,
      Offset(
        buttonX + buttonWidth / 2 - buttonTextPainter.width / 2,
        buttonY + buttonHeight / 2 - buttonTextPainter.height / 2,
      ),
    );

    canvas.restore();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (modalScale < 0.9) return; // Esperar a que termine la animación

    // Calcular posición del botón
    final modalWidth = (size.x * 0.90).clamp(300.0, 500.0);
    final modalHeight = (size.y * 0.65).clamp(400.0, 600.0);
    final modalX = (size.x - modalWidth) / 2;
    final modalY = (size.y - modalHeight) / 2;

    final buttonWidth = (modalWidth * 0.80).clamp(240.0, 380.0);
    final buttonHeight = (modalHeight * 0.14).clamp(55.0, 75.0);
    final buttonX = modalX + (modalWidth - buttonWidth) / 2;
    final buttonY = modalY + modalHeight * 0.76;

    final tapPos = event.localPosition;

    if (tapPos.x >= buttonX &&
        tapPos.x <= buttonX + buttonWidth &&
        tapPos.y >= buttonY &&
        tapPos.y <= buttonY + buttonHeight) {
      onNextLevel();
    }
  }
}

class Confetti {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double rotation;
  double rotationSpeed;

  Confetti({
    required this.position,
    required this.velocity,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });
}
