import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// 轻量级日志拦截器，按照统一格式输出请求 / 响应详细信息。
///
/// 使用 [dart:developer.log] 可以在 IDE Console 中保留换行与缩进格式，
/// 更易于排查问题。
class NetworkLoggerInterceptor extends Interceptor {
  NetworkLoggerInterceptor({this.logName = 'Network'})
      : _encoder = const JsonEncoder.withIndent('  ');

  final String logName;
  final JsonEncoder _encoder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 请求阶段打印方法、URL、请求头、查询参数及请求体。
    final StringBuffer buffer = StringBuffer()
      ..writeln('+--- Request ------------------------------------------')
      ..writeln('| [${options.method}] ${options.uri}')
      ..writeln('| Headers: ${_formatMap(options.headers)}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('| Query: ${_formatMap(options.queryParameters)}');
    }

    if (options.data != null) {
      buffer.writeln('| Body: ${_stringify(options.data)}');
    }

    buffer.writeln('+------------------------------------------------------');
    _log(buffer.toString());
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final RequestOptions options = response.requestOptions;
    // 响应阶段补充状态码与响应体，便于比对请求与返回内容。
    final StringBuffer buffer = StringBuffer()
      ..writeln('+--- Response -----------------------------------------')
      ..writeln('| [${options.method}] ${options.uri}')
      ..writeln('| Status: ${response.statusCode}')
      ..writeln('| Headers: ${_formatMap(response.headers.map)}')
      ..writeln('| Data: ${_stringify(response.data)}')
      ..writeln('+------------------------------------------------------');

    _log(buffer.toString());
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final RequestOptions options = err.requestOptions;
    final Response<dynamic>? response = err.response;
    // 错误阶段除基本信息外，还打印堆栈，方便定位问题源头。
    final StringBuffer buffer = StringBuffer()
      ..writeln('+--- Error --------------------------------------------')
      ..writeln('| [${options.method}] ${options.uri}')
      ..writeln('| Type: ${err.type}')
      ..writeln('| Message: ${err.message ?? '-'}');

    if (response != null) {
      buffer
        ..writeln('| Status: ${response.statusCode}')
        ..writeln('| Data: ${_stringify(response.data)}');
    }

    if (err.stackTrace != null) {
      buffer.writeln('| Stacktrace: ${err.stackTrace}');
    }

    buffer.writeln('+------------------------------------------------------');
    _log(buffer.toString());
    super.onError(err, handler);
  }

  String _formatMap(Map<dynamic, dynamic> map) {
    if (map.isEmpty) {
      return '{}';
    }
    return _encoder.convert(map);
  }

  String _stringify(dynamic value) {
    if (value == null) {
      return 'null';
    }
    if (value is String) {
      return value;
    }
    if (value is Map || value is Iterable) {
      try {
        return _encoder.convert(value);
      } catch (_) {
        return value.toString();
      }
    }
    return value.toString();
  }

  void _log(String message) {
    // name 字段方便在调试控制台中过滤网络日志。
    developer.log(message, name: logName);
  }
}
