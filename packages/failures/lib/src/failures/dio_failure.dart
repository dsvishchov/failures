import 'package:dio/dio.dart';

import '/src/utils/dio/http_status_code.dart';
import '/src/utils/dio/request_options_curl.dart';

import 'failure.dart';

class DioFailure extends Failure<DioException> {
  DioFailure(
    DioException error,
    StackTrace? stackTrace,
  ) : statusCode = HttpStatusCode.fromInt(error.response?.statusCode),
      super(error, error.stackTrace);

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

  String get curl => error.requestOptions.curl;
}

class DioFailureDescriptor extends FailureDescriptor<DioFailure> {
  @override
  String? message(DioFailure failure) => failure.error.message;

  @override
  String? details(DioFailure failure) => null;
}
