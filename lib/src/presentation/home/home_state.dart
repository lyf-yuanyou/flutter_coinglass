import 'package:coinglass_app/src/data/models.dart';

/// 聚合首页所需的核心数据模型，便于一次性传给 UI。
class HomeDashboardData {
  const HomeDashboardData({
    required this.metrics,
    required this.fundingRates,
    required this.liquidation,
  });

  /// 合约指标列表，包含价格、持仓量等。
  final List<CoinMetrics> metrics;
  /// 各币种资金费率数据。
  final List<FundingRate> fundingRates;
  /// 大额爆仓统计。
  final List<LiquidationStat> liquidation;
}
