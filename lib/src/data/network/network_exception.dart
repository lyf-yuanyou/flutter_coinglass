import 'package:dio/dio.dart';

class NetworkException implements Exception {
  NetworkException({
    required this.message,
    this.statusCode,
    this.details,
    this.type,
  });

  factory NetworkException.fromDio(DioException error) {
    final Response<dynamic>? response = error.response;
    final int? status = response?.statusCode;
    final dynamic payload = response?.data;
    final String friendlyMessage = _mapMessage(error, status);

    return NetworkException(
      message: friendlyMessage,
      statusCode: status,
      details: payload,
      type: error.type,
    );
  }

  final String message;
  final int? statusCode;
  final dynamic details;
  final DioExceptionType? type;

  static String _mapMessage(DioException error, int? statusCode) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return '网络连接失败，请稍后重试';
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络请求超时，请检查网络状态';
      case DioExceptionType.badResponse:
        return '服务返回异常(${statusCode ?? '未知状态'})';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.unknown:
      default:
        return error.message ?? '发生未知的网络错误';
    }
  }

  @override
  String toString() {
    return 'NetworkException(statusCode: $statusCode, message: $message)';
  }
}
