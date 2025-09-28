import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'data/coinglass_api.dart';
import 'data/datasources/market_remote_data_source.dart';
import 'data/network/network_client.dart';
import 'data/repositories/market_repository.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // 统一配置网络客户端，后续数据源/仓库均依赖它。
    Get.lazyPut<NetworkClient>(
      () => NetworkClient(
        baseUrl: 'https://api.coingecko.com/api/v3',
        enableLogging: kDebugMode,
        defaultHeaders: const <String, dynamic>{
          'accept': 'application/json',
        },
      ),
      fenix: true,
    );

    // 远程数据源：负责具体的接口调用。
    Get.lazyPut<MarketRemoteDataSource>(
      () => MarketRemoteDataSource(Get.find<NetworkClient>()),
      fenix: true,
    );

    // 仓库：向业务层提供统一的市场数据获取接口。
    Get.lazyPut<MarketRepository>(
      () => MarketRepository(Get.find<MarketRemoteDataSource>()),
      fenix: true,
    );

    // 保留原有 CoinGlass 仓库供历史数据使用。
    Get.lazyPut<CoinGlassRepository>(
      () => CoinGlassRepository(
        apiKey: const String.fromEnvironment('COINGLASS_SECRET'),
      ),
      fenix: true,
    );
  }
}
