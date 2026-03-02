import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../nebula_game.dart';

class Piece extends PositionComponent with TapCallbacks, DragCallbacks {
  final Color color;
  final int pieceId;
  final NebulaGame game;
  final double pieceSize;
  Vector2 velocity = Vector2.zero();
  Vector2? targetPosition;
  Vector2? originalPosition;
  bool isAnchored = false;
  bool isDragging = false;
  bool isSelected = false; // Nueva propiedad para selección

  Piece({
    required this.color,
    required this.pieceId,
    required Vector2 position,
    required this.game,
    required this.pieceSize,
  }) : super(position: position, size: Vector2.all(pieceSize)) {
    originalPosition = position.clone();
  }

  @override
  void render(Canvas canvas) {
    // Escala si está seleccionada
    final scale = isSelected ? 1.2 : 1.0;
    final radius = (size.x / 2) * scale;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isSelected ? Colors.white : Colors.white.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 5 : 3;

    // Sombra más pronunciada si está seleccionada
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(isSelected ? 150 : 100)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 12 : 8);

    canvas.drawCircle(
      Offset(size.x / 2 + 2, size.y / 2 + 2),
      radius,
      shadowPaint,
    );

    // Brillo exterior muy visible si está seleccionada (PISTA)
    if (isSelected) {
      // Brillo dorado exterior grande
      final outerGlowPaint = Paint()
        ..color = const Color(0xFFFFD700).withAlpha(180)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        radius + 15,
        outerGlowPaint,
      );

      // Segundo brillo blanco más cercano
      final innerGlowPaint = Paint()
        ..color = Colors.white.withAlpha(150)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        radius + 8,
        innerGlowPaint,
      );
    }

    // Círculo de color
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      radius,
      paint,
    );

    // Borde blanco
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      radius,
      borderPaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (targetPosition == null || isDragging || isAnchored) return;

    // Física flotante: atracción suave hacia el objetivo
    Vector2 direction = targetPosition! - position;
    velocity += direction * GameConstants.floatStrength;
    velocity *= GameConstants.spaceFriction;
    position += velocity * dt * 60;

    // Verificar si llegó al destino
    if (direction.length < GameConstants.anchorDistance) {
      position = targetPosition!;
      targetPosition = null; // Limpiar el objetivo
      velocity = Vector2.zero(); // Detener movimiento
      // NO anclar - la pieza queda libre para ser movida de nuevo
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isAnchored) return; // No permitir selección si está anclada

    // Seleccionar esta pieza
    game.selectPiece(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (isAnchored) return; // No permitir arrastre si está anclada

    super.onDragStart(event);
    isDragging = true;
    isSelected = false;
    priority = 100; // Prioridad alta cuando se arrastra
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isAnchored) return; // No permitir movimiento si está anclada

    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (isAnchored) return; // No procesar si está anclada

    super.onDragEnd(event);
    isDragging = false;
    priority = 0;

    // Buscar el slot más cercano usando el centro de la pieza
    final pieceCenter = position + Vector2(size.x / 2, size.y / 2);
    final nearestSlot = game.findNearestSlot(pieceCenter);

    if (nearestSlot != null) {
      // Intentar colocar la pieza en el slot
      game.checkPiecePlacement(this, nearestSlot);
    } else {
      // No hay slot cerca, volver a la posición original con animación
      targetPosition = originalPosition;
      isAnchored = false;
    }
  }

  void _onAnchor() {
    // Efecto de luz al anclar (implementar con partículas)
    // Verificar si el patrón está completo
  }
}
