import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 首页展示用的格式化工具集合，集中管理数字、颜色等格式。
class HomeFormatters {
  const HomeFormatters({
    required this.priceFormat,
    required this.wholeNumberFormat,
    required this.twoDecimalFormat,
    required this.smallNumberFormat,
  });

  final NumberFormat priceFormat;
  final NumberFormat wholeNumberFormat;
  final NumberFormat twoDecimalFormat;
  final NumberFormat smallNumberFormat;

  /// 将数值按数量级转换为中文“万/亿”单位，方便阅读。
  String formatLargeNumber(double value) {
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

  /// 根据价格区间切换不同的数字格式，兼顾精度与可读性。
  String formatMarketPrice(double price) {
    final double abs = price.abs();
    if (abs >= 1000) {
      return wholeNumberFormat.format(price);
    }
    if (abs >= 1) {
      return twoDecimalFormat.format(price);
    }
    return smallNumberFormat.format(price);
  }

  /// 统一百分比展示格式，补齐正号并限制两位小数。
  String formatPercent(double value) {
    final String prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }

  /// 根据币种首字母散列出配色，保持列表视觉区分度。
  Color colorForSymbol(String symbol) {
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
}
