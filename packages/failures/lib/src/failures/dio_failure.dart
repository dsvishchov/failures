import 'package:dio/dio.dart';

import '/src/utils/dio/http_status_code.dart';
import '/src/utils/dio/request_options_curl.dart';

import 'failure.dart';

class DioFailure extends Failure<DioException> {
  DioFailure(
    DioException error, {
    FailureExtra? extra,
    StackTrace? stackTrace,
  }) : statusCode = HttpStatusCode.fromInt(error.response?.statusCode),
      super(
        error,
        extra: {
          if (extra != null) ...extra,
          ..._httpDetails(error.requestOptions, error.response),
        },

        stackTrace: error.stackTrace
      );

  final HttpStatusCode statusCode;

  bool get isTimeout {
    return [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ].contains(error.type);
  }

  bool get isBadResponse => error.type == DioExceptionType.badResponse;

  bool get isNotFound => statusCode == HttpStatusCode.notFound;
  bool get isUnauthorised => statusCode == HttpStatusCode.unauthorized;

  static FailureExtra _httpDetails(
    RequestOptions request,
    Response? response,
  ) {
    String? _dataToString(Object? data) {
      if (data == null) return null;

      const maxDataLength = 512;
      final string = '$data';

      return string.length > maxDataLength
        ? '${string.substring(0, maxDataLength)}...'
        : string;
    }

    return {
      DioFailureExtra.url: request.uri,
      DioFailureExtra.method: request.method,
      DioFailureExtra.queryParameters: request.queryParameters,
      DioFailureExtra.requestHeaders: request.headers,
      DioFailureExtra.requestData: _dataToString(request.data),
      DioFailureExtra.statusCode: response?.statusCode,
      DioFailureExtra.responseHeaders: response?.headers.map,
      DioFailureExtra.responseData: _dataToString(response?.data),
      DioFailureExtra.curl: request.curl,
    };
  }
}

enum DioFailureExtra {
  url,
  method,
  queryParameters,
  requestHeaders,
  requestData,
  statusCode,
  responseHeaders,
  responseData,
  curl,
}

class DioFailureDescriptor extends FailureDescriptor<DioFailure> {
  @override
  String? message(DioFailure failure) => failure.error.message;

  @override
  String? details(DioFailure failure) => null;
}
