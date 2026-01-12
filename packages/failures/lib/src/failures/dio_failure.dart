import 'package:dio/dio.dart';

import '/src/utils/dio/http_status_code.dart';
import '/src/utils/dio/request_options_curl.dart';
import '/src/utils/name_transform_utils.dart';

import 'failure.dart';

class DioFailure extends Failure<DioException> {
  DioFailure(
    super.error, {
    FailureExtra? extra,
    StackTrace? stackTrace,
  }) : statusCode = HttpStatusCode.fromInt(error.response?.statusCode),
      super(
        extra: {
          if (extra != null) ...extra,
          ..._httpDetails(error.requestOptions, error.response),
        },
        stackTrace: error.stackTrace,
      );

  @override
  String get summary {
    final buffer = StringBuffer(
      '$runtimeType (.${error.type.name}, '
    );

    if (error.type == .badResponse) {
      buffer.write('${statusCode.code}, ');
    }

    buffer.write('${error.requestOptions.uri.path})');
    return buffer.toString();
  }

  @override
  String? get message => null;

  @override
  FailureType get type => .exception;

  final HttpStatusCode statusCode;

  bool get isTimeout {
    return <DioExceptionType>[
      .connectionTimeout,
      .sendTimeout,
      .receiveTimeout,
    ].contains(error.type);
  }

  bool get isBadResponse => error.type == .badResponse;

  bool get isNotFound => statusCode == .notFound;
  bool get isUnauthorised => statusCode == .unauthorized;

  static FailureExtra _httpDetails(
    RequestOptions request,
    Response? response,
  ) {
    String? dataToString(Object? data) {
      if (data == null) return null;

      const maxDataLength = 512;
      final string = '$data';

      return string.length > maxDataLength
        ? '${string.substring(0, maxDataLength)}...'
        : string;
    }

    return <DioFailureExtra, Object?>{
      .url: request.uri,
      .method: request.method,
      if (request.queryParameters.isNotEmpty) ...{
        .queryParameters: request.queryParameters,
      },
      if (request.headers.isNotEmpty) ...{
        .requestHeaders: request.headers,
      },
      .requestData: ?dataToString(request.data),
      .statusCode: ?response?.statusCode,
      if ((response?.headers.map != null) && response!.headers.map.isNotEmpty) ...{
        .responseHeaders: response.headers.map,
      },
      .responseData: ?dataToString(response?.data),
      .curl: request.curl,
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
  curl;

  @override
  String toString() => camelToSentence(name);
}
