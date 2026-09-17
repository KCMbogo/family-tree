import 'package:flutter/material.dart';

import '../../../domain/services/tree_layout.dart';

/// Draws the connectors of a genealogical chart.
///
/// Three shapes, each meaning something specific:
///
/// - a **couple bar**: a short horizontal line joining two spouses;
/// - a **descent**: a drop from the couple's midpoint to a horizontal sibling
///   bar, then a drop to each child — so children of one couple visibly share
///   a single origin;
/// - a **sibling tie**: a dashed link for people recorded as siblings when no
///   parent is known to join them.
class TreeConnectorPainter extends CustomPainter {
  const TreeConnectorPainter({
    required this.layout,
    required this.toOffset,
    required this.cardSize,
    required this.lineColor,
    required this.coupleColor,
  });

  final TreeLayout layout;

  /// Maps a slot-space point (x in card pitches, generation row) to pixels at
  /// the card's centre.
  final Offset Function(double x, int generation) toOffset;

  final Size cardSize;
  final Color lineColor;
  final Color coupleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final descent = Paint()
      ..color = lineColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final couple = Paint()
      ..color = coupleColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Group descents by their hanging point so each sibling group gets one bar.
    final groups = <String, List<TreeEdge>>{};

    for (final edge in layout.edges) {
      switch (edge.kind) {
        case TreeEdgeKind.couple:
          _drawCoupleBar(canvas, couple, edge);
        case TreeEdgeKind.siblingOnly:
          _drawSiblingTie(canvas, descent, edge);
        case TreeEdgeKind.descent:
          final key = '${edge.fromGeneration}:'
              '${edge.originX!.toStringAsFixed(4)}';
          groups.putIfAbsent(key, () => []).add(edge);
      }
    }

    for (final group in groups.values) {
      _drawDescentGroup(canvas, descent, couple, group);
    }
  }

  /// A horizontal tie between two spouses, drawn between their facing edges.
  void _drawCoupleBar(Canvas canvas, Paint paint, TreeEdge edge) {
    final a = toOffset(edge.fromX, edge.fromGeneration);
    final b = toOffset(edge.toX, edge.toGeneration);
    final (left, right) = a.dx <= b.dx ? (a, b) : (b, a);

    final start = Offset(left.dx + cardSize.width / 2, left.dy);
    final end = Offset(right.dx - cardSize.width / 2, right.dy);
    if (end.dx <= start.dx) return;

    canvas.drawLine(start, end, paint);

    // A small marker at the midpoint: the point descent hangs from.
    canvas.drawCircle(
      Offset((start.dx + end.dx) / 2, start.dy),
      3,
      Paint()..color = paint.color,
    );
  }

  /// The classic bracket: down from the couple, across the sibling bar, then
  /// down into each child.
  void _drawDescentGroup(
    Canvas canvas,
    Paint paint,
    Paint accent,
    List<TreeEdge> group,
  ) {
    final first = group.first;
    final origin = toOffset(first.originX!, first.fromGeneration);
    final childTops = [
      for (final edge in group) toOffset(edge.toX, edge.toGeneration),
    ]..sort((a, b) => a.dx.compareTo(b.dx));

    final parentBottom = origin.dy + cardSize.height / 2;
    final childTop = childTops.first.dy - cardSize.height / 2;

    // The sibling bar sits midway between the two rows.
    final barY = parentBottom + (childTop - parentBottom) / 2;

    // Start the stem on the marriage bar itself, which runs through the cards'
    // vertical centre — not at the cards' bottom edge. Starting lower leaves a
    // gap so the descent appears to hang unattached instead of joining the
    // couple. For a lone parent there is no bar, so start at the card edge.
    final isCouple = group.first.hasTwoParents;
    final stemTop = isCouple ? origin.dy : parentBottom;

    canvas.drawLine(
      Offset(origin.dx, stemTop),
      Offset(origin.dx, barY),
      paint,
    );

    // The sibling bar itself, spanning all children.
    if (childTops.length > 1) {
      canvas.drawLine(
        Offset(childTops.first.dx, barY),
        Offset(childTops.last.dx, barY),
        paint,
      );
    }

    // A drop into each child.
    for (final child in childTops) {
      canvas.drawLine(
        Offset(child.dx, barY),
        Offset(child.dx, childTop),
        paint,
      );
      canvas.drawCircle(
        Offset(child.dx, childTop),
        2.5,
        Paint()..color = paint.color,
      );
    }
  }

  /// Siblings asserted with no parent recorded: dashed, sitting just below the
  /// cards so it cannot be mistaken for a marriage.
  void _drawSiblingTie(Canvas canvas, Paint paint, TreeEdge edge) {
    final a = toOffset(edge.fromX, edge.fromGeneration);
    final b = toOffset(edge.toX, edge.toGeneration);
    final (left, right) = a.dx <= b.dx ? (a, b) : (b, a);

    final y = left.dy + cardSize.height * 0.32;
    final startX = left.dx + cardSize.width / 2;
    final endX = right.dx - cardSize.width / 2;
    if (endX <= startX) return;

    const dash = 5.0;
    const gap = 4.0;
    for (var x = startX; x < endX; x += dash + gap) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dash).clamp(startX, endX), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TreeConnectorPainter old) =>
      old.layout != layout ||
      old.cardSize != cardSize ||
      old.lineColor != lineColor ||
      old.coupleColor != coupleColor;
}
