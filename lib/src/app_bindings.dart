import 'package:get/get.dart';

import 'data/coinglass_api.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinGlassRepository>(
      () => CoinGlassRepository(
        apiKey: const String.fromEnvironment('COINGLASS_SECRET'),
      ),
      fenix: true,
    );
  }
}
