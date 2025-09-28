import 'dart:convert';

class CoinMetrics {
  const CoinMetrics({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.openInterest,
    required this.volume24h,
    required this.longShortRatio,
  });

  factory CoinMetrics.fromJson(Map<String, dynamic> json) {
    return CoinMetrics(
      symbol: json['symbol'] as String,
      price: (json['price'] as num).toDouble(),
      change24h: (json['change24h'] as num).toDouble(),
      openInterest: (json['openInterest'] as num).toDouble(),
      volume24h: (json['volume24h'] as num).toDouble(),
      longShortRatio: (json['longShortRatio'] as num).toDouble(),
    );
  }

  factory CoinMetrics.fromRawJson(String source) =>
      CoinMetrics.fromJson(jsonDecode(source) as Map<String, dynamic>);

  final String symbol;
  final double price;
  final double change24h;
  final double openInterest;
  final double volume24h;
  final double longShortRatio;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'symbol': symbol,
        'price': price,
        'change24h': change24h,
        'openInterest': openInterest,
        'volume24h': volume24h,
        'longShortRatio': longShortRatio,
      };
}

class FundingRate {
  const FundingRate({
    required this.symbol,
    required this.exchange,
    required this.rate,
  });

  factory FundingRate.fromJson(Map<String, dynamic> json) {
    return FundingRate(
      symbol: json['symbol'] as String,
      exchange: json['exchange'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }

  factory FundingRate.fromRawJson(String source) =>
      FundingRate.fromJson(jsonDecode(source) as Map<String, dynamic>);

  final String symbol;
  final String exchange;
  final double rate;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'symbol': symbol,
        'exchange': exchange,
        'rate': rate,
      };
}

class LiquidationStat {
  const LiquidationStat({
    required this.exchange,
    required this.longLiquidations,
    required this.shortLiquidations,
  });

  factory LiquidationStat.fromJson(Map<String, dynamic> json) {
    return LiquidationStat(
      exchange: json['exchange'] as String,
      longLiquidations: (json['longLiquidations'] as num).toDouble(),
      shortLiquidations: (json['shortLiquidations'] as num).toDouble(),
    );
  }

  factory LiquidationStat.fromRawJson(String source) =>
      LiquidationStat.fromJson(jsonDecode(source) as Map<String, dynamic>);

  final String exchange;
  final double longLiquidations;
  final double shortLiquidations;

  double get total => longLiquidations + shortLiquidations;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'exchange': exchange,
        'longLiquidations': longLiquidations,
        'shortLiquidations': shortLiquidations,
      };
}

class MarketCoin {
  const MarketCoin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.marketCapRank,
    required this.marketCap,
    required this.totalVolume,
    required this.priceChange24h,
    required this.high24h,
    required this.low24h,
    required this.lastUpdated,
  });

  factory MarketCoin.fromJson(Map<String, dynamic> json) {
    return MarketCoin(
      id: json['id'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0,
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      marketCapRank: json['market_cap_rank'] as int? ?? 0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0,
      priceChange24h: (json['price_change_24h'] as num?)?.toDouble() ?? 0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0,
      lastUpdated: _parseDate(json['last_updated'] as String?),
    );
  }

  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double priceChangePercentage24h;
  final int marketCapRank;
  final double marketCap;
  final double totalVolume;
  final double priceChange24h;
  final double high24h;
  final double low24h;
  final DateTime? lastUpdated;

  bool get isPositive => priceChangePercentage24h >= 0;

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
