import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models.dart';
import '../controllers/market_controller.dart';

class TopMoversSection extends StatelessWidget {
  const TopMoversSection({
    required this.controller,
    super.key,
  });

  final MarketController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat priceFormat =
        NumberFormat.compactSimpleCurrency(name: '\$');

    return Obx(() {
      final bool isLoading = controller.isLoading.value;
      final List<MarketCoin> items = controller.topMovers;
      final String? errorMessage = controller.errorMessage;
      final DateTime? lastUpdated = controller.lastUpdated.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '实时热门币种',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed:
                      isLoading ? null : () => controller.loadTopMovers(),
                  tooltip: '刷新',
                ),
              ],
            ),
            if (lastUpdated != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  "最近更新 ${DateFormat('HH:mm:ss').format(lastUpdated)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (isLoading && items.isEmpty)
              const SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null && items.isEmpty)
              _ErrorPlaceholder(
                message: errorMessage,
                onRetry: controller.loadTopMovers,
              )
            else if (items.isEmpty)
              const _ErrorPlaceholder(
                message: '暂时没有数据，稍后再试试~',
              )
            else
              SizedBox(
                height: 148,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final MarketCoin coin = items[index];
                    final Color changeColor = coin.isPositive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error;
                    final String changeText =
                        _formatPercent(coin.priceChangePercentage24h);

                    return _CoinCard(
                      coin: coin,
                      priceText: priceFormat.format(coin.currentPrice),
                      changeText: changeText,
                      changeColor: changeColor,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                ),
              ),
          ],
        ),
      );
    });
  }

  static String _formatPercent(double value) {
    final String formatted = value.abs().toStringAsFixed(2);
    return value >= 0 ? '+$formatted%' : '-$formatted%';
  }
}

class _CoinCard extends StatelessWidget {
  const _CoinCard({
    required this.coin,
    required this.priceText,
    required this.changeText,
    required this.changeColor,
  });

  final MarketCoin coin;
  final String priceText;
  final String changeText;
  final Color changeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int take = min(2, coin.symbol.length);
    final String initials = take == 0 ? '?' : coin.symbol.substring(0, take);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.surface,
                child: Text(
                  initials,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '#${coin.marketCapRank}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            priceText,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            changeText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({
    required this.message,
    this.onRetry,
  });

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null)
              TextButton(
                onPressed: () => onRetry!(),
                child: const Text('重试'),
              ),
          ],
        ),
      ),
    );
  }
}
