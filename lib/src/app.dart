import 'package:flutter/material.dart';

import 'presentation/home_screen.dart';
import 'theme.dart';

class CoinGlassApp extends StatelessWidget {
  const CoinGlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoinGlass',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
