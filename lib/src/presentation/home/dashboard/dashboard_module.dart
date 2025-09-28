import 'package:flutter/material.dart';

import 'package:coinglass_app/src/data/models.dart';
import 'package:coinglass_app/src/presentation/controllers/market_controller.dart';
import 'package:coinglass_app/src/presentation/widgets/top_movers_section.dart';
import 'package:coinglass_app/src/presentation/home/home_controller.dart';
import 'package:coinglass_app/src/presentation/home/home_formatters.dart';
import 'package:coinglass_app/src/presentation/home/home_state.dart';
import 'package:coinglass_app/src/presentation/home/shared/home_data_view.dart';
import 'package:coinglass_app/src/presentation/home/shared/shared_widgets.dart';

class DashboardModule extends StatelessWidget {
  const DashboardModule({
    super.key,
    required this.controller,
    required this.marketController,
    required this.onRefresh,
    required this.onShowComingSoon,
    required this.onOpenReminder,
    required this.formatters,
    required this.categoryLabels,
  });

  final HomeController controller;
  final MarketController marketController;
  final Future<void> Function() onRefresh;
  final VoidCallback onShowComingSoon;
  final VoidCallback onOpenReminder;
  final HomeFormatters formatters;
  final List<String> categoryLabels;

  @override
  Widget build(BuildContext context) {
    return HomeDataView(
      controller: controller,
      onRefresh: onRefresh,
      builder: (BuildContext context, HomeDashboardData data) {
          final List<_IndicatorItemData> indicatorItems = data.metrics
              .take(6)
              .map(
                (CoinMetrics metric) => _IndicatorItemData(
                  emoji: _emojiForChange(metric.change24h),
                  title: '${metric.symbol} 永续合约',
                  primaryValue: formatters.formatLargeNumber(metric.openInterest),
                  valueLabel: '持仓量',
                  trend: metric.change24h,
                  highlights: <String>[
                    '24h成交 ${formatters.formatLargeNumber(metric.volume24h)}',
                    '多空比 ${metric.longShortRatio.toStringAsFixed(2)}',
                    '价格 ${formatters.priceFormat.format(metric.price)}',
                  ],
                ),
              )
              .toList();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: <Widget>[
              const SizedBox(height: 12),
              _HomeHeader(
                onNotificationTap: onOpenReminder,
                onMoreTap: onShowComingSoon,
              ),
              const SizedBox(height: 16),
              _SearchField(onTap: onShowComingSoon),
              const SizedBox(height: 16),
              _CategoryScroller(categories: categoryLabels),
              const SizedBox(height: 24),
              TopMoversSection(controller: marketController),
              const SizedBox(height: 24),
              if (indicatorItems.isEmpty)
                const EmptyState(description: '暂无热门指标数据，稍后再试试~', icon: Icons.bar_chart)
              else
                ...indicatorItems
                    .map(
                      (_IndicatorItemData item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IndicatorTile(data: item),
                      ),
                    )
                    .toList(),
              const SizedBox(height: 32),
            ],
          );
        },
    );
  }

  String _emojiForChange(double change) {
    if (change >= 5) {
      return '🚀';
    }
    if (change >= 0.5) {
      return '😄';
    }
    if (change <= -5) {
      return '💣';
    }
    if (change < 0) {
      return '😟';
    }
    return '😐';
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onNotificationTap, required this.onMoreTap});

  final VoidCallback onNotificationTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '指标',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '掌握全球合约市场的实时动态',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const Spacer(),
        _RoundIconButton(
          icon: Icons.notifications_none_outlined,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: 12),
        _RoundIconButton(icon: Icons.more_horiz, onTap: onMoreTap),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color backgroundColor = theme.colorScheme.surface;
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: '搜索币种',
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryScroller extends StatelessWidget {
  const _CategoryScroller({required this.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _CategoryChip(label: categories[index], selected: index == 0);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color textColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.4)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _IndicatorItemData {
  const _IndicatorItemData({
    required this.emoji,
    required this.title,
    required this.primaryValue,
    required this.valueLabel,
    required this.trend,
    required this.highlights,
  });

  final String emoji;
  final String title;
  final String primaryValue;
  final String valueLabel;
  final double trend;
  final List<String> highlights;
}

class _IndicatorTile extends StatelessWidget {
  const _IndicatorTile({required this.data});

  final _IndicatorItemData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Color> gradientColors = _gradientForTrend(context, data.trend);
    final Color changeColor = data.trend >= 0
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final String changeText = data.trend >= 0
        ? '+${data.trend.toStringAsFixed(2)}%'
        : data.trend.toStringAsFixed(2)+'%';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(data.emoji, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.valueLabel} ${data.primaryValue}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: data.highlights
                        .map((highlight) => _InfoBadge(text: highlight))
                        .toList(),
                  ),
                ),
                _ChangeBadge(color: changeColor, text: changeText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<Color> _gradientForTrend(BuildContext context, double trend) {
  final theme = Theme.of(context);
  if (trend > 0) {
    return <Color>[
      theme.colorScheme.primary.withOpacity(0.18),
      theme.colorScheme.primary.withOpacity(0.08),
    ];
  }
  if (trend < 0) {
    return <Color>[Colors.red.shade100, Colors.red.shade50];
  }
  return <Color>[
    theme.colorScheme.surfaceVariant.withOpacity(0.5),
    theme.colorScheme.surfaceVariant.withOpacity(0.2),
  ];
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
