import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum CosmoState { idle, celebrate, cry, thinking, faint }

class CosmoCharacter extends PositionComponent {
  CosmoState currentState = CosmoState.idle;
  String? currentBubble;
  double bubbleTimer = 0;

  CosmoCharacter({required Vector2 position})
      : super(position: position, size: Vector2(80, 100));

  @override
  void render(Canvas canvas) {
    // Placeholder: dibujar COSMO como círculo con cara
    final paint = Paint()..color = Color(0xFFFFB3C6);
    
    // Cuerpo
    canvas.drawCircle(Offset(40, 50), 35, paint);
    
    // Ojos
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(30, 45), 5, eyePaint);
    canvas.drawCircle(Offset(50, 45), 5, eyePaint);
    
    // Boca según estado
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    if (currentState == CosmoState.celebrate) {
      canvas.drawArc(
        Rect.fromLTWH(25, 50, 30, 15),
        0,
        3.14,
        false,
        mouthPaint,
      );
    } else if (currentState == CosmoState.cry) {
      canvas.drawArc(
        Rect.fromLTWH(25, 60, 30, 15),
        3.14,
        3.14,
        false,
        mouthPaint,
      );
    }

    // Dibujar burbuja de diálogo si existe
    if (currentBubble != null && bubbleTimer > 0) {
      _drawBubble(canvas);
    }
  }

  void _drawBubble(Canvas canvas) {
    if (currentBubble == null) return;
    
    // Sombra de la burbuja
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(94, 24, 320, 80),
        Radius.circular(12),
      ),
      shadowPaint,
    );
    
    // Burbuja principal
    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = Color(0xFF00B4D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(90, 20, 320, 80),
      Radius.circular(12),
    );
    
    canvas.drawRRect(bubbleRect, bubblePaint);
    canvas.drawRRect(bubbleRect, borderPaint);
    
    // Pico de la burbuja (triángulo)
    final trianglePath = Path()
      ..moveTo(90, 60)
      ..lineTo(70, 70)
      ..lineTo(90, 80)
      ..close();
    
    canvas.drawPath(trianglePath, bubblePaint);
    canvas.drawPath(trianglePath, borderPaint);

    // Texto de la burbuja
    final textPainter = TextPainter(
      text: TextSpan(
        text: currentBubble,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 4,
      textAlign: TextAlign.left,
    );
    textPainter.layout(maxWidth: 300);
    textPainter.paint(canvas, Offset(100, 30));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (bubbleTimer > 0) {
      bubbleTimer -= dt;
    }
  }

  void onLevelComplete() {
    currentState = CosmoState.celebrate;
    showBubble('¡SABÍA que podías! Yo también lo habría... eventualmente');
  }

  void onLevelFail() {
    currentState = CosmoState.cry;
    showBubble('Yo destruí 3 planetas antes de aprender esto.');
  }

  void onAdRequest() {
    currentState = CosmoState.thinking;
    showBubble('Necesito fondos para mi cohete. ¿30 segundos?');
  }

  void showBubble(String text, {double duration = 3.0}) {
    currentBubble = text;
    bubbleTimer = duration;
  }
}
