import 'package:flutter/material.dart';

/// A warm, earthy palette rather than the default Material blue — this is an
/// app about family photographs and remembered dates, and it should feel
/// closer to a photo album than to a database client.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF9C6644);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
        thickness: 1,
      ),
    );
  }
}

/// Spacing and sizing for the tree canvas.
///
/// The canvas and its painters share one instance, so cards and the lines
/// between them can never drift apart. Each tree style supplies its own
/// metrics — portraits need taller cards, the organic style needs more room
/// between generations for its branches to curve.
class TreeMetrics {
  const TreeMetrics({
    required this.cardWidth,
    required this.cardHeight,
    required this.columnGap,
    required this.rowGap,
    this.canvasPadding = 48,
  });

  static const TreeMetrics chart = TreeMetrics(
    cardWidth: 152,
    cardHeight: 96,
    columnGap: 24,
    rowGap: 72,
  );

  static const TreeMetrics organic = TreeMetrics(
    cardWidth: 148,
    cardHeight: 88,
    columnGap: 32,
    rowGap: 104,
  );

  static const TreeMetrics portrait = TreeMetrics(
    cardWidth: 132,
    cardHeight: 168,
    columnGap: 22,
    rowGap: 78,
  );

  final double cardWidth;
  final double cardHeight;
  final double columnGap;
  final double rowGap;
  final double canvasPadding;

  double get rowPitch => cardHeight + rowGap;
  double get columnPitch => cardWidth + columnGap;

  Size get cardSize => Size(cardWidth, cardHeight);
}
