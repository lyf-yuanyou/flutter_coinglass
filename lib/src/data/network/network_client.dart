import 'package:dio/dio.dart';

import 'network_exception.dart';
import 'network_logger_interceptor.dart';

/// 针对 Dio 的轻量封装：统一客户端初始化、拦截器配置与异常转换，
/// 让业务层只关注调用方法即可。
class NetworkClient {
  NetworkClient({
    required String baseUrl,
    Dio? dio,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    Map<String, dynamic>? defaultHeaders,
    bool enableLogging = false,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: connectTimeout,
                receiveTimeout: receiveTimeout,
                responseType: ResponseType.json,
                headers: defaultHeaders,
              ),
            ) {
    if (enableLogging) {
      // 统一挂载自定义日志拦截器，保证输出格式一致。
      _dio.interceptors.add(NetworkLoggerInterceptor());
    }
  }

  final Dio _dio;

  Dio get rawClient => _dio;

  /// 暴露扩展点，方便调用方按需追加 Token 刷新等业务拦截器。
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// GET 请求便捷方法，避免调用方重复填写 HTTP 动词与参数模板。
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 核心请求入口：统一走 Dio 的 request 方法，集中处理错误与日志逻辑。
  Future<Response<T>> request<T>(
    String path, {
    required String method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Options requestOptions = options ?? Options();
      requestOptions.method = method;

      // 通过 request 将所有动词统一封装，调用层无需关心底层细节。
      return await _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (error) {
      throw NetworkException.fromDio(error);
    }
  }
}
