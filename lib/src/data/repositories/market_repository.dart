import '../datasources/market_remote_data_source.dart';
import '../models.dart';

/// 面向业务层的仓库，隔离具体的数据来源实现。
class MarketRepository {
  const MarketRepository(this._remoteDataSource);

  final MarketRemoteDataSource _remoteDataSource;

  /// 向 UI 或控制器暴露的统一入口。
  Future<List<MarketCoin>> fetchTopMovers({int limit = 10}) {
    return _remoteDataSource.fetchTopMovers(limit: limit);
  }
}
