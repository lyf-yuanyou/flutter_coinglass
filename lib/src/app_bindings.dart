import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'data/coinglass_api.dart';
import 'data/datasources/market_remote_data_source.dart';
import 'data/network/network_client.dart';
import 'data/repositories/market_repository.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
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

    Get.lazyPut<MarketRemoteDataSource>(
      () => MarketRemoteDataSource(Get.find<NetworkClient>()),
      fenix: true,
    );

    Get.lazyPut<MarketRepository>(
      () => MarketRepository(Get.find<MarketRemoteDataSource>()),
      fenix: true,
    );

    Get.lazyPut<CoinGlassRepository>(
      () => CoinGlassRepository(
        apiKey: const String.fromEnvironment('COINGLASS_SECRET'),
      ),
      fenix: true,
    );
  }
}
