import 'package:flutter/material.dart';

/// Provides fallbacks for newer Material 3 color roles when running on
/// Flutter versions that don't expose them yet.
extension ColorSchemeUtils on ColorScheme {
  Color get surfaceContainerHighest {
    final Color base =
        brightness == Brightness.dark ? surface : surfaceVariant;
    return base;
  }
}
