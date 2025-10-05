import 'package:flutter/material.dart';

/// Modern color palette for the Installment Tracker app
/// Based on the provided design color scheme
class AppColors {
  // Primary Colors from the design
  static const Color darkTeal = Color(0xFF003135);      // Dark teal/green
  static const Color teal = Color(0xFF024950);          // Medium teal
  static const Color rust = Color(0xFF964734);          // Rust/brown
  static const Color lightTeal = Color(0xFF0FA4AF);     // Light teal/cyan
  static const Color lightGray = Color(0xFFAFDDE5);     // Light blue-gray
  
  // Extended palette for UI elements
  static const Color primaryDark = darkTeal;
  static const Color primary = teal;
  static const Color primaryLight = lightTeal;
  
  static const Color secondary = rust;
  static const Color secondaryLight = Color(0xFFB86652);
  
  static const Color accent = lightTeal;
  static const Color accentLight = lightGray;
  
  // Neutral colors
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F7);
  
  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = lightTeal;
  
  // Border colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF94A3B8);
  
  // Semantic colors for loan management
  static const Color paid = success;
  static const Color pending = warning;
  static const Color overdue = error;
  static const Color active = primary;
  static const Color completed = success;
  
  // Shadow colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowHeavy = Color(0x1F000000);
  
  // Opacity variants
  static Color get primaryWithOpacity10 => primary.withOpacity(0.1);
  static Color get primaryWithOpacity20 => primary.withOpacity(0.2);
  static Color get primaryWithOpacity30 => primary.withOpacity(0.3);
  
  static Color get secondaryWithOpacity10 => secondary.withOpacity(0.1);
  static Color get secondaryWithOpacity20 => secondary.withOpacity(0.2);
  static Color get secondaryWithOpacity30 => secondary.withOpacity(0.3);
  
  static Color get accentWithOpacity10 => accent.withOpacity(0.1);
  static Color get accentWithOpacity20 => accent.withOpacity(0.2);
  static Color get accentWithOpacity30 => accent.withOpacity(0.3);
}

/// Extension methods for color utilities
extension AppColorsExtension on Color {
  /// Create a MaterialColor from any color
  MaterialColor toMaterialColor() {
    final int red = this.red;
    final int green = this.green;
    final int blue = this.blue;
    
    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };
    
    return MaterialColor(value, shades);
  }
  
  /// Darken a color by a percentage
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  /// Lighten a color by a percentage
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}