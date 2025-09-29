import 'package:flutter/material.dart';

import 'package:coinglass_app/src/presentation/controllers/market_controller.dart';
import 'package:coinglass_app/src/presentation/widgets/market_news_list.dart';

/// 新闻标签页，复用热门行情列表作为资讯内容来源。
class NewsModule extends StatelessWidget {
  const NewsModule({super.key, required this.marketController});

  final MarketController marketController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MarketNewsList(controller: marketController),
    );
  }
}
