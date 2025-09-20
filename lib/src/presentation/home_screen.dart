import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/coinglass_api.dart';
import '../data/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CoinGlassRepository _repository = CoinGlassRepository(
    apiKey: const String.fromEnvironment('COINGLASS_SECRET'),
  );
  late Future<_DashboardData> _dashboardFuture;

  final NumberFormat _priceFormat = NumberFormat.simpleCurrency(decimalDigits: 2);
  final NumberFormat _compactFormat = NumberFormat.compactSimpleCurrency(decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<_DashboardData> _loadDashboard() async {
    final metrics = await _repository.fetchCoinMetrics();
    final fundingRates = await _repository.fetchFundingRates();
    final liquidation = await _repository.fetchLiquidationStats();
    return _DashboardData(
      metrics: metrics,
      fundingRates: fundingRates,
      liquidation: liquidation,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
    await _dashboardFuture;
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoinGlass Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_DashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error,
              onRetry: _refresh,
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const SizedBox.shrink();
          }

          final displayedMetrics = data.metrics.take(6).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                const _SectionHeader(
                  title: '热门合约',
                  subtitle: '关注主流币种的价格、持仓与多空比',
                ),
                SizedBox(
                  height: 210,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayedMetrics.length,
                    itemBuilder: (context, index) {
                      final metric = displayedMetrics[index];
                      return _CoinMetricsCard(
                        metrics: metric,
                        priceFormat: _priceFormat,
                        compactFormat: _compactFormat,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: '资金费率',
                  subtitle: '监测不同交易所的多空情绪',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: data.fundingRates
                        .map(
                          (rate) => _FundingRateTile(
                            rate: rate,
                            percentText: '${rate.rate.toStringAsFixed(3)}%',
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: '爆仓数据',
                  subtitle: '了解市场杠杆风险的集中区域',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: data.liquidation
                        .map(
                          (stat) => _LiquidationTile(
                            stat: stat,
                            formatter: _compactFormat,
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

class _CoinMetricsCard extends StatelessWidget {
  const _CoinMetricsCard({
    required this.metrics,
    required this.priceFormat,
    required this.compactFormat,
  });

  final CoinMetrics metrics;
  final NumberFormat priceFormat;
  final NumberFormat compactFormat;

  Color _trendColor(BuildContext context) {
    if (metrics.change24h > 0) {
      return Colors.green.shade600;
    }
    if (metrics.change24h < 0) {
      return Colors.red.shade600;
    }
    return Theme.of(context).colorScheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _trendColor(context);

    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(_initials(metrics.symbol)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    metrics.symbol,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      metrics.change24h >= 0
                          ? '+${metrics.change24h.toStringAsFixed(2)}%'
                          : '${metrics.change24h.toStringAsFixed(2)}%',
                    ),
                    backgroundColor: color.withOpacity(0.1),
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                priceFormat.format(metrics.price),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _MetricRow(
                label: '24h成交量',
                value: compactFormat.format(metrics.volume24h),
              ),
              const SizedBox(height: 12),
              _MetricRow(
                label: '持仓量',
                value: compactFormat.format(metrics.openInterest),
              ),
              const SizedBox(height: 12),
              Text(
                '多空比 ${metrics.longShortRatio.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (metrics.longShortRatio / 2).clamp(0.0, 1.0),
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FundingRateTile extends StatelessWidget {
  const _FundingRateTile({required this.rate, required this.percentText});

  final FundingRate rate;
  final String percentText;

  Color _trendColor(BuildContext context) {
    if (rate.rate > 0) {
      return Colors.green.shade600;
    }
    if (rate.rate < 0) {
      return Colors.red.shade600;
    }
    return Theme.of(context).colorScheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _trendColor(context);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Text(_initials(rate.symbol)),
        ),
        title: Text('${rate.symbol} · ${rate.exchange}'),
        subtitle: const Text('资金费率'),
        trailing: Text(
          percentText,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LiquidationTile extends StatelessWidget {
  const _LiquidationTile({required this.stat, required this.formatter});

  final LiquidationStat stat;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = stat.total;
    final longPct = total == 0 ? 0.5 : stat.longLiquidations / total;
    final shortPct = total == 0 ? 0.5 : stat.shortLiquidations / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(_initials(stat.exchange)),
                ),
                const SizedBox(width: 12),
                Text(
                  stat.exchange,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  formatter.format(total),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('多头: ${formatter.format(stat.longLiquidations)}'),
                Text('空头: ${formatter.format(stat.shortLiquidations)}'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: (longPct * 1000).round(),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                    ),
                  ),
                ),
                Expanded(
                  flex: (shortPct * 1000).round(),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({this.error, required this.onRetry});

  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '无法连接到服务器',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? '请检查网络或稍后重试。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.metrics,
    required this.fundingRates,
    required this.liquidation,
  });

  final List<CoinMetrics> metrics;
  final List<FundingRate> fundingRates;
  final List<LiquidationStat> liquidation;
}

String _initials(String value) {
  if (value.isEmpty) {
    return '--';
  }
  final sanitized = value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  if (sanitized.isEmpty) {
    return '--';
  }
  if (sanitized.length >= 2) {
    return sanitized.substring(0, 2);
  }
  return sanitized.padRight(2, sanitized[0]);
}
