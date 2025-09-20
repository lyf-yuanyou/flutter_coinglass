import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';
import 'sample_data.dart';

class CoinGlassRepository {
  CoinGlassRepository({http.Client? client, this.apiKey})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String? apiKey;

  static const _baseUrl = 'https://open-api.coinglass.com/public/v2';

  Map<String, String> get _headers => <String, String>{
        'accept': 'application/json',
        if (apiKey != null && apiKey!.isNotEmpty) 'coinglassSecret': apiKey!,
      };

  Future<List<CoinMetrics>> fetchCoinMetrics() async {
    final uri = Uri.parse('$_baseUrl/futures/tickers?interval=24h');

    final response = await _safeGet(uri);
    if (response == null) {
      return sampleCoinMetrics
          .map((dynamic item) =>
              CoinMetrics.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = payload['data'];
    if (data is List) {
      return data
          .map((dynamic item) => CoinMetrics.fromJson(
                _mapCoinMetrics(item as Map<String, dynamic>),
              ))
          .toList();
    }

    return sampleCoinMetrics
        .map((dynamic item) => CoinMetrics.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FundingRate>> fetchFundingRates() async {
    final uri = Uri.parse('$_baseUrl/futures/fundingRate/list');
    final response = await _safeGet(uri);
    if (response == null) {
      return sampleFundingRates
          .map((dynamic item) =>
              FundingRate.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = payload['data'];
    if (data is List) {
      return data
          .map((dynamic item) => FundingRate.fromJson(
                _mapFundingRate(item as Map<String, dynamic>),
              ))
          .toList();
    }

    return sampleFundingRates
        .map((dynamic item) => FundingRate.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<LiquidationStat>> fetchLiquidationStats() async {
    final uri = Uri.parse('$_baseUrl/futures/liquidation');
    final response = await _safeGet(uri);
    if (response == null) {
      return sampleLiquidationStats
          .map((dynamic item) =>
              LiquidationStat.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = payload['data'];
    if (data is List) {
      return data
          .map((dynamic item) => LiquidationStat.fromJson(
                _mapLiquidation(item as Map<String, dynamic>),
              ))
          .toList();
    }

    return sampleLiquidationStats
        .map((dynamic item) =>
            LiquidationStat.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<http.Response?> _safeGet(Uri uri) async {
    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        return response;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Map<String, dynamic> _mapCoinMetrics(Map<String, dynamic> json) {
    return <String, dynamic>{
      'symbol': json['symbol'] ?? json['pair'] ?? 'UNKNOWN',
      'price': _toDouble(json['price'] ?? json['uPrice']),
      'change24h': _toDouble(json['chgPct'] ?? json['change']),
      'openInterest': _toDouble(json['openInterest'] ?? json['oi']),
      'volume24h': _toDouble(json['volume'] ?? json['vol']),
      'longShortRatio': _toDouble(json['longShortRatio'] ?? json['lsr'] ?? 1),
    };
  }

  Map<String, dynamic> _mapFundingRate(Map<String, dynamic> json) {
    return <String, dynamic>{
      'symbol': json['symbol'] ?? json['pair'] ?? 'UNKNOWN',
      'exchange': json['exchange'] ?? json['market'] ?? 'Unknown',
      'rate': _toDouble(json['rate'] ?? json['fundingRate']),
    };
  }

  Map<String, dynamic> _mapLiquidation(Map<String, dynamic> json) {
    return <String, dynamic>{
      'exchange': json['exchange'] ?? json['market'] ?? 'Unknown',
      'longLiquidations':
          _toDouble(json['long'] ?? json['longLiquidations']),
      'shortLiquidations':
          _toDouble(json['short'] ?? json['shortLiquidations']),
    };
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  void dispose() {
    _client.close();
  }
}
