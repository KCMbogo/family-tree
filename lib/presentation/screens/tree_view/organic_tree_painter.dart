import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/services/tree_layout.dart';

/// Draws the tree as branches rather than as wiring.
///
/// Same [TreeLayout] as every other style — only the strokes differ. Branches
/// taper as they rise through the generations, the way a real tree thins
/// toward its crown, and descent is drawn as a curve so a family reads as
/// something grown rather than something wired together.
class OrganicTreePainter extends CustomPainter {
  const OrganicTreePainter({
    required this.layout,
    required this.toOffset,
    required this.cardSize,
    required this.branchColor,
    required this.coupleColor,
  });

  final TreeLayout layout;
  final Offset Function(double x, int generation) toOffset;
  final Size cardSize;
  final Color branchColor;
  final Color coupleColor;

  /// Trunk width at the oldest generation, tapering toward the youngest.
  static const double _rootWidth = 9;
  static const double _tipWidth = 2.2;

  double _widthFor(int generation) {
    if (layout.generationCount <= 1) return _rootWidth;
    final t = generation / (layout.generationCount - 1);
    return _rootWidth + (_tipWidth - _rootWidth) * t;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final groups = <String, List<TreeEdge>>{};

    for (final edge in layout.edges) {
      switch (edge.kind) {
        case TreeEdgeKind.couple:
          _drawUnion(canvas, edge);
        case TreeEdgeKind.siblingOnly:
          _drawSiblingWisp(canvas, edge);
        case TreeEdgeKind.descent:
          final key = '${edge.fromGeneration}:'
              '${edge.originX!.toStringAsFixed(4)}';
          groups.putIfAbsent(key, () => []).add(edge);
      }
    }

    for (final group in groups.values) {
      _drawBranches(canvas, group);
    }
  }

  /// Two spouses joined by a swelling bough — the fork a branch grows from.
  void _drawUnion(Canvas canvas, TreeEdge edge) {
    final a = toOffset(edge.fromX, edge.fromGeneration);
    final b = toOffset(edge.toX, edge.toGeneration);
    final (left, right) = a.dx <= b.dx ? (a, b) : (b, a);

    final start = Offset(left.dx + cardSize.width / 2, left.dy);
    final end = Offset(right.dx - cardSize.width / 2, right.dy);
    if (end.dx <= start.dx) return;

    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = coupleColor
        ..strokeWidth = _widthFor(edge.fromGeneration) * 0.6
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset((start.dx + end.dx) / 2, start.dy),
      _widthFor(edge.fromGeneration) * 0.45,
      Paint()..color = coupleColor,
    );
  }

  /// A limb per child, curving out of the parents' union and tapering as it
  /// rises to the next generation.
  void _drawBranches(Canvas canvas, List<TreeEdge> group) {
    final first = group.first;
    final origin = toOffset(first.originX!, first.fromGeneration);

    final parentWidth = _widthFor(first.fromGeneration);
    final childWidth = _widthFor(first.toGeneration);

    for (final edge in group) {
      final child = toOffset(edge.toX, edge.toGeneration);

      final start = Offset(origin.dx, origin.dy + cardSize.height / 2);
      final end = Offset(child.dx, child.dy - cardSize.height / 2);

      // Control points pull the curve vertical at both ends, so a branch
      // leaves the parents going down and meets the child going up rather
      // than cutting across at an angle.
      final lift = (end.dy - start.dy) * 0.55;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx, start.dy + lift,
          end.dx, end.dy - lift,
          end.dx, end.dy,
        );

      canvas.drawPath(
        path,
        Paint()
          ..color = branchColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = (parentWidth + childWidth) / 2 * 0.72
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // A bud where the branch meets the child.
      canvas.drawCircle(
        end,
        childWidth * 0.8,
        Paint()..color = branchColor,
      );
    }
  }

  /// Siblings with no recorded parent: a thin wisp, clearly not a bough.
  void _drawSiblingWisp(Canvas canvas, TreeEdge edge) {
    final a = toOffset(edge.fromX, edge.fromGeneration);
    final b = toOffset(edge.toX, edge.toGeneration);
    final (left, right) = a.dx <= b.dx ? (a, b) : (b, a);

    final y = left.dy + cardSize.height * 0.34;
    final startX = left.dx + cardSize.width / 2;
    final endX = right.dx - cardSize.width / 2;
    if (endX <= startX) return;

    final paint = Paint()
      ..color = branchColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // A shallow arc reads as a tendril rather than a structural branch.
    final path = Path()
      ..moveTo(startX, y)
      ..quadraticBezierTo(
        (startX + endX) / 2,
        y + math.min(18, (endX - startX) * 0.18),
        endX,
        y,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(OrganicTreePainter old) =>
      old.layout != layout ||
      old.cardSize != cardSize ||
      old.branchColor != branchColor ||
      old.coupleColor != coupleColor;
}
