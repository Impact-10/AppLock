import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  const primary = Color(0xFF0B61FF);
  const accent = Color(0xFF00C48C);
  const error = Color(0xFFFF4D4F);
  const bg = Color(0xFFF7F9FC);

  final textTheme = GoogleFonts.interTextTheme().apply(
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      error: error,
      background: bg,
    ),
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
    ),
    cardTheme: const CardTheme(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
