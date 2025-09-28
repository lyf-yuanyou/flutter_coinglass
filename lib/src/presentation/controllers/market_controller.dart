import 'package:get/get.dart';

import '../../data/models.dart';
import '../../data/network/network_exception.dart';
import '../../data/repositories/market_repository.dart';

/// 管理热门币种列表的状态控制器，负责调度仓库并暴露可监听数据。
class MarketController extends GetxController {
  MarketController(this._repository);

  final MarketRepository _repository;

  /// 当前是否正在加载数据，用于控制按钮、显示骨架屏等。
  final RxBool isLoading = false.obs;

  /// 最近一次请求返回的热门币种数据。
  final RxList<MarketCoin> topMovers = <MarketCoin>[].obs;

  /// 记录最近一次请求的网络异常，便于展示错误状态。
  final Rx<NetworkException?> error = Rx<NetworkException?>(null);

  /// 记录数据最后更新时间，界面可用来展示“刚刚更新”等提示。
  final Rx<DateTime?> lastUpdated = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    loadTopMovers();
  }

  /// 拉取热门币种数据，捕获不同异常并更新对应的响应式变量。
  Future<void> loadTopMovers({int limit = 10}) async {
    try {
      isLoading.value = true;
      error.value = null;

      // 拉取远程数据并更新响应式列表。
      final coins = await _repository.fetchTopMovers(limit: limit);
      topMovers.assignAll(coins);
      lastUpdated.value = DateTime.now();
    } on NetworkException catch (exception) {
      error.value = exception;
    } catch (err) {
      // 捕获未知异常，统一转换成网络异常结构，避免 UI 额外分支。
      error.value = NetworkException(
        message: '获取行情失败，请稍后重试',
        details: err,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 便捷 getter，避免 UI 端重复判空。
  String? get errorMessage => error.value?.message;
}
