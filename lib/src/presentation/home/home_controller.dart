import 'package:get/get.dart';

import 'package:coinglass_app/src/data/coinglass_api.dart';
import 'package:coinglass_app/src/data/models.dart';
import 'package:coinglass_app/src/presentation/home/home_state.dart';

/// 首页主控制器，负责协调仪表盘相关的数据拉取与状态管理。
class HomeController extends GetxController {
  HomeController(this._repository);

  final CoinGlassRepository _repository;

  /// 页面整体加载状态，配合骨架屏/指示器使用。
  final RxBool isLoading = true.obs;
  /// 仪表盘聚合数据，包含指标、资金费率、爆仓统计等。
  final Rx<HomeDashboardData?> dashboardData = Rx<HomeDashboardData?>(null);
  /// 捕获请求过程中的异常，便于上层展示错误态。
  final Rx<Object?> error = Rx<Object?>(null);
  /// 底部导航选中索引。
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  /// 拉取首页仪表盘所需的所有数据，并汇总成单个状态对象。
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

  /// 更新底部导航索引，避免重复触发刷新。
  void setIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
    }
  }
}
