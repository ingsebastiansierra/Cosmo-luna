import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/piece.dart';
import 'components/slot.dart';
import 'components/victory_overlay.dart';
import '../data/player_progress.dart';

class NebulaGame extends FlameGame {
  final int galaxyId;
  final int levelId;
  final Function(int, int)? onLevelCompleted;

  List<Piece> pieces = [];
  List<Slot> slots = [];
  List<Color> patternColors = [];
  bool isPatternVisible = true;
  double patternTimer = 5.0;
  late TextComponent instructionText;
  bool levelCompleted = false;
  bool gameReady = false;
  Piece? selectedPiece; // Pieza actualmente seleccionada

  // Sistema de puntos
  int currentPoints = 450;
  int lunaTimeRemaining = 75;
  int totalPointsAccumulated = 0; // Puntos totales acumulados
  late TextComponent pointsText;
  late TextComponent lunaTimeText;
  late TextComponent totalPointsText;
  final int pointsPerCorrect = 50;
  final int pointsLostOnError = 25;
  final int lunaTimeLostOnError = 10;

  // Meta para liberar a Luna (ajusta según dificultad)
  static const int pointsToFreeLuna = 10000;

  NebulaGame({
    required this.galaxyId,
    required this.levelId,
    this.onLevelCompleted,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Cargar puntos totales acumulados
    totalPointsAccumulated = await PlayerProgress.getTotalPoints();

    // Fondo degradado elegante
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF0D2438),
            Color(0xFF102D48),
            Color(0xFF0F2D45),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 1000, 2000)),
      priority: -10,
    ));

    _buildUI();

    await Future.delayed(const Duration(milliseconds: 300));
    _generatePattern();
  }

  void _buildUI() {
    // Header con diseño moderno y atractivo
    final headerBg = RectangleComponent(
      size: Vector2(size.x, 110),
      position: Vector2.zero(),
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF0D2438),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 1000, 110)),
      priority: 5,
    );
    add(headerBg);

    // Línea decorativa superior
    add(RectangleComponent(
      size: Vector2(size.x, 2),
      position: Vector2(0, 108),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0x0000D9FF),
            Color(0xFF00D9FF),
            Color(0x0000D9FF),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 1000, 2)),
      priority: 6,
    ));

    // Contenedor de puntos - Diseño premium
    final pointsBox = RectangleComponent(
      size: Vector2(150, 65),
      position: Vector2(15, 20),
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A52),
            Color(0xFF152D42),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 150, 65)),
      priority: 6,
    );
    add(pointsBox);

    // Borde brillante del contenedor de puntos
    add(RectangleComponent(
      size: Vector2(150, 65),
      position: Vector2(15, 20),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF00D9FF),
            Color(0xFF0088CC),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 150, 65))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      priority: 7,
    ));

    // Icono de estrella con brillo
    add(TextComponent(
      text: '⭐',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          shadows: [
            Shadow(color: Color(0xFFFFD700), blurRadius: 10),
          ],
        ),
      ),
      position: Vector2(35, 52),
      anchor: Anchor.center,
      priority: 8,
    ));

    add(TextComponent(
      text: 'PUNTOS',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF6B8A9E),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      position: Vector2(100, 38),
      anchor: Anchor.center,
      priority: 8,
    ));

    pointsText = TextComponent(
      text: '450',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Color(0xFFFFD700), blurRadius: 8),
          ],
        ),
      ),
      position: Vector2(100, 62),
      anchor: Anchor.center,
      priority: 8,
    );
    add(pointsText);

    // Contenedor de Luna - Diseño premium
    final lunaBox = RectangleComponent(
      size: Vector2(150, 65),
      position: Vector2(size.x - 165, 20),
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A52),
            Color(0xFF152D42),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 150, 65)),
      priority: 6,
    );
    add(lunaBox);

    add(RectangleComponent(
      size: Vector2(150, 65),
      position: Vector2(size.x - 165, 20),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF6B9D),
            Color(0xFFCC5577),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 150, 65))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      priority: 7,
    ));

    add(TextComponent(
      text: '💗',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          shadows: [
            Shadow(color: Color(0xFFFF6B9D), blurRadius: 10),
          ],
        ),
      ),
      position: Vector2(size.x - 148, 52),
      anchor: Anchor.center,
      priority: 8,
    ));

    add(TextComponent(
      text: 'LUNA',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF6B8A9E),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      position: Vector2(size.x - 85, 38),
      anchor: Anchor.center,
      priority: 8,
    ));

    lunaTimeText = TextComponent(
      text: '75%',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF6B9D),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Color(0xFFFF6B9D), blurRadius: 8),
          ],
        ),
      ),
      position: Vector2(size.x - 85, 62),
      anchor: Anchor.center,
      priority: 8,
    );
    add(lunaTimeText);

    // Barra de progreso para liberar a Luna
    _buildLunaProgressBar();

    // Texto de instrucción con efecto
    instructionText = TextComponent(
      text: 'Memoriza el patrón...',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00D9FF),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Color(0xFF00D9FF), blurRadius: 15),
            Shadow(color: Colors.black, blurRadius: 5),
          ],
        ),
      ),
      position: Vector2(size.x * 0.5, 130),
      anchor: Anchor.center,
      priority: 8,
    );
    add(instructionText);

    add(TextComponent(
      text: '━━━ NEBULA CODE ARENA ━━━',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF3A5A6E),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
      position: Vector2(size.x * 0.5, 152),
      anchor: Anchor.center,
      priority: 8,
    ));
  }

  void _buildLunaProgressBar() {
    // Calcular progreso
    final progress =
        (totalPointsAccumulated / pointsToFreeLuna).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toInt();

    // Contenedor de la barra de progreso en la parte INFERIOR
    final barWidth = size.x - 40;
    const barHeight = 40.0;
    final barX = 20.0;
    final barY = size.y - 60.0; // Parte inferior de la pantalla

    // Fondo de la barra con degradado
    add(RectangleComponent(
      size: Vector2(barWidth, barHeight),
      position: Vector2(barX, barY),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF1A3A52),
            Color(0xFF0D2438),
          ],
        ).createShader(Rect.fromLTWH(0, 0, barWidth, barHeight)),
      priority: 6,
    ));

    // Borde brillante de la barra
    add(RectangleComponent(
      size: Vector2(barWidth, barHeight),
      position: Vector2(barX, barY),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFF6B9D),
            Color(0xFFFFB3C6),
          ],
        ).createShader(Rect.fromLTWH(0, 0, barWidth, barHeight))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      priority: 7,
    ));

    // Barra de progreso con degradado
    if (progress > 0) {
      final progressWidth = (barWidth - 8) * progress;
      add(RectangleComponent(
        size: Vector2(progressWidth, barHeight - 8),
        position: Vector2(barX + 4, barY + 4),
        paint: Paint()
          ..shader = const LinearGradient(
            colors: [
              Color(0xFFFF6B9D),
              Color(0xFFFF8FB3),
              Color(0xFFFFB3C6),
            ],
          ).createShader(Rect.fromLTWH(0, 0, progressWidth, barHeight - 8)),
        priority: 7,
      ));
    }

    // Icono de Luna
    add(TextComponent(
      text: '💙',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          shadows: [
            Shadow(color: Color(0xFFFF6B9D), blurRadius: 10),
          ],
        ),
      ),
      position: Vector2(barX + 12, barY + barHeight / 2),
      anchor: Anchor.centerLeft,
      priority: 8,
    ));

    // Texto de progreso
    totalPointsText = TextComponent(
      text:
          'Liberar a Luna: $totalPointsAccumulated / $pointsToFreeLuna ($progressPercent%)',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 3),
          ],
        ),
      ),
      position: Vector2(barX + barWidth / 2, barY + barHeight / 2),
      anchor: Anchor.center,
      priority: 8,
    );
    add(totalPointsText);
  }

  void _generatePattern() {
    final pieceCount = 3 + levelId;
    patternColors = List.generate(pieceCount, (i) => _getPieceColor(i));

    // Generar posiciones para slots en grid
    final slotPositions = _generateGridPositions(pieceCount);

    for (int i = 0; i < pieceCount; i++) {
      final slot = Slot(
        slotId: i,
        expectedColor: patternColors[i],
        position: slotPositions[i],
      );
      slots.add(slot);
      add(slot);
    }

    // Crear piezas en los slots
    for (int i = 0; i < pieceCount; i++) {
      final slotCenter = slotPositions[i] + Vector2(45, 45);
      final piece = Piece(
        color: patternColors[i],
        pieceId: i,
        position: slotCenter - Vector2(35, 35),
        game: this,
      );
      pieces.add(piece);
      add(piece);
    }

    gameReady = true;
  }

  List<Vector2> _generateGridPositions(int count) {
    final positions = <Vector2>[];

    // Grid de 3 columnas centrado
    const cols = 3;
    const slotSize = 90.0;
    const spacing = 30.0;
    const cellSize = slotSize + spacing;

    const gridWidth = cols * cellSize - spacing;

    final startX = (size.x - gridWidth) / 2;
    final startY = size.y * 0.30;

    for (int i = 0; i < count; i++) {
      final col = i % cols;
      final row = i ~/ cols;

      final x = startX + (col * cellSize);
      final y = startY + (row * cellSize);

      positions.add(Vector2(x, y));
    }

    return positions;
  }

  Color _getPieceColor(int index) {
    const colors = [
      Color(0xFF00D9FF), // Cyan brillante
      Color(0xFFFF6B9D), // Rosa
      Color(0xFF9D4EDD), // Púrpura
      Color(0xFFFFD700), // Dorado
      Color(0xFF00FF88), // Verde
      Color(0xFFFF6B6B), // Rojo coral
    ];
    return colors[index % colors.length];
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!gameReady) return;

    if (isPatternVisible) {
      patternTimer -= dt;

      if (patternTimer <= 0) {
        isPatternVisible = false;
        instructionText.text = '¡Arrastra las piezas!';
        _fragmentPattern();
      } else {
        final secs = (patternTimer + 0.5).toInt().clamp(1, 5);
        instructionText.text = 'Memoriza... ${secs}s';
      }
    }
  }

  void _fragmentPattern() {
    final shuffled = List.generate(pieces.length, (i) => i)..shuffle();

    // Diseño de baraja/abanico de cartas
    const pieceSize = 70.0;
    const overlapSpacing = 45.0; // Las piezas se superponen como cartas

    // Calcular el ancho total de la baraja
    final totalWidth = (pieces.length - 1) * overlapSpacing + pieceSize;

    // Centrar la baraja horizontalmente
    final startX = (size.x - totalWidth) / 2;

    // Posición Y en la parte inferior (arriba de la barra de progreso)
    final yPos = size.y - 180;

    for (int i = 0; i < pieces.length; i++) {
      final piece = pieces[shuffled[i]];

      // Posición X con superposición
      final xPos = startX + (i * overlapSpacing);

      // Asegurar que esté dentro de los límites
      final safeX = xPos.clamp(pieceSize / 2 + 10, size.x - pieceSize / 2 - 10);
      final safeY =
          yPos.clamp(pieceSize / 2 + 10, size.y - pieceSize / 2 - 120);

      piece.position = Vector2(safeX, safeY);
      piece.originalPosition = Vector2(safeX, safeY);
      piece.targetPosition = null;
      piece.isAnchored = false;

      // Prioridad para que las piezas de la derecha estén encima
      piece.priority = i;
    }
  }

  Slot? findNearestSlot(Vector2 position) {
    Slot? nearest;
    double minDistance = double.infinity;

    for (var slot in slots) {
      if (slot.isFilled) continue;

      final slotCenter = slot.position + Vector2(45, 45);
      final distance = (slotCenter - position).length;

      if (distance < 120 && distance < minDistance) {
        minDistance = distance;
        nearest = slot;
      }
    }

    return nearest;
  }

  // Seleccionar una pieza (modo naipe)
  void selectPiece(Piece piece) {
    if (isPatternVisible || piece.isAnchored) return;

    // Deseleccionar la pieza anterior
    if (selectedPiece != null) {
      selectedPiece!.isSelected = false;
    }

    // Seleccionar la nueva pieza
    selectedPiece = piece;
    piece.isSelected = true;
    piece.priority = 100; // Traer al frente
  }

  // Colocar pieza seleccionada en un slot (llamado desde Slot)
  void placeSelectedPieceInSlot(Slot slot) {
    if (selectedPiece == null || slot.isFilled) return;

    checkPiecePlacement(selectedPiece!, slot);

    // Deseleccionar después de colocar
    selectedPiece!.isSelected = false;
    selectedPiece = null;
  }

  void checkPiecePlacement(Piece piece, Slot slot) {
    // Verificar si el color es correcto
    if (piece.color.toARGB32() == slot.expectedColor.toARGB32()) {
      // ¡Correcto! Colocar la pieza en el slot
      slot.isFilled = true;
      slot.isCorrect = true;

      // Centrar la pieza en el slot
      final slotCenter = slot.position + Vector2(45, 45);
      piece.position = slotCenter - Vector2(35, 35);
      piece.targetPosition = null;
      piece.isAnchored = true;
      piece.originalPosition = piece.position.clone();

      currentPoints += pointsPerCorrect;
      pointsText.text = '$currentPoints';

      // Verificar si todos los slots están completos
      if (slots.every((s) => s.isCorrect)) {
        Future.delayed(const Duration(milliseconds: 500), onLevelComplete);
      }
    } else {
      // Incorrecto - la pieza vuelve a su posición original
      _handleIncorrectPlacement(piece);
    }
  }

  void _handleIncorrectPlacement(Piece piece) {
    // Penalización
    if (currentPoints >= pointsLostOnError) {
      currentPoints -= pointsLostOnError;
      pointsText.text = '$currentPoints';
    } else {
      lunaTimeRemaining =
          (lunaTimeRemaining - lunaTimeLostOnError).clamp(0, 100);
      _updateLunaTimeDisplay();

      if (lunaTimeRemaining <= 0) {
        instructionText.text = '💔 GAME OVER';
        Future.delayed(const Duration(seconds: 3), onLevelFail);
        return;
      }
    }

    // La pieza vuelve a su posición original
    piece.targetPosition = piece.originalPosition;
    piece.isAnchored = false;
  }

  void _updateLunaTimeDisplay() {
    lunaTimeText.text = '$lunaTimeRemaining%';
  }

  void onLevelComplete() {
    if (levelCompleted) return;
    levelCompleted = true;

    instructionText.text = '¡COMPLETADO! 🎉';

    PlayerProgress.markLevelCompleted(galaxyId, levelId, currentPoints);

    // Calcular nuevos puntos totales
    final newTotalPoints = totalPointsAccumulated + currentPoints;
    final progress = (newTotalPoints / pointsToFreeLuna).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toInt();

    final victoryOverlay = VictoryOverlay(
      size: size,
      pointsEarned: currentPoints,
      totalPoints: newTotalPoints,
      pointsToFreeLuna: pointsToFreeLuna,
      progressPercent: progressPercent,
      onNextLevel: () {
        if (onLevelCompleted != null) {
          onLevelCompleted!(galaxyId, levelId);
        }
      },
    );
    add(victoryOverlay);
  }

  void onLevelFail() {
    // Manejar fallo del nivel
  }
}
