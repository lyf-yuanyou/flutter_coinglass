import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/coinglass_api.dart';
import '../data/models.dart';
import '../data/repositories/market_repository.dart';
import '../router/app_pages.dart' show AppRoutes;
import 'controllers/market_controller.dart';
import 'my_profile_tab.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/top_movers_section.dart';
import 'widgets/market_news_list.dart';

const List<String> _categoryLabels = <String>[
  '首页',
  '清算地图',
  '爆仓信息',
  '多空比',
  '资金费率',
];

const List<String> _marketSegmentLabels = <String>[
  'Hyperliquid',
  '指数',
  'ETFs',
  '筛选',
];

const List<String> _marketFilterLabels = <String>['自选', '持仓量排行', '份额', '交易所'];

const List<String> _chartTimeframes = <String>[
  '分时',
  '15m',
  '30m',
  '4H',
  '1D',
  '更多',
];

const List<String> _chartActionLabels = <String>['指标', '深度', '成交'];

const Color _positiveTrendColor = Color(0xFF26A69A);
const Color _negativeTrendColor = Color(0xFFE53935);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;
  late final MarketController _marketController;

  final NumberFormat _priceFormat = NumberFormat.simpleCurrency(
    decimalDigits: 2,
  );
  final NumberFormat _wholeNumberFormat = NumberFormat('#,##0');
  final NumberFormat _twoDecimalFormat = NumberFormat('#,##0.00');
  final NumberFormat _smallNumberFormat = NumberFormat('#,##0.0000');

  static const List<CustomBottomNavItem> _navItems = <CustomBottomNavItem>[
    CustomBottomNavItem(icon: Icons.analytics_outlined, label: '首页'),
    CustomBottomNavItem(icon: Icons.public, label: '行情'),
    CustomBottomNavItem(icon: Icons.warning_amber_outlined, label: '图表'),
    CustomBottomNavItem(icon: Icons.trending_up, label: '新闻'),
    CustomBottomNavItem(
      icon: Icons.account_balance_wallet_outlined,
      label: '我的',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController(Get.find<CoinGlassRepository>()));
    }
    _controller = Get.find<HomeController>();

    // 热门币种模块依赖单独的仓库与控制器，这里做懒加载注册。
    if (!Get.isRegistered<MarketController>()) {
      Get.put<MarketController>(
        MarketController(Get.find<MarketRepository>()),
      );
    }
    _marketController = Get.find<MarketController>();
  }

  /// 下拉刷新：并行刷新仪表盘数据与热门币种。
  Future<void> _refresh() async {
    await Future.wait(<Future<void>>[
      _controller.refreshDashboard(),
      _marketController.loadTopMovers(),
    ]);
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('功能开发中，敬请期待。')));
  }

  void _openLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void _openReminderCenter() {
    Get.toNamed(AppRoutes.reminder);
  }

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
        final bool isLoading = _controller.isLoading.value;
        final _DashboardData? data = _controller.dashboardData.value;
        final Object? error = _controller.error.value;

        if (isLoading && data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null && data == null) {
          return _ErrorState(error: error, onRetry: _refresh);
        }

        if (data == null) {
          return const SizedBox.shrink();
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: builder(context, data),
        );
      }),
    );
  }

  String _formatMarketPrice(double price) {
    final double abs = price.abs();
    if (abs >= 1000) {
      return _wholeNumberFormat.format(price);
    }
    if (abs >= 1) {
      return _twoDecimalFormat.format(price);
    }
    return _smallNumberFormat.format(price);
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
                '价格 ${_priceFormat.format(metric.price)}',
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
            onNotificationTap: _openReminderCenter,
            onMoreTap: _showComingSoon,
          ),
          const SizedBox(height: 16),
          _SearchField(onTap: _showComingSoon),
          const SizedBox(height: 16),
          const _CategoryScroller(categories: _categoryLabels),
          const SizedBox(height: 24),
          TopMoversSection(controller: _marketController),
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
            onSearchTap: _showComingSoon,
            onFilterTap: _showComingSoon,
          ),
          const SizedBox(height: 16),
          _StaticChipScroller(
            items: _marketSegmentLabels,
            onTap: (_) => _showComingSoon(),
          ),
          const SizedBox(height: 12),
          _StaticChipScroller(
            items: _marketFilterLabels,
            dense: true,
            onTap: (_) => _showComingSoon(),
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
                  onTap: _showComingSoon,
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
      final String fundingText = fundingRate == null
          ? '--'
          : _formatPercent(fundingPercent);
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
            onBackTap: _showComingSoon,
            onFavouriteTap: _showComingSoon,
            onShareTap: _showComingSoon,
          ),
          const SizedBox(height: 16),
          _PriceOverview(
            priceText: _formatMarketPrice(coin.price),
            changeText: _formatPercent(coin.change24h),
            changeColor: coin.change24h >= 0
                ? _positiveTrendColor
                : _negativeTrendColor,
            currencyText: _priceFormat.format(coin.price),
          ),
          const SizedBox(height: 16),
          _StatsGrid(items: statItems),
          const SizedBox(height: 20),
          _ChartToolbar(
            timeframes: _chartTimeframes,
            actions: _chartActionLabels,
            onTimeframeTap: (_) => _showComingSoon(),
            onActionTap: (_) => _showComingSoon(),
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
            onTap: _showComingSoon,
          ),
          const SizedBox(height: 32),
        ],
      );
    });
  }

  Widget _buildNewsHome(BuildContext context) {
    return SafeArea(
      child: MarketNewsList(controller: _marketController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
        theme.brightness == Brightness.dark ? 0.3 : 1,
      ),
      body: Obx(() {
        return IndexedStack(
          index: _controller.currentIndex.value,
          children: <Widget>[
            _buildDashboard(context),
            _buildMarketHome(context),
            _buildChartHome(context),
            _buildNewsHome(context),
            MyProfileTab(
              onLoginTap: _openLogin,
              onPlaceholderTap: _showComingSoon,
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => CustomBottomNavBar(
          items: _navItems,
          currentIndex: _controller.currentIndex.value,
          onTap: _controller.setIndex,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<HomeController>()) {
      Get.delete<HomeController>();
    }
    super.dispose();
  }
}

class HomeController extends GetxController {
  HomeController(this._repository);

  final CoinGlassRepository _repository;

  final RxBool isLoading = true.obs;
  final Rx<_DashboardData?> dashboardData = Rx<_DashboardData?>(null);
  final Rx<Object?> error = Rx<Object?>(null);
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    try {
      isLoading.value = true;
      error.value = null;

      final metrics = await _repository.fetchCoinMetrics();
      final fundingRates = await _repository.fetchFundingRates();
      final liquidation = await _repository.fetchLiquidationStats();

      dashboardData.value = _DashboardData(
        metrics: metrics,
        fundingRates: fundingRates,
        liquidation: liquidation,
      );
    } catch (e) {
      error.value = e;
    } finally {
      isLoading.value = false;
    }
  }

  void setIndex(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
    }
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

List<double?> _calculateMovingAverage(List<_ChartCandle> candles, int period) {
  if (candles.isEmpty || period <= 0) {
    return <double?>[];
  }
  final List<double?> values = List<double?>.filled(candles.length, null);
  double sum = 0;
  for (int i = 0; i < candles.length; i++) {
    sum += candles[i].close;
    if (i >= period) {
      sum -= candles[i - period].close;
    }
    if (i >= period - 1) {
      values[i] = sum / period;
    }
  }
  return values;
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
