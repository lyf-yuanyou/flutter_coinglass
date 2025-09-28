library home_screen;

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

part 'home/home_tab_builders.dart';
part 'home/home_components.dart';

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

class _HomeScreenState extends State<HomeScreen> with HomeTabBuilders {
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

  @override
  HomeController get controller => _controller;

  @override
  MarketController get marketController => _marketController;

  @override
  NumberFormat get priceFormat => _priceFormat;

  @override
  NumberFormat get wholeNumberFormat => _wholeNumberFormat;

  @override
  NumberFormat get twoDecimalFormat => _twoDecimalFormat;

  @override
  NumberFormat get smallNumberFormat => _smallNumberFormat;

  @override
  Future<void> Function() get refreshAll => _refresh;

  @override
  VoidCallback get showComingSoon => _showComingSoon;

  @override
  VoidCallback get openReminderCenter => _openReminderCenter;

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
