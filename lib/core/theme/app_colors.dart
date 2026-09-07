import 'package:flutter/material.dart';

/// Al-Bahith Academy design system colors.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF1E40AF);
  static const primaryLight = Color(0xFF3B5FD9);
  static const primaryDark = Color(0xFF152E7F);
  static const accent = Color(0xFFDC2626);
  static const accentLight = Color(0xFFEF4444);
  static const navy = Color(0xFF0F172A);
  static const surface = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF64748B);
  static const textPrimary = Color(0xFF0F172A);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFEEF2F6);
  static const shimmerBase = Color(0xFFE9EDF2);
  static const shimmerHighlight = Color(0xFFF6F8FA);

  static const gold = Color(0xFFF6B93B);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF1E40AF), Color(0xFF0F1E5C)],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), success],
  );

  static List<Color> gradientForIndex(int index) {
    const gradients = [
      [Color(0xFF1E40AF), Color(0xFF3B5FD9)],
      [Color(0xFFDC2626), Color(0xFFF87171)],
      [Color(0xFF10B981), Color(0xFF34D399)],
      [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      [Color(0xFF7C3AED), Color(0xFFA78BFA)],
      [Color(0xFF0891B2), Color(0xFF22D3EE)],
    ];
    return gradients[index % gradients.length];
  }
}
