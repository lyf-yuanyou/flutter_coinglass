import 'package:flutter/material.dart';

class MyProfileTab extends StatelessWidget {
  const MyProfileTab({
    super.key,
    required this.onLoginTap,
    required this.onPlaceholderTap,
  });

  final VoidCallback onLoginTap;
  final VoidCallback onPlaceholderTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color backgroundColor = theme.colorScheme.surfaceVariant.withOpacity(
      theme.brightness == Brightness.dark ? 0.25 : 0.15,
    );

    return ColoredBox(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: <Widget>[
            Text(
              '我的',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _ProfileHeader(onTap: onLoginTap),
            const SizedBox(height: 24),
            _SettingsCard(
              items: <_SettingsItemData>[
                _SettingsItemData(
                  icon: Icons.notifications_none_outlined,
                  label: '提醒',
                  onTap: onPlaceholderTap,
                ),
                _SettingsItemData(
                  icon: Icons.history_toggle_off,
                  label: '历史提醒',
                  onTap: onPlaceholderTap,
                ),
                _SettingsItemData(
                  icon: Icons.wb_sunny_outlined,
                  label: '外观',
                  onTap: onPlaceholderTap,
                ),
                _SettingsItemData(
                  icon: Icons.language,
                  label: '语言',
                  trailingLabel: '简体中文',
                  onTap: onPlaceholderTap,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              items: <_SettingsItemData>[
                _SettingsItemData(
                  icon: Icons.settings_outlined,
                  label: '更多设置',
                  onTap: onPlaceholderTap,
                ),
                _SettingsItemData(
                  icon: Icons.share_outlined,
                  label: '分享',
                  onTap: onPlaceholderTap,
                ),
                _SettingsItemData(
                  icon: Icons.star_border_rounded,
                  label: '给 CoinGlass 评分',
                  onTap: onPlaceholderTap,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color surface = theme.colorScheme.surface;
    final Color accent = theme.colorScheme.primary;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: accent.withOpacity(0.12),
                child: Icon(
                  Icons.person_outline,
                  size: 30,
                  color: accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '登录/注册',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '组合记录',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.items});

  final List<_SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i != 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 72,
                color: theme.dividerColor.withOpacity(0.3),
              ),
            _SettingsTile(data: items[i]),
          ],
        ],
      ),
    );
  }
}

class _SettingsItemData {
  const _SettingsItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingLabel,
  });

  final IconData icon;
  final String label;
  final String? trailingLabel;
  final VoidCallback onTap;
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.data});

  final _SettingsItemData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accent = theme.colorScheme.primary;

    return ListTile(
      onTap: data.onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accent.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(data.icon, color: accent, size: 22),
      ),
      title: Text(
        data.label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (data.trailingLabel != null) ...<Widget>[
            Text(
              data.trailingLabel!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
