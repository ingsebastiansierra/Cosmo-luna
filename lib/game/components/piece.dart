import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../nebula_game.dart';

class Piece extends PositionComponent with TapCallbacks, DragCallbacks {
  final Color color;
  final int pieceId;
  final NebulaGame game;
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
  }) : super(position: position, size: Vector2.all(70)) {
    originalPosition = position.clone();
  }

  @override
  void render(Canvas canvas) {
    // Escala si está seleccionada
    final scale = isSelected ? 1.15 : 1.0;
    final radius = (size.x / 2) * scale;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isSelected ? Colors.white : Colors.white.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 4 : 3;

    // Sombra más pronunciada si está seleccionada
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(isSelected ? 150 : 100)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 12 : 8);

    canvas.drawCircle(
      Offset(size.x / 2 + 2, size.y / 2 + 2),
      radius,
      shadowPaint,
    );

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

    // Indicador de selección (brillo)
    if (isSelected) {
      final glowPaint = Paint()
        ..color = Colors.white.withAlpha(100)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        radius + 5,
        glowPaint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isAnchored || targetPosition == null || isDragging) return;

    // Física flotante: atracción suave hacia el objetivo
    Vector2 direction = targetPosition! - position;
    velocity += direction * GameConstants.floatStrength;
    velocity *= GameConstants.spaceFriction;
    position += velocity * dt * 60;

    // Verificar si llegó al destino
    if (direction.length < GameConstants.anchorDistance) {
      position = targetPosition!;
      isAnchored = true;
      _onAnchor();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isAnchored) return;

    // Seleccionar esta pieza
    game.selectPiece(this);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    isDragging = true;
    isAnchored = false;
    isSelected = false;
    priority = 100; // Prioridad alta cuando se arrastra
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
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
