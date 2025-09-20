import 'package:auto_route/auto_route.dart';

import '../presentation/home_screen.dart';
import '../presentation/reminder_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: HomeRoute.page, path: '/'),
        AutoRoute(page: ReminderRoute.page, path: '/reminder'),
      ];
}
