// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// ***************************************************************************
// AutoRouterGenerator
// ***************************************************************************

class _$AppRouter extends RootStackRouter {
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = <String, PageFactory>{
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    ReminderRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ReminderScreen(),
      );
    },
  };

  @override
  List<RouteConfig> get routes => <RouteConfig>[
        RouteConfig(
          HomeRoute.name,
          path: '/',
        ),
        RouteConfig(
          ReminderRoute.name,
          path: '/reminder',
        ),
      ];
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute()
      : super(
          HomeRoute.name,
          path: '/',
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ReminderScreen]
class ReminderRoute extends PageRouteInfo<void> {
  const ReminderRoute()
      : super(
          ReminderRoute.name,
          path: '/reminder',
        );

  static const String name = 'ReminderRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
