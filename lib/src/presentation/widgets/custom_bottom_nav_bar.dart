import 'package:flutter/material.dart';

/// 自定义底部导航项的数据描述。
class CustomBottomNavItem {
  const CustomBottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// 自定义底部导航栏，支持渐变背景与动画反馈。
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : assert(items.length >= 2);

  final List<CustomBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 12,
      color: theme.colorScheme.surface,
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == currentIndex;
            final color = selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _NavItemButton(
                  item: item,
                  color: color,
                  selected: selected,
                  onTap: () => onTap(index),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// 单个导航按钮，负责处理选中态动画。
class _NavItemButton extends StatelessWidget {
  const _NavItemButton({
    required this.item,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final CustomBottomNavItem item;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 22,
                color: color,
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
