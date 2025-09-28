import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:coinglass_app/src/presentation/home/home_controller.dart';
import 'package:coinglass_app/src/presentation/home/home_state.dart';
import 'package:coinglass_app/src/presentation/home/shared/shared_widgets.dart';

class HomeDataView extends StatelessWidget {
  const HomeDataView({
    super.key,
    required this.controller,
    required this.onRefresh,
    required this.builder,
  });

  final HomeController controller;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, HomeDashboardData data) builder;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        final bool isLoading = controller.isLoading.value;
        final HomeDashboardData? data = controller.dashboardData.value;
        final Object? error = controller.error.value;

        if (isLoading && data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && data == null) {
          return ErrorState(error: error, onRetry: onRefresh);
        }

        if (data == null) {
          return const SizedBox.shrink();
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: builder(context, data),
        );
      }),
    );
  }
}
