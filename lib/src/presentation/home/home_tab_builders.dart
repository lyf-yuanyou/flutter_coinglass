part of home_screen;

mixin HomeTabBuilders on State<HomeScreen> {
  String _formatLargeNumber(double value) {
    final double absValue = value.abs();
    if (absValue >= 1e12) {
      return '${(value / 1e12).toStringAsFixed(2)}万亿';
    }
    if (absValue >= 1e8) {
      return '${(value / 1e8).toStringAsFixed(2)}亿';
    }
    if (absValue >= 1e4) {
      return '${(value / 1e4).toStringAsFixed(2)}万';
    }
    if (absValue >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(2)}K';
    }
    if (absValue == value) {
      return value.toStringAsFixed(value >= 100 ? 0 : 2);
    }
    return value.toStringAsFixed(2);
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

  Widget _buildDataDrivenView(
    Widget Function(BuildContext context, _DashboardData data) builder,
  ) {
    return SafeArea(
      child: Obx(() {
        final bool isLoading = controller.isLoading.value;
        final _DashboardData? data = controller.dashboardData.value;
        final Object? error = controller.error.value;

        if (isLoading && data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && data == null) {
          return _ErrorState(error: error, onRetry: refreshAll);
        }

        if (data == null) {
          return const SizedBox.shrink();
        }

        return RefreshIndicator(
          onRefresh: refreshAll,
          child: builder(context, data),
        );
      }),
    );
  }

  String _formatMarketPrice(double price) {
    final double abs = price.abs();
    if (abs >= 1000) {
      return wholeNumberFormat.format(price);
    }
    if (abs >= 1) {
      return twoDecimalFormat.format(price);
    }
    return smallNumberFormat.format(price);
  }

  String _formatPercent(double value) {
    final String prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }

  Color _colorForSymbol(String symbol) {
    if (symbol.isEmpty) {
      return Colors.blueGrey;
    }
    final int code = symbol.codeUnitAt(0);
    const List<Color> palette = <Color>[
      Color(0xFFFF9800),
      Color(0xFF2196F3),
      Color(0xFF9C27B0),
      Color(0xFF4CAF50),
      Color(0xFFE91E63),
      Color(0xFF00BCD4),
      Color(0xFF3F51B5),
    ];
    return palette[code % palette.length];
  }

  CoinMetrics? _findCoin(List<CoinMetrics> metrics, String symbol) {
    for (final CoinMetrics coin in metrics) {
      if (coin.symbol.toUpperCase() == symbol.toUpperCase()) {
        return coin;
      }
    }
    return null;
  }

  FundingRate? _findFundingRate(List<FundingRate> rates, String symbol) {
    for (final FundingRate rate in rates) {
      if (rate.symbol.toUpperCase() == symbol.toUpperCase()) {
        return rate;
      }
    }
    return null;
  }

  double? _latestNonNull(List<double?> values) {
    for (int i = values.length - 1; i >= 0; i--) {
      final double? value = values[i];
      if (value != null) {
        return value;
      }
    }
    return null;
  }

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

  Widget _buildDashboard(BuildContext context) {
    return _buildDataDrivenView((context, data) {
      final displayedMetrics = data.metrics.take(6).toList();
      final List<_IndicatorItemData> indicatorItems = displayedMetrics
          .map(
            (CoinMetrics metric) => _IndicatorItemData(
              emoji: _emojiForChange(metric.change24h),
              title: '${metric.symbol} 永续合约',
              primaryValue: _formatLargeNumber(metric.openInterest),
              valueLabel: '持仓量',
              trend: metric.change24h,
              highlights: <String>[
                '24h成交 ${_formatLargeNumber(metric.volume24h)}',
                '多空比 ${metric.longShortRatio.toStringAsFixed(2)}',
                '价格 ${priceFormat.format(metric.price)}',
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
            onNotificationTap: openReminderCenter,
            onMoreTap: showComingSoon,
          ),
          const SizedBox(height: 16),
          _SearchField(onTap: showComingSoon),
          const SizedBox(height: 16),
          const _CategoryScroller(categories: _categoryLabels),
          const SizedBox(height: 24),
          TopMoversSection(controller: marketController),
          const SizedBox(height: 24),
          if (indicatorItems.isEmpty)
            _EmptyState(description: '暂无热门指标数据，稍后再试试~', icon: Icons.bar_chart)
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
    });
  }

  Widget _buildMarketHome(BuildContext context) {
    return _buildDataDrivenView((context, data) {
      final List<CoinMetrics> coins = data.metrics;

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          const SizedBox(height: 12),
          _MarketHeader(
            onSearchTap: showComingSoon,
            onFilterTap: showComingSoon,
          ),
          const SizedBox(height: 16),
          _StaticChipScroller(
            items: _marketSegmentLabels,
            onTap: (_) => showComingSoon(),
          ),
          const SizedBox(height: 12),
          _StaticChipScroller(
            items: _marketFilterLabels,
            dense: true,
            onTap: (_) => showComingSoon(),
          ),
          const SizedBox(height: 20),
          const _MarketListHeader(),
          const Divider(height: 1),
          const SizedBox(height: 4),
          if (coins.isEmpty)
            _EmptyState(description: '暂无行情数据，稍后再试试~', icon: Icons.show_chart)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: coins.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final CoinMetrics coin = coins[index];
                final String changeText = _formatPercent(coin.change24h);
                final Color changeColor = coin.change24h >= 0
                    ? _positiveTrendColor
                    : _negativeTrendColor;

                return _MarketCoinTile(
                  metric: coin,
                  priceText: _formatMarketPrice(coin.price),
                  openInterestText: _formatLargeNumber(coin.openInterest),
                  volumeText: _formatLargeNumber(coin.volume24h),
                  changeText: changeText,
                  changeColor: changeColor,
                  accentColor: _colorForSymbol(coin.symbol),
                  onTap: showComingSoon,
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildChartHome(BuildContext context) {
    return _buildDataDrivenView((context, data) {
      if (data.metrics.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: const <Widget>[
            SizedBox(height: 60),
            _EmptyState(description: '暂无图表数据，稍后再试试~', icon: Icons.show_chart),
          ],
        );
      }

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
      final String fundingText =
          fundingRate == null ? '--' : _formatPercent(fundingPercent);
      final Color? fundingColor = fundingRate == null
          ? null
          : (fundingPercent >= 0 ? _positiveTrendColor : _negativeTrendColor);

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
              value: _formatMarketPrice(latest),
              color: ma.color,
            );
          })
          .whereType<_IndicatorLegendEntry>()
          .toList();

      final List<_StatItem> statItems = <_StatItem>[
        _StatItem(label: '24h最高', value: _formatMarketPrice(highestPrice)),
        _StatItem(label: '24h最低', value: _formatMarketPrice(lowestPrice)),
        _StatItem(label: '24h成交量', value: _formatLargeNumber(coin.volume24h)),
        _StatItem(label: '资金费率', value: fundingText, valueColor: fundingColor),
        _StatItem(label: '多空比', value: coin.longShortRatio.toStringAsFixed(2)),
        _StatItem(label: '持仓量', value: _formatLargeNumber(coin.openInterest)),
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
            onBackTap: showComingSoon,
            onFavouriteTap: showComingSoon,
            onShareTap: showComingSoon,
          ),
          const SizedBox(height: 16),
          _PriceOverview(
            priceText: _formatMarketPrice(coin.price),
            changeText: _formatPercent(coin.change24h),
            changeColor:
                coin.change24h >= 0 ? _positiveTrendColor : _negativeTrendColor,
            currencyText: priceFormat.format(coin.price),
          ),
          const SizedBox(height: 16),
          _StatsGrid(items: statItems),
          const SizedBox(height: 20),
          _ChartToolbar(
            timeframes: _chartTimeframes,
            actions: _chartActionLabels,
            onTimeframeTap: (_) => showComingSoon(),
            onActionTap: (_) => showComingSoon(),
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
                value: _formatLargeNumber(lastVolume),
                color: _positiveTrendColor,
              ),
              _ChartMetricBadgeData(
                label: 'VOL(20)',
                value: _formatLargeNumber(averageVolume),
                color: _negativeTrendColor,
              ),
              _ChartMetricBadgeData(
                label: '成交额',
                value: _formatLargeNumber(coin.volume24h),
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
                value: _formatLargeNumber(coin.volume24h),
              ),
              _DetailItem(
                title: '持仓量',
                value: _formatLargeNumber(coin.openInterest),
              ),
            ],
            onTap: () {},
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildNewsHome(BuildContext context) {
    return SafeArea(
      child: MarketNewsList(controller: marketController),
    );
  }

  HomeController get controller;
  MarketController get marketController;
  NumberFormat get priceFormat;
  NumberFormat get wholeNumberFormat;
  NumberFormat get twoDecimalFormat;
  NumberFormat get smallNumberFormat;
  Future<void> Function() get refreshAll;
  VoidCallback get showComingSoon;
  VoidCallback get openReminderCenter;
}

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
