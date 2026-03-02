import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/piece.dart';
import 'components/slot.dart';
import 'components/victory_overlay.dart';
import 'components/hint_offer_overlay.dart';
import 'components/hint_button.dart';
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

  // Sistema de puntos y vidas
  int currentPoints = 450;
  double currentLives = 10.0; // Vidas de Cosmo
  int totalPointsAccumulated = 0; // Puntos totales acumulados
  late TextComponent pointsText;
  late TextComponent livesText;
  late TextComponent totalPointsText;
  final int pointsPerCorrect = 50;

  // Sistema de pistas
  bool showingHintButton = false;
  bool showingHintOffer = false;
  Piece? lastFailedPiece; // Última pieza que falló
  HintButton? currentHintButton; // Botón flotante actual

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

    // Cargar puntos totales y vidas actuales
    totalPointsAccumulated = await PlayerProgress.getTotalPoints();
    currentLives = await PlayerProgress.getCurrentLives();

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
    // Header más bajo y con diseño moderno
    const headerHeight = 135.0; // Más alto para incluir la barra de progreso
    const headerTopMargin = 40.0; // Bajado más

    // Fondo del header con degradado suave
    final headerBg = RectangleComponent(
      size: Vector2(size.x - 30, headerHeight),
      position: Vector2(15, headerTopMargin),
      paint: Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2838),
            Color(0xFF1A3A52),
            Color(0xFF0D2438),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 1000, headerHeight)),
      priority: 5,
    );
    add(headerBg);

    // Borde brillante del header con radius
    add(_createRoundedBorder(
      size: Vector2(size.x - 30, headerHeight),
      position: Vector2(15, headerTopMargin),
      colors: [Color(0xFF00D9FF), Color(0xFF0088CC)],
      strokeWidth: 2.5,
      radius: 20,
      priority: 6,
    ));

    // Contenedor de puntos con border radius (más pequeño para dar espacio)
    const boxWidth = 110.0;
    const boxHeight = 70.0;
    const boxY = headerTopMargin + 15;

    add(_createRoundedBox(
      size: Vector2(boxWidth, boxHeight),
      position: Vector2(30, boxY),
      gradientColors: [Color(0xFF1E3A52), Color(0xFF152D42)],
      borderColors: [Color(0xFF00D9FF), Color(0xFF00B8D4)],
      radius: 16,
      priority: 7,
    ));

    // Icono de estrella centrado arriba
    add(TextComponent(
      text: '⭐',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          shadows: [
            Shadow(color: Color(0xFFFFD700), blurRadius: 12),
          ],
        ),
      ),
      position: Vector2(30 + boxWidth / 2 - 25, boxY + 20),
      anchor: Anchor.center,
      priority: 9,
    ));

    add(TextComponent(
      text: 'PUNTOS',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF6B8A9E),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(30 + boxWidth / 2 + 10, boxY + 20),
      anchor: Anchor.center,
      priority: 9,
    ));

    pointsText = TextComponent(
      text: '450',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Color(0xFFFFD700), blurRadius: 10),
          ],
        ),
      ),
      position: Vector2(30 + boxWidth / 2, boxY + 48),
      anchor: Anchor.center,
      priority: 9,
    );
    add(pointsText);

    // NÚMERO DE NIVEL - CENTRADO ENTRE LOS DOS CUADROS
    add(TextComponent(
      text: 'Nº$levelId',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00D9FF),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          shadows: [
            Shadow(color: Color(0xFF00D9FF), blurRadius: 15),
            Shadow(color: Colors.black, blurRadius: 5),
          ],
        ),
      ),
      position: Vector2(size.x / 2, boxY + boxHeight / 2),
      anchor: Anchor.center,
      priority: 9,
    ));

    // BARRA DE PROGRESO DE LUNA EN EL CENTRO DEL HEADER
    _buildLunaProgressBar(headerTopMargin, boxY, boxWidth);

    // Contenedor de Vidas de Cosmo con border radius
    add(_createRoundedBox(
      size: Vector2(boxWidth, boxHeight),
      position: Vector2(size.x - boxWidth - 30, boxY),
      gradientColors: [Color(0xFF1E3A52), Color(0xFF152D42)],
      borderColors: [Color(0xFFFF6B9D), Color(0xFFFF8FB3)],
      radius: 16,
      priority: 7,
    ));

    // Icono de corazón centrado arriba
    add(TextComponent(
      text: '💗',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          shadows: [
            Shadow(color: Color(0xFFFF6B9D), blurRadius: 12),
          ],
        ),
      ),
      position: Vector2(size.x - boxWidth - 30 + boxWidth / 2 - 20, boxY + 20),
      anchor: Anchor.center,
      priority: 9,
    ));

    add(TextComponent(
      text: 'VIDAS',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF6B8A9E),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
      position: Vector2(size.x - boxWidth - 30 + boxWidth / 2 + 10, boxY + 20),
      anchor: Anchor.center,
      priority: 9,
    ));

    livesText = TextComponent(
      text: currentLives.toStringAsFixed(1),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFF6B9D),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Color(0xFFFF6B9D), blurRadius: 10),
          ],
        ),
      ),
      position: Vector2(size.x - boxWidth - 30 + boxWidth / 2, boxY + 48),
      anchor: Anchor.center,
      priority: 9,
    );
    add(livesText);

    // Texto de instrucción con diseño mejorado
    const instructionY = headerTopMargin + headerHeight + 25;

    instructionText = TextComponent(
      text: 'Memoriza el patrón...',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00D9FF),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Color(0xFF00D9FF), blurRadius: 15),
            Shadow(color: Colors.black, blurRadius: 5),
          ],
        ),
      ),
      position: Vector2(size.x * 0.5, instructionY),
      anchor: Anchor.center,
      priority: 8,
    );
    add(instructionText);

    // Línea decorativa debajo del texto
    add(RectangleComponent(
      size: Vector2(120, 2),
      position: Vector2(size.x * 0.5 - 60, instructionY + 18),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0x0000D9FF),
            Color(0xFF00D9FF),
            Color(0x0000D9FF),
          ],
        ).createShader(Rect.fromLTWH(0, 0, 120, 2)),
      priority: 8,
    ));
  }

  // Helper para crear cajas redondeadas con degradado
  PositionComponent _createRoundedBox({
    required Vector2 size,
    required Vector2 position,
    required List<Color> gradientColors,
    required List<Color> borderColors,
    required double radius,
    required int priority,
  }) {
    return _RoundedBoxComponent(
      size: size,
      position: position,
      gradientColors: gradientColors,
      borderColors: borderColors,
      radius: radius,
      priority: priority,
    );
  }

  // Helper para crear bordes redondeados
  PositionComponent _createRoundedBorder({
    required Vector2 size,
    required Vector2 position,
    required List<Color> colors,
    required double strokeWidth,
    required double radius,
    required int priority,
  }) {
    return _RoundedBorderComponent(
      size: size,
      position: position,
      colors: colors,
      strokeWidth: strokeWidth,
      radius: radius,
      priority: priority,
    );
  }

  void _buildLunaProgressBar(
      double headerTopMargin, double boxY, double boxWidth) {
    // Calcular progreso
    final progress =
        (totalPointsAccumulated / pointsToFreeLuna).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toInt();

    // Barra ABAJO de los recuadros, ocupando todo el ancho del header
    final barWidth = size.x - 60; // Ancho completo con márgenes
    const barHeight = 35.0;
    const barX = 30.0;
    final barY = boxY + 80; // Debajo de los recuadros

    // Componente de barra con border radius - PRIORIDAD ALTA
    add(_LunaProgressBarComponent(
      size: Vector2(barWidth, barHeight),
      position: Vector2(barX, barY),
      progress: progress,
      totalPoints: totalPointsAccumulated,
      targetPoints: pointsToFreeLuna,
      progressPercent: progressPercent,
      priority: 10,
    ));

    // Icono de Luna
    add(TextComponent(
      text: '💙',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          shadows: [
            Shadow(color: Color(0xFFFF6B9D), blurRadius: 12),
          ],
        ),
      ),
      position: Vector2(barX + 12, barY + barHeight / 2),
      anchor: Anchor.centerLeft,
      priority: 12,
    ));

    // Texto de progreso
    totalPointsText = TextComponent(
      text:
          'Liberar a Luna: $totalPointsAccumulated / $pointsToFreeLuna ($progressPercent%)',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      ),
      position: Vector2(barX + barWidth / 2, barY + barHeight / 2),
      anchor: Anchor.center,
      priority: 12,
    );
    add(totalPointsText);
  }

  void _generatePattern() {
    final pieceCount = 3 + levelId;
    patternColors = List.generate(pieceCount, (i) => _getPieceColor(i));

    // Calcular tamaño dinámico basado en la cantidad de piezas
    final slotSize = _calculateSlotSize(pieceCount);
    final pieceSize =
        slotSize * 0.78; // Las piezas son un poco más pequeñas que los slots

    // Generar posiciones para slots en grid
    final slotPositions = _generateGridPositions(pieceCount, slotSize);

    for (int i = 0; i < pieceCount; i++) {
      final slot = Slot(
        slotId: i,
        expectedColor: patternColors[i],
        position: slotPositions[i],
        slotSize: slotSize,
      );
      slots.add(slot);
      add(slot);
    }

    // Crear piezas en los slots
    for (int i = 0; i < pieceCount; i++) {
      final slotCenter = slotPositions[i] + Vector2(slotSize / 2, slotSize / 2);
      final piece = Piece(
        color: patternColors[i],
        pieceId: i,
        position: slotCenter - Vector2(pieceSize / 2, pieceSize / 2),
        game: this,
        pieceSize: pieceSize,
      );
      pieces.add(piece);
      add(piece);
    }

    gameReady = true;
  }

  // Calcular tamaño de slot basado en cantidad de piezas
  double _calculateSlotSize(int count) {
    if (count <= 4) return 90.0;
    if (count <= 6) return 80.0;
    if (count <= 9) return 70.0;
    if (count <= 12) return 60.0;
    return 55.0; // Para más de 12 piezas
  }

  List<Vector2> _generateGridPositions(int count, double slotSize) {
    final positions = <Vector2>[];

    // Determinar número de columnas según cantidad de piezas
    // Más piezas = más columnas para aprovechar el espacio horizontal
    int cols;
    if (count <= 6) {
      cols = 3; // 3 columnas para 6 o menos piezas
    } else if (count <= 12) {
      cols = 4; // 4 columnas para 7-12 piezas
    } else {
      cols = 5; // 5 columnas para más de 12 piezas
    }

    const spacing = 20.0; // Espaciado reducido para aprovechar más espacio
    final cellSize = slotSize + spacing;

    final gridWidth = cols * cellSize - spacing;

    final startX = (size.x - gridWidth) / 2;
    final startY = size.y * 0.35; // Más abajo para dar espacio al header

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
      Color(0xFFFF9500), // Naranja
      Color(0xFF00E5FF), // Azul claro
      Color(0xFFFF1493), // Rosa fuerte
      Color(0xFF7FFF00), // Verde lima
      Color(0xFFFF69B4), // Rosa claro
      Color(0xFF00CED1), // Turquesa
    ];

    // Si hay más piezas que colores, usar módulo
    // Pero mezclar para evitar patrones repetitivos
    if (index < colors.length) {
      return colors[index];
    } else {
      return colors[index % colors.length];
    }
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

    // Calcular tamaño de pieza dinámicamente
    final pieceSize = pieces.first.size.x;

    // Organización en filas - aumenta 1 pieza por fila cada nivel después del nivel 3
    // Nivel 1-3: 6 piezas por fila
    // Nivel 4: 7 piezas por fila
    // Nivel 5+: 8 piezas por fila (máximo)
    final maxPiecesPerRow = (6 + (levelId > 3 ? levelId - 3 : 0)).clamp(6, 8);
    const overlapSpacing =
        0.75; // Factor de superposición aumentado (75% del tamaño para más espacio)

    // Calcular cuántas filas necesitamos
    final totalRows = (pieces.length / maxPiecesPerRow).ceil();

    // Posición Y base fija en la parte inferior
    const baseY = 580.0; // Posición ajustada
    const rowSpacing = 15.0; // Espacio entre filas

    for (int i = 0; i < pieces.length; i++) {
      final piece = pieces[shuffled[i]];

      // Determinar en qué fila está esta pieza
      final row = i ~/ maxPiecesPerRow;
      final posInRow = i % maxPiecesPerRow;
      final piecesInThisRow = (i ~/ maxPiecesPerRow == totalRows - 1)
          ? pieces.length % maxPiecesPerRow == 0
              ? maxPiecesPerRow
              : pieces.length % maxPiecesPerRow
          : maxPiecesPerRow;

      // Calcular el ancho total de esta fila
      final rowWidth =
          (piecesInThisRow - 1) * (pieceSize * overlapSpacing) + pieceSize;

      // Centrar la fila horizontalmente
      final rowStartX = (size.x - rowWidth) / 2;

      // Posición X con superposición
      final xPos = rowStartX + (posInRow * pieceSize * overlapSpacing);

      // Posición Y según la fila - INVERTIDO: las filas adicionales van ABAJO
      final yPos = baseY + (row * (pieceSize * 0.7 + rowSpacing));

      // Asegurar que esté dentro de los límites
      final safeX = xPos.clamp(pieceSize / 2 + 10, size.x - pieceSize / 2 - 10);
      final safeY = yPos.clamp(pieceSize / 2 + 10, size.y - pieceSize / 2 - 10);

      piece.position = Vector2(safeX, safeY);
      piece.originalPosition = Vector2(safeX, safeY);
      piece.targetPosition = null;
      piece.isAnchored = false;

      // Prioridad INVERTIDA: piezas de la IZQUIERDA están encima para facilitar selección
      // Esto permite que todas las piezas sean clickeables
      piece.priority = (row * maxPiecesPerRow) + (maxPiecesPerRow - posInRow);
    }
  }

  Slot? findNearestSlot(Vector2 position) {
    Slot? nearest;
    double minDistance = double.infinity;

    for (var slot in slots) {
      if (slot.isFilled) continue;

      final slotCenter =
          slot.position + Vector2(slot.slotSize / 2, slot.slotSize / 2);
      final distance = (slotCenter - position).length;

      // Distancia de detección basada en el tamaño del slot
      final detectionRadius = slot.slotSize * 1.3;

      if (distance < detectionRadius && distance < minDistance) {
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

      // Activar animación de brillo de acierto
      slot.isGlowing = true;
      slot.glowTimer = 0.0;

      // Centrar la pieza en el slot usando tamaños dinámicos
      final slotCenter =
          slot.position + Vector2(slot.slotSize / 2, slot.slotSize / 2);
      piece.position = slotCenter - Vector2(piece.size.x / 2, piece.size.y / 2);
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

  void _handleIncorrectPlacement(Piece piece) async {
    // Guardar la pieza que falló
    lastFailedPiece = piece;

    // Perder una vida
    await PlayerProgress.loseLife();
    currentLives = await PlayerProgress.getCurrentLives();
    _updateLivesDisplay();

    // Verificar si Cosmo murió
    if (await PlayerProgress.isDead()) {
      instructionText.text = '💔 COSMO HA MUERTO';
      Future.delayed(const Duration(seconds: 2), () async {
        await PlayerProgress.returnToCheckpoint();
        onGameOver();
      });
      return;
    }

    // La pieza vuelve a su posición original con animación
    piece.targetPosition = piece.originalPosition;
    piece.isAnchored = false;

    // Mostrar botón flotante de pista si tiene suficientes vidas
    if (currentLives >= PlayerProgress.hintCost &&
        !showingHintButton &&
        !isPatternVisible) {
      _showHintButton();
    }
  }

  void _updateLivesDisplay() {
    livesText.text = currentLives.toStringAsFixed(1);
  }

  void onGameOver() {
    // Regresar al mapa de galaxias
    if (onLevelCompleted != null) {
      onLevelCompleted!(-1, -1); // Señal especial para regresar al mapa
    }
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

  // Mostrar botón flotante de pista
  void _showHintButton() {
    showingHintButton = true;

    // Posición del botón: esquina inferior derecha, arriba del menú
    final buttonPosition = Vector2(size.x - 50, size.y - 150);

    currentHintButton = HintButton(
      position: buttonPosition,
      onTap: () {
        _onHintButtonTapped();
      },
    );

    add(currentHintButton!);

    // Auto-ocultar después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      _hideHintButton();
    });
  }

  // Ocultar botón flotante
  void _hideHintButton() {
    if (currentHintButton != null) {
      currentHintButton!.removeFromParent();
      currentHintButton = null;
      showingHintButton = false;
    }
  }

  // Cuando se toca el botón flotante, mostrar el modal
  void _onHintButtonTapped() {
    _hideHintButton();
    _showHintOffer();
  }

  // Mostrar oferta de pista (modal)
  void _showHintOffer() {
    showingHintOffer = true;

    final hintOverlay = HintOfferOverlay(
      game: this,
      hintCost: PlayerProgress.hintCost.toInt(), // Mostrar como "0.5 vidas"
      onAccept: () {
        _acceptHint();
      },
      onDecline: () {
        _declineHint();
      },
    );

    add(hintOverlay);
  }

  // Aceptar la pista
  void _acceptHint() async {
    if (lastFailedPiece == null) {
      showingHintOffer = false;
      return;
    }

    // Usar pista (cuesta media vida)
    final success = await PlayerProgress.useHint();
    if (!success) {
      showingHintOffer = false;
      return;
    }

    // Actualizar vidas en pantalla
    currentLives = await PlayerProgress.getCurrentLives();
    _updateLivesDisplay();

    // Encontrar el slot correcto para la pieza
    Slot? correctSlot;
    for (var slot in slots) {
      if (!slot.isFilled &&
          slot.expectedColor.toARGB32() == lastFailedPiece!.color.toARGB32()) {
        correctSlot = slot;
        break;
      }
    }

    // Mostrar pista visual
    if (correctSlot != null) {
      _showHintAnimation(correctSlot);
    }

    showingHintOffer = false;

    // Remover el overlay
    children.whereType<HintOfferOverlay>().forEach((overlay) {
      overlay.removeFromParent();
    });
  }

  // Rechazar la pista
  void _declineHint() {
    showingHintOffer = false;
    lastFailedPiece = null;

    // Remover el overlay
    children.whereType<HintOfferOverlay>().forEach((overlay) {
      overlay.removeFromParent();
    });
  }

  // Mostrar animación de pista
  void _showHintAnimation(Slot slot) {
    // Activar el slot temporalmente para que brille
    slot.isActive = true;

    // Usar la pieza que falló (lastFailedPiece) en lugar de buscar cualquiera
    Piece? hintPiece = lastFailedPiece;

    // Verificar que la pieza aún existe y no está anclada
    if (hintPiece != null && !hintPiece.isAnchored) {
      // Asegurar que la pieza esté en un estado limpio y seleccionable
      hintPiece.targetPosition =
          null; // Cancelar cualquier animación de retorno
      hintPiece.velocity = Vector2.zero(); // Detener cualquier movimiento
      hintPiece.isDragging = false; // No está siendo arrastrada

      // Hacer brillar la pieza y traerla al frente
      hintPiece.isSelected = true;
      hintPiece.priority = 200; // Traer al frente
    } else {
      // Si por alguna razón no tenemos la pieza, buscar una del mismo color
      for (var piece in pieces) {
        if (!piece.isAnchored &&
            piece.color.toARGB32() == slot.expectedColor.toARGB32()) {
          hintPiece = piece;

          // Asegurar que la pieza esté en un estado limpio
          hintPiece.targetPosition = null;
          hintPiece.velocity = Vector2.zero();
          hintPiece.isDragging = false;

          hintPiece.isSelected = true;
          hintPiece.priority = 200;
          break;
        }
      }
    }

    // Desactivar después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      slot.isActive = false;
      if (hintPiece != null) {
        hintPiece.isSelected = false;
        // La pieza queda con prioridad alta y completamente funcional
        // Sin targetPosition ni animaciones que bloqueen la interacción
      }
    });
  }
}

