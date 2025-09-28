import 'package:coinglass_app/src/data/models.dart';

class HomeDashboardData {
  const HomeDashboardData({
    required this.metrics,
    required this.fundingRates,
    required this.liquidation,
  });

  final List<CoinMetrics> metrics;
  final List<FundingRate> fundingRates;
  final List<LiquidationStat> liquidation;
}
