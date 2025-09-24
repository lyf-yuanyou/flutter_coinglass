import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_bindings.dart';
import 'router/app_pages.dart';
import 'theme.dart';

class CoinGlassApp extends StatelessWidget {
  const CoinGlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CoinGlass',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      initialBinding: AppBindings(),
      initialRoute: AppRoutes.home,
      getPages: AppPages.routes,
    );
  }
}
