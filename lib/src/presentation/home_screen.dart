import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../data/coinglass_api.dart';
import '../data/models.dart';
import '../router/app_router.gr.dart';
import 'widgets/custom_bottom_nav_bar.dart';

const List<String> _categoryLabels = <String>[
  '首页',
  '清算地图',
  '爆仓信息',
  '多空比',
  '资金费率',
];

@RoutePage()
class HomeScreen extends StatefulWidget implements AutoRouteWrapper {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(
        HomeController(Get.find<CoinGlassRepository>()),
      );
    }
    return this;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  final NumberFormat _priceFormat =
      NumberFormat.simpleCurrency(decimalDigits: 2);

  static const List<CustomBottomNavItem> _navItems = <CustomBottomNavItem>[
    CustomBottomNavItem(icon: Icons.analytics_outlined, label: '指标'),
    CustomBottomNavItem(icon: Icons.public, label: '清算地图'),
    CustomBottomNavItem(icon: Icons.warning_amber_outlined, label: '爆仓信息'),
    CustomBottomNavItem(icon: Icons.trending_up, label: '多空比'),
    CustomBottomNavItem(
      icon: Icons.account_balance_wallet_outlined,
      label: '资金费率',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<HomeController>();
  }

  Future<void> _refresh() {
    return _controller.refreshDashboard();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('功能开发中，敬请期待。')),
      );
  }

  void _openReminderCenter() {
    context.router.push(const ReminderRoute());
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

  Widget _buildDashboard(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final Object? error = _controller.error.value;
        if (error != null) {
          return _ErrorState(
            error: error,
            onRetry: _refresh,
          );
        }

        final _DashboardData? data = _controller.dashboardData.value;
        if (data == null) {
          return const SizedBox.shrink();
        }

        final displayedMetrics = data.metrics.take(6).toList();
        final indicatorItems = displayedMetrics
            .map(
              (metric) => _IndicatorItemData(
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

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
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
              if (indicatorItems.isEmpty)
                _EmptyState(
                  description: '暂无热门指标数据，稍后再试试~',
                  icon: Icons.bar_chart,
                )
              else
                ...indicatorItems
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _IndicatorTile(data: item),
                      ),
                    )
                    .toList(),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant
          .withOpacity(theme.brightness == Brightness.dark ? 0.3 : 1),
      body: Obx(() {
        return IndexedStack(
          index: _controller.currentIndex.value,
          children: <Widget>[
            _buildDashboard(context),
            const _ComingSoonView(title: '清算地图'),
            const _ComingSoonView(title: '爆仓信息'),
            const _ComingSoonView(title: '多空比'),
            const _ComingSoonView(title: '资金费率'),
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
  const _HomeHeader({
    required this.onNotificationTap,
    required this.onMoreTap,
  });

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
        _RoundIconButton(
          icon: Icons.more_horiz,
          onTap: onMoreTap,
        ),
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
          return _CategoryChip(
            label: categories[index],
            selected: index == 0,
          );
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
    final Color shadowColor =
        isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05);
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
            child: Text(
              data.emoji,
              style: const TextStyle(fontSize: 28),
            ),
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
    return <Color>[
      Colors.red.shade100,
      Colors.red.shade50,
    ];
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
          Icon(
            icon,
            size: 48,
            color: theme.colorScheme.primary,
          ),
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
            Text(
              '$title功能开发中',
              style: theme.textTheme.titleMedium,
            ),
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
