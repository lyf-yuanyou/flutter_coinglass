import 'package:get/get.dart';

import '../../data/models.dart';
import '../../data/network/network_exception.dart';
import '../../data/repositories/market_repository.dart';

class MarketController extends GetxController {
  MarketController(this._repository);

  final MarketRepository _repository;

  final RxBool isLoading = false.obs;
  final RxList<MarketCoin> topMovers = <MarketCoin>[].obs;
  final Rx<NetworkException?> error = Rx<NetworkException?>(null);
  final Rx<DateTime?> lastUpdated = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    loadTopMovers();
  }

  Future<void> loadTopMovers({int limit = 10}) async {
    try {
      isLoading.value = true;
      error.value = null;

      final coins = await _repository.fetchTopMovers(limit: limit);
      topMovers.assignAll(coins);
      lastUpdated.value = DateTime.now();
    } on NetworkException catch (exception) {
      error.value = exception;
    } catch (err) {
      error.value = NetworkException(
        message: '获取行情失败，请稍后重试',
        details: err,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? get errorMessage => error.value?.message;
}
