import 'package:flutter/material.dart';

class FontStyles {
  // Poppins font styles
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'poppins',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  // Common text styles
  static TextStyle get heading => poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get subheading => poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get body => poppins(
    fontSize: 16,
  );

  static TextStyle get bodySmall => poppins(
    fontSize: 14,
  );

  static TextStyle get caption => poppins(
    fontSize: 12,
  );

  static TextStyle get button => poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
} 
