import 'package:flutter/material.dart';

abstract final class RoyalTheme {
  static const Color forest = Color(0xFF1B5E20);
  static const Color mint = Color(0xFF00E676);
  static const Color nightBg = Color(0xFF001A15);
  static const Color dayBg = Color(0xFFA5D6A7);
  static const Color cardDark = Color(0xFF002B22);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF003D33);

  static Color primary(bool isDark) => isDark ? mint : forest;

  static double get radiusOuter => 32;
  static double get radiusCard => 18;
  static double get radiusButton => 16;

  static List<BoxShadow> cardShadow(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
