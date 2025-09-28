import '../datasources/market_remote_data_source.dart';
import '../models.dart';

class MarketRepository {
  const MarketRepository(this._remoteDataSource);

  final MarketRemoteDataSource _remoteDataSource;

  Future<List<MarketCoin>> fetchTopMovers({int limit = 10}) {
    return _remoteDataSource.fetchTopMovers(limit: limit);
  }
}
