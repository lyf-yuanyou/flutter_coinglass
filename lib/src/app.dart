import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_bindings.dart';
import 'router/app_router.dart';
import 'theme.dart';

class CoinGlassApp extends StatelessWidget {
  CoinGlassApp({super.key, AppRouter? appRouter})
      : _appRouter = appRouter ?? AppRouter();

  final AppRouter _appRouter;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'CoinGlass',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      initialBinding: AppBindings(),
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
