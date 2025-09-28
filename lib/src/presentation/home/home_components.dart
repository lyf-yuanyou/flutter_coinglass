part of home_screen;

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
    final String abbreviation = metric.symbol.length > 3
        ? metric.symbol.substring(0, 3)
        : metric.symbol;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 22,
              backgroundColor: accentColor.withOpacity(0.12),
              child: Text(
                abbreviation,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '持仓量 $openInterestText',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '多空比 ${metric.longShortRatio.toStringAsFixed(2)}',
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
                  priceText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    changeText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '24h成交 $volumeText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
        _RoundIconButton(icon: Icons.chevron_left, onTap: onBackTap),
        const SizedBox(width: 12),
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
        _RoundIconButton(icon: Icons.star_border, onTap: onFavouriteTap),
        const SizedBox(width: 12),
        _RoundIconButton(icon: Icons.share_outlined, onTap: onShareTap),
        const SizedBox(width: 12),
        _RoundIconButton(icon: Icons.fullscreen, onTap: onShareTap),
      ],
    );
  }
}

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

class _StatItem {
  const _StatItem({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}

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

class _ChartMetricBadges extends StatelessWidget {
  const _ChartMetricBadges({required this.badges});

  final List<_ChartMetricBadgeData> badges;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: badges
          .map(
            (_ChartMetricBadgeData badge) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badge.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${badge.label}: ${badge.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: badge.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DetailItem {
  const _DetailItem({
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;
}

class _ChartDetailCard extends StatelessWidget {
  const _ChartDetailCard({required this.items, required this.onTap});

  final List<_DetailItem> items;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
      ),
      child: Column(
        children: List<Widget>.generate(items.length, (int index) {
          final _DetailItem item = items[index];
          final Widget tile = ListTile(
            title: Text(item.title),
            trailing: Text(
              item.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: item.valueColor ?? theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: onTap,
          );
          if (index == items.length - 1) {
            return tile;
          }
          return Column(
            children: <Widget>[
              tile,
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withOpacity(0.08),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.candles, required this.movingAverages});

  final List<_ChartCandle> candles;
  final List<_MovingAverage> movingAverages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1.4,
        child: _CandlestickChartBody(
          candles: candles,
          movingAverages: movingAverages,
        ),
      ),
    );
  }
}

class _CandlestickChartBody extends StatelessWidget {
  const _CandlestickChartBody({
    required this.candles,
    required this.movingAverages,
  });

  final List<_ChartCandle> candles;
  final List<_MovingAverage> movingAverages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color gridColor = theme.colorScheme.outline.withOpacity(0.12);
    return LayoutBuilder(
      builder: (context, constraints) {
        final double candleHeight = constraints.maxHeight * 0.68;
        return Column(
          children: <Widget>[
            SizedBox(
              height: candleHeight,
              child: CustomPaint(
                painter: _CandlestickPainter(
                  candles: candles,
                  movingAverages: movingAverages,
                  bullColor: _positiveTrendColor,
                  bearColor: _negativeTrendColor,
                  gridLineColor: gridColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: CustomPaint(
                painter: _VolumePainter(
                  candles: candles,
                  bullColor: _positiveTrendColor,
                  bearColor: _negativeTrendColor,
                  gridLineColor: gridColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

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

      final double top = openY < closeY ? openY : closeY;
      final double bottom = openY > closeY ? openY : closeY;
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
            const Radius.circular(2),
          ),
          bodyPaint,
        );
      }
    }

    for (final _MovingAverage average in movingAverages) {
      final Paint linePaint = Paint()
        ..color = average.color
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;
      final Path path = Path();
      bool started = false;
      for (int i = 0; i < average.values.length; i++) {
        final double? value = average.values[i];
        if (value == null) {
          continue;
        }
        final double x = stepX * (i + 0.5);
        final double y = _priceToY(value, size.height, minPrice, priceRange);
        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }
      if (started) {
        canvas.drawPath(path, linePaint);
      }
    }
  }

  double _priceToY(
    double price,
    double height,
    double minPrice,
    double priceRange,
  ) {
    final double normalized = (price - minPrice) / priceRange;
    return height - normalized * height;
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return true;
  }
}

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

    final Paint baseLine = Paint()
      ..color = gridLineColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      baseLine,
    );

    double maxVolume = candles.first.volume;
    for (final _ChartCandle candle in candles) {
      if (candle.volume > maxVolume) {
        maxVolume = candle.volume;
      }
    }
    if (maxVolume <= 0) {
      maxVolume = 1;
    }

    final double stepX = size.width / candles.length;
    final double barWidth = stepX * 0.5;

    for (int i = 0; i < candles.length; i++) {
      final _ChartCandle candle = candles[i];
      final bool isBull = candle.close >= candle.open;
      final double ratio = candle.volume / maxVolume;
      final double barHeight = ratio * size.height;
      final double left = stepX * (i + 0.5) - barWidth / 2;
      final Rect rect = Rect.fromLTRB(
        left,
        size.height - barHeight,
        left + barWidth,
        size.height,
      );
      final Paint paint = Paint()
        ..color = (isBull ? bullColor : bearColor).withOpacity(0.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VolumePainter oldDelegate) {
    return true;
  }
}

class _MovingAverage {
  const _MovingAverage({
    required this.label,
    required this.color,
    required this.values,
  });

  final String label;
  final Color color;
  final List<double?> values;
}

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
    final double high = (open > close ? open : close) + 18;
    final double low = (open < close ? open : close) - 18;
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

class _IndicatorItemData {
  const _IndicatorItemData({
    required this.emoji,
    required this.title,
    required this.primaryValue,
    required this.valueLabel,
    required this.trend,
    this.highlights = const <String>[],
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
    final bool isDark = theme.brightness == Brightness.dark;
    final Color shadowColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.black.withOpacity(0.05);
    final Color changeColor = data.trend > 0
        ? Colors.green.shade600
        : data.trend < 0
        ? Colors.red.shade600
        : theme.colorScheme.outline;
    final String changeText = data.trend > 0
        ? '+${data.trend.toStringAsFixed(2)}%'
        : data.trend < 0
        ? '${data.trend.toStringAsFixed(2)}%'
        : '0.00%';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: _gradientForTrend(context, data.trend),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(data.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        data.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          data.primaryValue,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.valueLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
        ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.description, required this.icon});

  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.construction,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('$title功能开发中', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '敬请期待',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
          children: <Widget>[
            Icon(Icons.wifi_off, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('无法连接到服务器', style: theme.textTheme.titleMedium),
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
