import 'package:get/get.dart';

import 'package:coinglass_app/src/data/coinglass_api.dart';
import 'package:coinglass_app/src/data/models.dart';
import 'package:coinglass_app/src/presentation/home/home_state.dart';

class HomeController extends GetxController {
  HomeController(this._repository);

  final CoinGlassRepository _repository;

  final RxBool isLoading = true.obs;
  final Rx<HomeDashboardData?> dashboardData = Rx<HomeDashboardData?>(null);
  final Rx<Object?> error = Rx<Object?>(null);
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    try {
      isLoading.value = true;
      error.value = null;

      final metrics = await _repository.fetchCoinMetrics();
      final fundingRates = await _repository.fetchFundingRates();
      final liquidation = await _repository.fetchLiquidationStats();

      dashboardData.value = HomeDashboardData(
        metrics: metrics,
        fundingRates: fundingRates,
        liquidation: liquidation,
      );
    } catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  void setIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
    }
  }
}
