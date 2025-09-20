import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  final base = ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B5E20),
      brightness: brightness,
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'Roboto',
    ),
    cardTheme: base.cardTheme.copyWith(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
