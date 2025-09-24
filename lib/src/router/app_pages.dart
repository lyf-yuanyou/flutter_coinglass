import 'package:get/get.dart';

import '../presentation/home_screen.dart';
import '../presentation/login_screen.dart';
import '../presentation/reminder_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String reminder = '/reminder';
  static const String login = '/login';
}

class AppPages {
  const AppPages._();

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.reminder,
      page: () => const ReminderScreen(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 320),
    ),
  ];
}