// Componente helper para cajas redondeadas con degradado
class _RoundedBoxComponent extends PositionComponent {
  final List<Color> gradientColors;
  final List<Color> borderColors;
  final double radius;

  _RoundedBoxComponent({
    required Vector2 size,
    required Vector2 position,
    required this.gradientColors,
    required this.borderColors,
    required this.radius,
    required int priority,
  }) : super(size: size, position: position, priority: priority);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Fondo con degradado
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(rect);

    canvas.drawRRect(rrect, bgPaint);

    // Borde brillante
    final borderPaint = Paint()
      ..shader = LinearGradient(
        colors: borderColors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(rrect, borderPaint);
  }
}

// Componente helper para bordes redondeados
class _RoundedBorderComponent extends PositionComponent {
  final List<Color> colors;
  final double strokeWidth;
  final double radius;

  _RoundedBorderComponent({
    required Vector2 size,
    required Vector2 position,
    required this.colors,
    required this.strokeWidth,
    required this.radius,
    required int priority,
  }) : super(size: size, position: position, priority: priority);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }
}

// Componente de barra de progreso de Luna con border radius
class _LunaProgressBarComponent extends PositionComponent {
  final double progress;
  final int totalPoints;
  final int targetPoints;
  final int progressPercent;

  _LunaProgressBarComponent({
    required Vector2 size,
    required Vector2 position,
    required this.progress,
    required this.totalPoints,
    required this.targetPoints,
    required this.progressPercent,
    required int priority,
  }) : super(size: size, position: position, priority: priority);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));

    // Fondo oscuro de la barra
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0D1F2D),
          Color(0xFF152D3F),
        ],
      ).createShader(rect);

    canvas.drawRRect(rrect, bgPaint);

    // Barra de progreso interna (solo si hay progreso)
    if (progress > 0) {
      final progressWidth = (size.x - 8) * progress;
      final progressRect = Rect.fromLTWH(4, 4, progressWidth, size.y - 8);
      final progressRRect =
          RRect.fromRectAndRadius(progressRect, const Radius.circular(14));

      // Degradado de la barra de progreso
      final progressPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF6B9D),
            Color(0xFFFF8FB3),
            Color(0xFFFFB3C6),
          ],
        ).createShader(progressRect);

      canvas.drawRRect(progressRRect, progressPaint);

      // Brillo en la barra de progreso
      final glowRect = Rect.fromLTWH(4, 4, progressWidth, (size.y - 8) / 2);
      final glowRRect =
          RRect.fromRectAndRadius(glowRect, const Radius.circular(14));

      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(glowRect);

      canvas.drawRRect(glowRRect, glowPaint);
    }

    // Borde brillante exterior
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF6B9D),
          Color(0xFFFFB3C6),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(rrect, borderPaint);
  }
}
