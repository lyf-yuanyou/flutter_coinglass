import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:coinglass_app/src/data/coinglass_api.dart';
import 'package:coinglass_app/src/data/repositories/market_repository.dart';
import 'package:coinglass_app/src/presentation/home/dashboard/dashboard_module.dart';
import 'package:coinglass_app/src/presentation/home/chart/chart_module.dart';
import 'package:coinglass_app/src/presentation/home/home_controller.dart';
import 'package:coinglass_app/src/presentation/home/home_formatters.dart';
import 'package:coinglass_app/src/presentation/home/market/market_module.dart';
import 'package:coinglass_app/src/presentation/home/news/news_module.dart';
import 'package:coinglass_app/src/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:coinglass_app/src/presentation/home/profile/profile_module.dart';
import 'package:coinglass_app/src/presentation/controllers/market_controller.dart';
import 'package:coinglass_app/src/router/app_pages.dart' show AppRoutes;

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
  late final HomeFormatters _formatters;

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

    _formatters = HomeFormatters(
      priceFormat: _priceFormat,
      wholeNumberFormat: _wholeNumberFormat,
      twoDecimalFormat: _twoDecimalFormat,
      smallNumberFormat: _smallNumberFormat,
    );
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
            DashboardModule(
              controller: _controller,
              marketController: _marketController,
              onRefresh: _refresh,
              onShowComingSoon: _showComingSoon,
              onOpenReminder: _openReminderCenter,
              formatters: _formatters,
              categoryLabels: _categoryLabels,
            ),
            MarketModule(
              controller: _controller,
              formatters: _formatters,
              onRefresh: _refresh,
              onShowComingSoon: _showComingSoon,
              segmentLabels: _marketSegmentLabels,
              filterLabels: _marketFilterLabels,
            ),
            ChartModule(
              controller: _controller,
              formatters: _formatters,
              onRefresh: _refresh,
              onShowComingSoon: _showComingSoon,
              timeframes: _chartTimeframes,
              actions: _chartActionLabels,
            ),
            NewsModule(marketController: _marketController),
            ProfileModule(
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


