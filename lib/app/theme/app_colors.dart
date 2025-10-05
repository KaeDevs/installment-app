import 'package:flutter/material.dart';

/// Modern dark color palette for the Installment Tracker app
/// Clean, minimal, and sophisticated dark theme
class AppColors {
  // Primary Colors - Modern Dark Theme
  static const Color deepSlate = Color(0xFF0F172A);     // Deep slate background
  static const Color slate = Color(0xFF1E293B);         // Slate surfaces
  static const Color mediumSlate = Color(0xFF334155);   // Medium slate
  static const Color violet = Color(0xFF8B5CF6);        // Vibrant violet accent
  static const Color softViolet = Color(0xFFA78BFA);    // Soft violet
  
  // Extended palette for UI elements
  static const Color primaryDark = deepSlate;
  static const Color primary = violet;
  static const Color primaryLight = softViolet;
  
  static const Color secondary = Color(0xFF06B6D4);     // Cyan accent
  static const Color secondaryLight = Color(0xFF22D3EE);
  
  static const Color accent = violet;
  static const Color accentLight = softViolet;
  
  // Neutral colors - Dark theme
  static const Color background = Color(0xFF0F172A);    // Deep slate
  static const Color surface = Color(0xFF1E293B);       // Elevated slate
  static const Color surfaceVariant = Color(0xFF334155); // Variant slate
  
  // Text colors - High contrast for dark mode
  static const Color textPrimary = Color(0xFFF1F5F9);   // Almost white
  static const Color textSecondary = Color(0xFFCBD5E1); // Light gray
  static const Color textTertiary = Color(0xFF94A3B8);  // Muted gray
  
  // Status colors - Vibrant and modern
  static const Color success = Color(0xFF10B981);       // Emerald green
  static const Color warning = Color(0xFFF59E0B);       // Amber
  static const Color error = Color(0xFFF43F5E);         // Rose red
  static const Color info = Color(0xFF06B6D4);          // Cyan
  
  // Border colors - Subtle in dark theme
  static const Color borderLight = Color(0xFF334155);   // Subtle slate
  static const Color borderMedium = Color(0xFF475569);  // Medium slate
  static const Color borderDark = Color(0xFF64748B);    // Lighter slate
  
  // Semantic colors for loan management
  static const Color paid = success;
  static const Color pending = warning;
  static const Color overdue = error;
  static const Color active = violet;
  static const Color completed = success;
  
  // Shadow colors - Adjusted for dark theme
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowHeavy = Color(0x4D000000);
  
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