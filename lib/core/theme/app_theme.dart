import 'package:flutter/material.dart';

const Color kGreen = Color(0xFF0C831F);

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: kGreen,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: kGreen,
      );
}
