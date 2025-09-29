import 'package:flutter/material.dart';

/// 提醒中心页面，展示不同类型的通知能力。
class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  static const List<_ReminderCategory> _categories = <_ReminderCategory>[
    _ReminderCategory(
      title: '价格警报',
      description: '自定义目标价和幅度，价格触达时第一时间提醒。',
      icon: Icons.notifications_active_outlined,
      accentColor: Color(0xFFFFA726),
    ),
    _ReminderCategory(
      title: '价格波动',
      description: '关注 24 小时内的涨跌幅，一眼掌握市场异动。',
      icon: Icons.stacked_line_chart,
      accentColor: Color(0xFF42A5F5),
    ),
    _ReminderCategory(
      title: '行情推送',
      description: '获取主流币种的行情快讯，不错过每一次突破。',
      icon: Icons.campaign_outlined,
      accentColor: Color(0xFF7E57C2),
    ),
    _ReminderCategory(
      title: '资金费率',
      description: '监控资金费率拐点，发现多空力量的细微变化。',
      icon: Icons.percent,
      accentColor: Color(0xFF26A69A),
    ),
    _ReminderCategory(
      title: '多空比',
      description: '实时关注合约多空比，捕捉筹码倾斜的方向。',
      icon: Icons.swap_vert,
      accentColor: Color(0xFF5C6BC0),
    ),
    _ReminderCategory(
      title: '大额爆仓',
      description: '重大爆仓事件提醒，警惕市场黑天鹅。',
      icon: Icons.warning_amber_rounded,
      accentColor: Color(0xFFEF5350),
    ),
    _ReminderCategory(
      title: '交易所公告',
      description: '交易所停服、上新等公告第一时间知晓。',
      icon: Icons.article_outlined,
      accentColor: Color(0xFFFF7043),
    ),
    _ReminderCategory(
      title: '其他提醒',
      description: '自定义关注内容，打造你的专属通知中心。',
      icon: Icons.more_horiz,
      accentColor: Color(0xFF90A4AE),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color background = theme.colorScheme.surface;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('提醒'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_outlined),
            tooltip: '提醒管理',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _ReminderTile(category: category);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ),
    );
  }
}

/// 提醒类型条目，点击后可跳转至配置详情。
class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.category});

  final _ReminderCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color containerColor = theme.colorScheme.surfaceVariant.withOpacity(
      theme.brightness == Brightness.dark ? 0.35 : 0.6,
    );
    final Color descriptionColor = theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: category.accentColor.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  category.icon,
                  size: 22,
                  color: category.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      category.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: descriptionColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: descriptionColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 提醒分类的数据模型。
class _ReminderCategory {
  const _ReminderCategory({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}
