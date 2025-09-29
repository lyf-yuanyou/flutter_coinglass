import 'package:flutter/material.dart';

import 'package:coinglass_app/src/data/models.dart';
import 'package:coinglass_app/src/presentation/home/home_controller.dart';
import 'package:coinglass_app/src/presentation/home/home_formatters.dart';
import 'package:coinglass_app/src/presentation/home/home_state.dart';
import 'package:coinglass_app/src/presentation/home/shared/home_data_view.dart';
import 'package:coinglass_app/src/presentation/home/shared/shared_widgets.dart';

/// 行情标签页模块，展示合约币种列表及筛选条件。
class MarketModule extends StatelessWidget {
  const MarketModule({
    super.key,
    required this.controller,
    required this.formatters,
    required this.onRefresh,
    required this.onShowComingSoon,
    required this.segmentLabels,
    required this.filterLabels,
  });

  final HomeController controller;
  final HomeFormatters formatters;
  final Future<void> Function() onRefresh;
  final VoidCallback onShowComingSoon;
  final List<String> segmentLabels;
  final List<String> filterLabels;

  @override
  Widget build(BuildContext context) {
    return HomeDataView(
      controller: controller,
      onRefresh: onRefresh,
      builder: (BuildContext context, HomeDashboardData data) {
        final List<CoinMetrics> coins = data.metrics;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: <Widget>[
            const SizedBox(height: 12),
            _MarketHeader(
              onSearchTap: onShowComingSoon,
              onFilterTap: onShowComingSoon,
            ),
            const SizedBox(height: 16),
            _StaticChipScroller(
              items: segmentLabels,
              onTap: (_) => onShowComingSoon(),
            ),
            const SizedBox(height: 12),
            _StaticChipScroller(
              items: filterLabels,
              dense: true,
              onTap: (_) => onShowComingSoon(),
            ),
            const SizedBox(height: 20),
            const _MarketListHeader(),
            const Divider(height: 1),
            const SizedBox(height: 4),
            if (coins.isEmpty)
              const EmptyState(
                  description: '暂无行情数据，稍后再试试~', icon: Icons.show_chart)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: coins.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final CoinMetrics coin = coins[index];
                  final String changeText =
                      formatters.formatPercent(coin.change24h);
                  final Color changeColor = coin.change24h >= 0
                      ? const Color(0xFF26A69A)
                      : const Color(0xFFE53935);

                  return _MarketCoinTile(
                    metric: coin,
                    priceText: formatters.formatMarketPrice(coin.price),
                    openInterestText:
                        formatters.formatLargeNumber(coin.openInterest),
                    volumeText: formatters.formatLargeNumber(coin.volume24h),
                    changeText: changeText,
                    changeColor: changeColor,
                    accentColor: formatters.colorForSymbol(coin.symbol),
                    onTap: onShowComingSoon,
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

/// 行情页头部，包含标题与搜索/筛选入口。
class _MarketHeader extends StatelessWidget {
  const _MarketHeader({required this.onSearchTap, required this.onFilterTap});

  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '加密货币',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '全球热门币种实时行情',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const Spacer(),
        _RoundIconButton(icon: Icons.search, onTap: onSearchTap),
        const SizedBox(width: 12),
        _RoundIconButton(icon: Icons.tune, onTap: onFilterTap),
      ],
    );
  }
}

/// 圆形图标按钮，提供搜索和筛选等操作入口。
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
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

/// 固定选项的横向 Chip 选择器，主要用于展示分组标签。
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

/// 封装的静态 Chip 样式，支持密集模式与点击回调。
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

/// 行情列表的表头行，标注币种/价格/涨跌幅列。
class _MarketListHeader extends StatelessWidget {
  const _MarketListHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(child: Text('币种', style: style)),
          SizedBox(
            width: 96,
            child: Text('价格', style: style, textAlign: TextAlign.right),
          ),
          SizedBox(
            width: 96,
            child: Text('24h涨跌', style: style, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

/// 单个币种的行情条目，展示价格、持仓量等关键信息。
class _MarketCoinTile extends StatelessWidget {
  const _MarketCoinTile({
    required this.metric,
    required this.priceText,
    required this.openInterestText,
    required this.volumeText,
    required this.changeText,
    required this.changeColor,
    required this.accentColor,
    required this.onTap,
  });

  final CoinMetrics metric;
  final String priceText;
  final String openInterestText;
  final String volumeText;
  final String changeText;
  final Color changeColor;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 20,
              backgroundColor: accentColor.withOpacity(0.2),
              child: Text(
                metric.symbol.characters.take(2).join().toUpperCase(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    metric.symbol,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'OI ${openInterestText} · 24h量 ${volumeText}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    priceText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    changeText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
