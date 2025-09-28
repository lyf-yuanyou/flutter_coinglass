import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../data/models.dart';
import '../controllers/market_controller.dart';

/// 新闻模块使用的热门行情列表视图，展示关键市场指标。
class MarketNewsList extends StatelessWidget {
  MarketNewsList({
    required this.controller,
    super.key,
  })  : _priceFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2),
        _compactFormat = NumberFormat.compact(locale: 'zh_CN'),
        _timeFormat = DateFormat('MM-dd HH:mm');

  final MarketController controller;
  final NumberFormat _priceFormat;
  final NumberFormat _compactFormat;
  final DateFormat _timeFormat;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isLoading = controller.isLoading.value;
      final List<MarketCoin> items = controller.topMovers.toList(growable: false);
      final String? errorMessage = controller.errorMessage;
      final DateTime? lastUpdated = controller.lastUpdated.value;

      return RefreshIndicator(
        onRefresh: () => controller.loadTopMovers(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: _itemCount(items),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _buildHeader(context, isLoading, lastUpdated, items.isNotEmpty);
            }

            if (items.isEmpty) {
              return _buildStatePlaceholder(context, isLoading, errorMessage);
            }

            final MarketCoin coin = items[index - 1];
            return _MarketNewsCard(
              coin: coin,
              priceFormat: _priceFormat,
              compactFormat: _compactFormat,
              timeFormat: _timeFormat,
            );
          },
        ),
      );
    });
  }

  int _itemCount(List<MarketCoin> items) {
    if (items.isEmpty) {
      // Header + placeholder.
      return 2;
    }
    return items.length + 1;
  }

  Widget _buildHeader(
    BuildContext context,
    bool isLoading,
    DateTime? lastUpdated,
    bool hasData,
  ) {
    final theme = Theme.of(context);
    final String subtitle = lastUpdated == null
        ? '拉取 CoinGecko 热门行情，及时掌握波动' // default tagline
        : '最近更新 ${_timeFormat.format(lastUpdated.toLocal())}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '市场热点快讯',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (isLoading && hasData) ...<Widget>[
          const SizedBox(height: 12),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    );
  }

  Widget _buildStatePlaceholder(
    BuildContext context,
    bool isLoading,
    String? errorMessage,
  ) {
    if (isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return _NewsPlaceholder(
        icon: Icons.cloud_off,
        message: errorMessage,
        onRetry: () => controller.loadTopMovers(),
      );
    }

    return const _NewsPlaceholder(
      icon: Icons.info_outline,
      message: '暂未获取到行情数据，轻触下拉刷新重试',
    );
  }
}

class _MarketNewsCard extends StatelessWidget {
  const _MarketNewsCard({
    required this.coin,
    required this.priceFormat,
    required this.compactFormat,
    required this.timeFormat,
  });

  final MarketCoin coin;
  final NumberFormat priceFormat;
  final NumberFormat compactFormat;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color changeColor = coin.isPositive
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final String changeText = _formatPercent(coin.priceChangePercentage24h);
    final String marketCap =
        '${priceFormat.currencySymbol}${compactFormat.format(coin.marketCap)}';
    final String volume =
        '${priceFormat.currencySymbol}${compactFormat.format(coin.totalVolume)}';
    final String high = priceFormat.format(coin.high24h);
    final String low = priceFormat.format(coin.low24h);
    final String? updated = coin.lastUpdated == null
        ? null
        : timeFormat.format(coin.lastUpdated!.toLocal());

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                    child: Text(
                      coin.symbol.characters.take(3).join().toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          coin.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '代码 ${coin.symbol} · 市值排名 #${coin.marketCapRank}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        priceFormat.format(coin.currentPrice),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _ChangeBadge(
                        text: changeText,
                        color: changeColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: <Widget>[
                  _InfoChip(
                    icon: Icons.bar_chart,
                    label: '24h涨跌',
                    value: '${coin.priceChange24h >= 0 ? '+' : '-'}'
                        '${coin.priceChange24h.abs().toStringAsFixed(2)}',
                  ),
                  _InfoChip(
                    icon: Icons.show_chart,
                    label: '24h最高',
                    value: high,
                  ),
                  _InfoChip(
                    icon: Icons.stacked_line_chart,
                    label: '24h最低',
                    value: low,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: <Widget>[
                  _PillInfo(
                    icon: Icons.pie_chart_outline,
                    label: '市值',
                    value: marketCap,
                  ),
                  _PillInfo(
                    icon: Icons.swap_vert_circle_outlined,
                    label: '成交量',
                    value: volume,
                  ),
                  if (updated != null)
                    _PillInfo(
                      icon: Icons.schedule,
                      label: '更新时间',
                      value: updated,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPercent(double value) {
    final String formatted = value.abs().toStringAsFixed(2);
    return value >= 0 ? '+$formatted%' : '-$formatted%';
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$label $value',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillInfo extends StatelessWidget {
  const _PillInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            '$label $value',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _NewsPlaceholder extends StatelessWidget {
  const _NewsPlaceholder({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () => onRetry!(),
                child: const Text('重试'),
              ),
          ],
        ),
      ),
    );
  }
}
