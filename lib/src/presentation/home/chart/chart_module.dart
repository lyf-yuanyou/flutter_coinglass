import 'dart:math';

import 'package:flutter/material.dart';

import 'package:coinglass_app/src/data/models.dart';
import 'package:coinglass_app/src/presentation/home/home_controller.dart';
import 'package:coinglass_app/src/presentation/home/home_formatters.dart';
import 'package:coinglass_app/src/presentation/home/home_state.dart';
import 'package:coinglass_app/src/presentation/home/shared/home_data_view.dart';
import 'package:coinglass_app/src/presentation/home/shared/shared_widgets.dart';

/// K 线图模块，整合行情概览、指标图层与统计信息。
class ChartModule extends StatelessWidget {
  const ChartModule({
    super.key,
    required this.controller,
    required this.formatters,
    required this.onRefresh,
    required this.onShowComingSoon,
    required this.timeframes,
    required this.actions,
  });

  final HomeController controller;
  final HomeFormatters formatters;
  final Future<void> Function() onRefresh;
  final VoidCallback onShowComingSoon;
  final List<String> timeframes;
  final List<String> actions;

  @override
  Widget build(BuildContext context) {
    return HomeDataView(
      controller: controller,
      onRefresh: onRefresh,
      builder: (BuildContext context, HomeDashboardData data) {
        if (data.metrics.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: const <Widget>[
              SizedBox(height: 60),
              EmptyState(description: '暂无图表数据，稍后再试试~', icon: Icons.show_chart),
            ],
          );
        }

        // 目前产品原型默认展示 ETH，如不存在则回退到第一项数据。
        final CoinMetrics coin =
            _findCoin(data.metrics, 'ETH') ?? data.metrics.first;
        final FundingRate? fundingRate = _findFundingRate(
          data.fundingRates,
          coin.symbol,
        );
        final List<_ChartCandle> candles = _sampleEthCandles;

        double highestPrice = candles.first.high;
        double lowestPrice = candles.first.low;
        for (final _ChartCandle candle in candles) {
          if (candle.high > highestPrice) {
            highestPrice = candle.high;
          }
          if (candle.low < lowestPrice) {
            lowestPrice = candle.low;
          }
        }

        final double fundingPercent = (fundingRate?.rate ?? 0) * 100;
        final String fundingText = fundingRate == null
            ? '--'
            : formatters.formatPercent(fundingPercent);
        final Color? fundingColor = fundingRate == null
            ? null
            : (fundingPercent >= 0 ? const Color(0xFF26A69A) : const Color(0xFFE53935));

        final List<_MovingAverage> movingAverages = <_MovingAverage>[
          _MovingAverage(
            label: 'MA(5)',
            color: const Color(0xFFFFB300),
            values: _calculateMovingAverage(candles, 5),
          ),
          _MovingAverage(
            label: 'MA(10)',
            color: const Color(0xFFAB47BC),
            values: _calculateMovingAverage(candles, 10),
          ),
          _MovingAverage(
            label: 'MA(20)',
            color: const Color(0xFF29B6F6),
            values: _calculateMovingAverage(candles, 20),
          ),
        ];

        final List<_IndicatorLegendEntry> legendEntries = movingAverages
            .map((_MovingAverage ma) {
              final double? latest = _latestNonNull(ma.values);
              if (latest == null) {
                return null;
              }
              return _IndicatorLegendEntry(
                label: ma.label,
                value: formatters.formatMarketPrice(latest),
                color: ma.color,
              );
            })
            .whereType<_IndicatorLegendEntry>()
            .toList();

        final List<_StatItem> statItems = <_StatItem>[
          _StatItem(label: '24h最高', value: formatters.formatMarketPrice(highestPrice)),
          _StatItem(label: '24h最低', value: formatters.formatMarketPrice(lowestPrice)),
          _StatItem(label: '24h成交量', value: formatters.formatLargeNumber(coin.volume24h)),
          _StatItem(label: '资金费率', value: fundingText, valueColor: fundingColor),
          _StatItem(label: '多空比', value: coin.longShortRatio.toStringAsFixed(2)),
          _StatItem(label: '持仓量', value: formatters.formatLargeNumber(coin.openInterest)),
        ];

        final double lastVolume = candles.isEmpty ? 0 : candles.last.volume;
        final double averageVolume = _averageVolume(candles, 20);

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: <Widget>[
            const SizedBox(height: 12),
            _ChartHeader(
              symbol: '${coin.symbol}USDT 永续',
              exchange: 'Binance',
              onBackTap: onShowComingSoon,
              onFavouriteTap: onShowComingSoon,
              onShareTap: onShowComingSoon,
            ),
            const SizedBox(height: 16),
            _PriceOverview(
              priceText: formatters.formatMarketPrice(coin.price),
              changeText: formatters.formatPercent(coin.change24h),
              changeColor: coin.change24h >= 0
                  ? const Color(0xFF26A69A)
                  : const Color(0xFFE53935),
              currencyText: formatters.priceFormat.format(coin.price),
            ),
            const SizedBox(height: 16),
            _StatsGrid(items: statItems),
            const SizedBox(height: 20),
            _ChartToolbar(
              timeframes: timeframes,
              actions: actions,
              onTimeframeTap: (_) => onShowComingSoon(),
              onActionTap: (_) => onShowComingSoon(),
            ),
            if (legendEntries.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              _IndicatorLegend(entries: legendEntries),
            ],
            const SizedBox(height: 12),
            _ChartCard(candles: candles, movingAverages: movingAverages),
            const SizedBox(height: 12),
            _ChartMetricBadges(
              badges: <_ChartMetricBadgeData>[
                _ChartMetricBadgeData(
                  label: 'VOL',
                  value: formatters.formatLargeNumber(lastVolume),
                  color: const Color(0xFF26A69A),
                ),
                _ChartMetricBadgeData(
                  label: 'VOL(20)',
                  value: formatters.formatLargeNumber(averageVolume),
                  color: const Color(0xFFE53935),
                ),
                _ChartMetricBadgeData(
                  label: '成交额',
                  value: formatters.formatLargeNumber(coin.volume24h),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ChartDetailCard(
              items: <_DetailItem>[
                _DetailItem(
                  title: '资金费率',
                  value: fundingText,
                  valueColor: fundingColor,
                ),
                _DetailItem(
                  title: '多空比',
                  value: coin.longShortRatio.toStringAsFixed(2),
                ),
                _DetailItem(
                  title: '24h成交量',
                  value: formatters.formatLargeNumber(coin.volume24h),
                ),
                _DetailItem(
                  title: '持仓量',
                  value: formatters.formatLargeNumber(coin.openInterest),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  /// 在指标列表里查找目标币种，返回空表示未命中。
  CoinMetrics? _findCoin(List<CoinMetrics> metrics, String symbol) {
    for (final CoinMetrics coin in metrics) {
      if (coin.symbol.toUpperCase() == symbol.toUpperCase()) {
        return coin;
      }
    }
    return null;
  }

  /// 根据币种符号匹配资金费率数据。
  FundingRate? _findFundingRate(List<FundingRate> rates, String symbol) {
    for (final FundingRate rate in rates) {
      if (rate.symbol.toUpperCase() == symbol.toUpperCase()) {
        return rate;
      }
    }
    return null;
  }

  /// 找出移动平均列表中最后一个有效值，便于渲染图例。
  double? _latestNonNull(List<double?> values) {
    for (int i = values.length - 1; i >= 0; i--) {
      final double? value = values[i];
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  /// 计算指定周期内的平均成交量，供 VOL(20) 指标展示使用。
  double _averageVolume(List<_ChartCandle> candles, int period) {
    if (candles.isEmpty) {
      return 0;
    }
    final int start = candles.length > period ? candles.length - period : 0;
    final List<_ChartCandle> window = candles.sublist(start);
    if (window.isEmpty) {
      return 0;
    }
    double total = 0;
    for (final _ChartCandle candle in window) {
      total += candle.volume;
    }
    return total / window.length;
  }
}

/// 图表顶部标题栏，提供返回、收藏、分享等操作。
class _ChartHeader extends StatelessWidget {
  const _ChartHeader({
    required this.symbol,
    required this.exchange,
    required this.onBackTap,
    required this.onFavouriteTap,
    required this.onShareTap,
  });

  final String symbol;
  final String exchange;
  final VoidCallback onBackTap;
  final VoidCallback onFavouriteTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: onBackTap,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                symbol,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exchange,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _ChartIconButton(icon: Icons.star_border, onTap: onFavouriteTap),
        const SizedBox(width: 12),
        _ChartIconButton(icon: Icons.share_outlined, onTap: onShareTap),
        const SizedBox(width: 12),
        _ChartIconButton(icon: Icons.fullscreen, onTap: onShareTap),
      ],
    );
  }
}

/// 图表模块通用的圆角图标按钮。
class _ChartIconButton extends StatelessWidget {
  const _ChartIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// 价格概览区域，展示当前价与 24h 涨跌幅。
class _PriceOverview extends StatelessWidget {
  const _PriceOverview({
    required this.priceText,
    required this.changeText,
    required this.changeColor,
    required this.currencyText,
  });

  final String priceText;
  final String changeText;
  final Color changeColor;
  final String currencyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                priceText,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currencyText,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                changeText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '24h涨跌',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 指标统计项的数据模型。
class _StatItem {
  const _StatItem({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}

/// 关键统计信息的宫格展示。
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final _StatItem item = items[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                item.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                item.value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: item.valueColor ?? theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 图表工具栏，展示时间范围与操作按钮。
class _ChartToolbar extends StatelessWidget {
  const _ChartToolbar({
    required this.timeframes,
    required this.actions,
    this.onTimeframeTap,
    this.onActionTap,
  });

  final List<String> timeframes;
  final List<String> actions;
  final ValueChanged<String>? onTimeframeTap;
  final ValueChanged<String>? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StaticChipScroller(
          items: timeframes,
          selectedIndex: timeframes.length > 1 ? 1 : 0,
          dense: true,
          onTap: onTimeframeTap,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List<Widget>.generate(actions.length, (int index) {
            final String label = actions[index];
            return _StaticChoiceChip(
              label: label,
              selected: index == 0,
              dense: true,
              onTap: onActionTap == null ? null : () => onActionTap!(label),
            );
          }),
        ),
      ],
    );
  }
}

/// 图例条目结构，描述指标名称与最新值。
class _IndicatorLegendEntry {
  const _IndicatorLegendEntry({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

/// 图例显示组件，位于图表顶部说明各条均线。
class _IndicatorLegend extends StatelessWidget {
  const _IndicatorLegend({required this.entries});

  final List<_IndicatorLegendEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: entries
          .map(
            (_IndicatorLegendEntry entry) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: entry.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${entry.label} ${entry.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: entry.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// 移动平均线的数据集合，包含标签、颜色和计算值。
class _MovingAverage {
  _MovingAverage({required this.label, required this.color, required this.values});

  final String label;
  final Color color;
  final List<double?> values;
}

/// 图表下方徽章的数据模型。
class _ChartMetricBadgeData {
  const _ChartMetricBadgeData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

/// 图表下方的徽章列表，展示成交量等附加指标。
class _ChartMetricBadges extends StatelessWidget {
  const _ChartMetricBadges({required this.badges});

  final List<_ChartMetricBadgeData> badges;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: badges
          .map((badge) => _ChartMetricBadge(data: badge))
          .toList(),
    );
  }
}

/// 单个指标徽章，强调关键指标与颜色。
class _ChartMetricBadge extends StatelessWidget {
  const _ChartMetricBadge({required this.data});

  final _ChartMetricBadgeData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '${data.label} ${data.value}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: data.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 图表详情卡片，列出资金费率、多空比等信息。
class _ChartDetailCard extends StatelessWidget {
  const _ChartDetailCard({required this.items});

  final List<_DetailItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (_DetailItem item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      item.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: item.valueColor ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// 图表详情卡片内的单行数据模型。
class _DetailItem {
  const _DetailItem({required this.title, required this.value, this.valueColor});

  final String title;
  final String value;
  final Color? valueColor;
}

/// 包含蜡烛图与成交量柱状图的组合卡片。
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.candles, required this.movingAverages});

  final List<_ChartCandle> candles;
  final List<_MovingAverage> movingAverages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color gridColor = theme.colorScheme.outline.withOpacity(0.16);
    return AspectRatio(
      aspectRatio: 1.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          color: theme.colorScheme.surface,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: CustomPaint(
                  painter: _CandlestickPainter(
                    candles: candles,
                    movingAverages: movingAverages,
                    bullColor: const Color(0xFF26A69A),
                    bearColor: const Color(0xFFE53935),
                    gridLineColor: gridColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CustomPaint(
                  painter: _VolumePainter(
                    candles: candles,
                    bullColor: const Color(0xFF26A69A),
                    bearColor: const Color(0xFFE53935),
                    gridLineColor: gridColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 简化的蜡烛图数据结构，来源于后端或本地示例数据。
class _ChartCandle {
  const _ChartCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
}

final List<_ChartCandle> _sampleEthCandles = _generateSampleCandles();

/// 生成一组示例蜡烛数据，模拟 ETH 在不同时间点的价格波动。
List<_ChartCandle> _generateSampleCandles() {
  final DateTime start = DateTime.now().subtract(const Duration(hours: 38));
  final List<int> deltas = <int>[
    12,
    -8,
    15,
    -6,
    4,
    10,
    -12,
    16,
    -5,
    8,
    -3,
    6,
    -14,
    18,
    -9,
    5,
    7,
    -11,
    14,
    -4,
  ];

  double lastClose = 4460;
  final List<_ChartCandle> candles = <_ChartCandle>[];
  for (int i = 0; i < deltas.length; i++) {
    final double open = lastClose;
    final double close = open + deltas[i];
    final double high = max(open, close) + 18;
    final double low = min(open, close) - 18;
    final double volume = 160000 + (i % 5) * 22000 + deltas[i].abs() * 1200;
    candles.add(
      _ChartCandle(
        time: start.add(Duration(hours: i * 2)),
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ),
    );
    lastClose = close;
  }
  return candles;
}

/// 根据收盘价计算简单移动平均，用于展示 MA 指标。
List<double?> _calculateMovingAverage(List<_ChartCandle> candles, int period) {
  final List<double?> averages = List<double?>.filled(candles.length, null);
  if (candles.isEmpty) {
    return averages;
  }

  double sum = 0;
  for (int i = 0; i < candles.length; i++) {
    sum += candles[i].close;
    if (i >= period) {
      sum -= candles[i - period].close;
    }
    if (i >= period - 1) {
      averages[i] = sum / period;
    }
  }
  return averages;
}

/// 自定义蜡烛图绘制器，负责绘制 K 线与均线轨迹。
class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.candles,
    required this.movingAverages,
    required this.bullColor,
    required this.bearColor,
    required this.gridLineColor,
  });

  final List<_ChartCandle> candles;
  final List<_MovingAverage> movingAverages;
  final Color bullColor;
  final Color bearColor;
  final Color gridLineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) {
      return;
    }

    final Paint gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 1;
    const int horizontalLines = 4;
    for (int i = 0; i <= horizontalLines; i++) {
      final double dy = size.height / horizontalLines * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    double maxPrice = candles.first.high;
    double minPrice = candles.first.low;
    for (final _ChartCandle candle in candles) {
      if (candle.high > maxPrice) {
        maxPrice = candle.high;
      }
      if (candle.low < minPrice) {
        minPrice = candle.low;
      }
    }
    final double priceRange = (maxPrice - minPrice).abs() < 0.001
        ? 1
        : maxPrice - minPrice;

    final double stepX = size.width / candles.length;
    final double bodyWidth = stepX * 0.6;

    final Paint wickPaint = Paint()..strokeWidth = 1.2;
    final Paint bodyPaint = Paint();

    for (int i = 0; i < candles.length; i++) {
      final _ChartCandle candle = candles[i];
      final double x = stepX * (i + 0.5);
      final double highY = _priceToY(
        candle.high,
        size.height,
        minPrice,
        priceRange,
      );
      final double lowY = _priceToY(
        candle.low,
        size.height,
        minPrice,
        priceRange,
      );
      final double openY = _priceToY(
        candle.open,
        size.height,
        minPrice,
        priceRange,
      );
      final double closeY = _priceToY(
        candle.close,
        size.height,
        minPrice,
        priceRange,
      );
      final bool isBull = candle.close >= candle.open;
      final Color color = isBull ? bullColor : bearColor;

      wickPaint.color = color;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      final double top = min(openY, closeY);
      final double bottom = max(openY, closeY);
      final double bodyHeight = (bottom - top).abs();

      if (bodyHeight < 1) {
        final double centerY = (openY + closeY) / 2;
        canvas.drawLine(
          Offset(x - bodyWidth / 2, centerY),
          Offset(x + bodyWidth / 2, centerY),
          Paint()
            ..color = color
            ..strokeWidth = 2,
        );
      } else {
        bodyPaint
          ..color = color.withOpacity(0.9)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(x - bodyWidth / 2, top, x + bodyWidth / 2, bottom),
            const Radius.circular(3),
          ),
          bodyPaint,
        );
      }
    }

    for (final _MovingAverage ma in movingAverages) {
      final List<double?> values = ma.values;
      if (values.isEmpty) {
        continue;
      }
      final Path path = Path();
      bool hasStarted = false;
      for (int i = 0; i < values.length; i++) {
        final double? value = values[i];
        if (value == null) {
          continue;
        }
        final double x = stepX * (i + 0.5);
        final double y = _priceToY(value, size.height, minPrice, priceRange);
        if (!hasStarted) {
          path.moveTo(x, y);
          hasStarted = true;
        } else {
          path.lineTo(x, y);
        }
      }
      final Paint maPaint = Paint()
        ..color = ma.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawPath(path, maPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 成交量柱状图绘制器，位于蜡烛图下方展示量能。
class _VolumePainter extends CustomPainter {
  _VolumePainter({
    required this.candles,
    required this.bullColor,
    required this.bearColor,
    required this.gridLineColor,
  });

  final List<_ChartCandle> candles;
  final Color bullColor;
  final Color bearColor;
  final Color gridLineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) {
      return;
    }

    final Paint gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), gridPaint);

    double maxVolume = candles.first.volume;
    for (final _ChartCandle candle in candles) {
      if (candle.volume > maxVolume) {
        maxVolume = candle.volume;
      }
    }
    final double stepX = size.width / candles.length;
    final double barWidth = stepX * 0.6;

    for (int i = 0; i < candles.length; i++) {
      final _ChartCandle candle = candles[i];
      final bool isBull = candle.close >= candle.open;
      final Paint paint = Paint()
        ..color = (isBull ? bullColor : bearColor).withOpacity(0.75);
      final double height = maxVolume == 0 ? 0 : candle.volume / maxVolume * size.height;
      final double x = stepX * (i + 0.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            x - barWidth / 2,
            size.height - height,
            x + barWidth / 2,
            size.height,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 图表内使用的静态 Chip 滚动选择器。
class _StaticChipScroller extends StatelessWidget {
  const _StaticChipScroller({
    required this.items,
    this.selectedIndex = 0,
    this.onTap,
    this.dense = false,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<String>? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final double height = dense ? 34 : 38;
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _StaticChoiceChip(
            label: items[index],
            selected: index == selectedIndex,
            dense: dense,
            onTap: onTap == null ? null : () => onTap!(items[index]),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
      ),
    );
  }
}

/// 带有选中态的静态 Chip 组件。
class _StaticChoiceChip extends StatelessWidget {
  const _StaticChoiceChip({
    required this.label,
    required this.selected,
    this.onTap,
    this.dense = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final EdgeInsets padding = dense
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withOpacity(0.12)
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

double _priceToY(
  double price,
  double height,
  double minPrice,
  double priceRange,
) {
  return height - ((price - minPrice) / priceRange) * height;
}
