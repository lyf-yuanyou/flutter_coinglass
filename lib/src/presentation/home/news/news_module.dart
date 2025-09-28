import 'package:flutter/material.dart';

import 'package:coinglass_app/src/presentation/controllers/market_controller.dart';
import 'package:coinglass_app/src/presentation/widgets/market_news_list.dart';

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
