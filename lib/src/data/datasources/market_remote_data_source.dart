import 'package:dio/dio.dart';

import '../models.dart';
import '../network/network_client.dart';
import '../network/network_exception.dart';

class MarketRemoteDataSource {
  const MarketRemoteDataSource(this._client);

  final NetworkClient _client;

  Future<List<MarketCoin>> fetchTopMovers({int limit = 10}) async {
    final Response<dynamic> response = await _client.get<dynamic>(
      '/coins/markets',
      queryParameters: <String, dynamic>{
        'vs_currency': 'usd',
        'order': 'market_cap_desc',
        'per_page': limit,
        'page': 1,
        'sparkline': false,
        'price_change_percentage': '24h',
      },
    );

    final dynamic data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(MarketCoin.fromJson)
          .toList();
    }

    throw NetworkException(
      message: '数据格式异常，无法解析行情列表',
      details: data,
    );
  }
}
