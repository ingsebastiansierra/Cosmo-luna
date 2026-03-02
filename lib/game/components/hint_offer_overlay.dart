import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../nebula_game.dart';

class HintOfferOverlay extends PositionComponent with TapCallbacks {
  final NebulaGame game;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int hintCost;

  _HintButtonComponent? acceptButton;
  _HintButtonComponent? declineButton;

  HintOfferOverlay({
    required this.game,
    required this.onAccept,
    required this.onDecline,
    required this.hintCost,
  }) : super(priority: 200);

  @override
  Future<void> onLoad() async {
    size = game.size;

    // Fondo semi-transparente más sutil
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.5),
      priority: 1,
    ));

    // Contenedor del mensaje - centrado horizontalmente, más abajo verticalmente
    final boxWidth = 240.0;
    final boxHeight = 160.0;
    final boxX = (size.x - boxWidth) / 2; // Centrado horizontalmente
    final boxY = (size.y - boxHeight) / 2 +
        80; // Centrado verticalmente + 80px más abajo

    // Fondo del cuadro con degradado
    add(_HintBoxComponent(
      size: Vector2(boxWidth, boxHeight),
      position: Vector2(boxX, boxY),
      priority: 2,
    ));

    // Icono de bombilla
    add(TextComponent(
      text: '💡',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 26,
        ),
      ),
      position: Vector2(boxX + boxWidth / 2, boxY + 25),
      anchor: Anchor.center,
      priority: 3,
    ));

    // Título
    add(TextComponent(
      text: '¿Necesitas una pista?',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00D9FF),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(boxX + boxWidth / 2, boxY + 55),
      anchor: Anchor.center,
      priority: 3,
    ));

    // Mensaje de costo
    add(TextComponent(
      text: 'Costo: 0.5 vidas 💗',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF6B9D),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      position: Vector2(boxX + boxWidth / 2, boxY + 78),
      anchor: Anchor.center,
      priority: 3,
    ));

    // Botones - posicionados desde la esquina superior izquierda (sin anchor center)
    final buttonY = boxY + 110;
    final button1X = boxX + 35; // Margen de 35px desde el borde izquierdo
    final button2X = boxX + 145; // Segundo botón más a la derecha

    // Botón ACEPTAR
    acceptButton = _HintButtonComponent(
      size: Vector2(80, 35),
      position: Vector2(button1X, buttonY),
      text: 'SÍ',
      color: const Color(0xFF00D9FF),
      onTap: onAccept,
      priority: 3,
      useAnchor: false, // Sin anchor center
    );
    add(acceptButton!);

    // Botón RECHAZAR
    declineButton = _HintButtonComponent(
      size: Vector2(80, 35),
      position: Vector2(button2X, buttonY),
      text: 'NO',
      color: const Color(0xFFFF6B9D),
      onTap: onDecline,
      priority: 3,
      useAnchor: false, // Sin anchor center
    );
    add(declineButton!);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final tapPosition = event.localPosition;
    acceptButton?.handleTap(tapPosition);
    declineButton?.handleTap(tapPosition);
  }
}

// Componente del cuadro de fondo
class _HintBoxComponent extends PositionComponent {
  _HintBoxComponent({
    required Vector2 size,
    required Vector2 position,
    required int priority,
  }) : super(size: size, position: position, priority: priority);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Fondo con degradado
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E3A52),
          Color(0xFF152D42),
          Color(0xFF0D2438),
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, bgPaint);

    // Borde brillante
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00D9FF),
          Color(0xFF00B8D4),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(rrect, borderPaint);
  }
}

// Componente de botón
class _HintButtonComponent extends PositionComponent {
  final String text;
  final Color color;
  final VoidCallback onTap;
  bool isPressed = false;

  _HintButtonComponent({
    required Vector2 size,
    required Vector2 position,
    required this.text,
    required this.color,
    required this.onTap,
    required int priority,
    bool useAnchor = true,
  }) : super(
          size: size,
          position: position,
          priority: priority,
          anchor: useAnchor ? Anchor.center : Anchor.topLeft,
        );

  @override
  void render(Canvas canvas) {
    // Dibujar desde la esquina superior izquierda
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    // Fondo del botón
    final bgPaint = Paint()
      ..color = isPressed ? color.withValues(alpha: 0.8) : color;

    canvas.drawRRect(rrect, bgPaint);

    // Texto del botón centrado
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Verificar si el punto está dentro del rectángulo del botón
    return point.x >= 0 &&
        point.x <= size.x &&
        point.y >= 0 &&
        point.y <= size.y;
  }

  void handleTap(Vector2 point) {
    // Convertir el punto global a local relativo a este componente
    final localPoint = Vector2(
      point.x - position.x,
      point.y - position.y,
    );

    if (containsLocalPoint(localPoint)) {
      onTap();
    }
  }
}
