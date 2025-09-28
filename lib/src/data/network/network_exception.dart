import 'package:dio/dio.dart';

/// 统一的网络异常模型：将 Dio 抛出的错误封装成结构化对象，
/// 既保留用户可读的信息，也方便开发者调试排查。
class NetworkException implements Exception {
  NetworkException({
    required this.message,
    this.statusCode,
    this.details,
    this.type,
  });

  /// 将 Dio 的异常转换为 [NetworkException]，提取状态码、原始数据等上下文。
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

  /// 面向用户的友好提示文本。
  final String message;

  /// HTTP 状态码（若有返回）。
  final int? statusCode;

  /// 原始响应数据或附加信息，便于日志与埋点。
  final dynamic details;

  /// Dio 定义的异常类型，可用于上层做精细化处理。
  final DioExceptionType? type;

  /// 根据不同异常类型生成默认提示文案。
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
