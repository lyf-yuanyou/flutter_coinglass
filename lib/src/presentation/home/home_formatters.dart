import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String formatPercent(double value) {
    final String prefix = value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }

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
