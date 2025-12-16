import 'package:dio/dio.dart';

import '/src/failures.dart';

class DioFailure extends Failure<DioException> {
  DioFailure(
    DioException error,
    StackTrace? stackTrace,
  ) : statusCode = HttpStatusCode.fromInt(error.response?.statusCode),
      super(error, stackTrace ?? error.stackTrace);

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

  String get requestCurl => 'curl -i';
}

class DioFailureDescriptor extends FailureDescriptor<DioFailure> {
  @override
  String? message(DioFailure failure) => failure.error.message;

  @override
  String? details(DioFailure failure) => null;
}

enum HttpStatusCode {
  unknown(0),
  continue_(100),
  switchingProtocols(101),
  processing(102),
  ok(200),
  created(201),
  accepted(202),
  nonAuthoritativeInformation(203),
  noContent(204),
  resetContent(205),
  partialContent(206),
  multiStatus(207),
  alreadyReported(208),
  imUsed(226),
  multipleChoices(300),
  movedPermanently(301),
  found(302),
  movedTemporarily(302),
  seeOther(303),
  notModified(304),
  useProxy(305),
  temporaryRedirect(307),
  permanentRedirect(308),
  badRequest(400),
  unauthorized(401),
  paymentRequired(402),
  forbidden(403),
  notFound(404),
  methodNotAllowed(405),
  notAcceptable(406),
  proxyAuthenticationRequired(407),
  requestTimeout(408),
  conflict(409),
  gone(410),
  lengthRequired(411),
  preconditionFailed(412),
  requestEntityTooLarge(413),
  requestUriTooLong(414),
  unsupportedMediaType(415),
  requestedRangeNotSatisfiable(416),
  expectationFailed(417),
  misdirectedRequest(421),
  unprocessableEntity(422),
  locked(423),
  failedDependency(424),
  upgradeRequired(426),
  preconditionRequired(428),
  tooManyRequests(429),
  requestHeaderFieldsTooLarge(431),
  connectionClosedWithoutResponse(444),
  unavailableForLegalReasons(451),
  clientClosedRequest(499),
  internalServerError(500),
  notImplemented(501),
  badGateway(502),
  serviceUnavailable(503),
  gatewayTimeout(504),
  httpVersionNotSupported(505),
  variantAlsoNegotiates(506),
  insufficientStorage(507),
  loopDetected(508),
  notExtended(510),
  networkAuthenticationRequired(511),
  networkConnectTimeoutError(599);

  const HttpStatusCode(this.code);
  final int code;

  factory HttpStatusCode.fromInt(int? code) {
    return values.firstWhere(
      (value) => value.code == code,
      orElse: () => HttpStatusCode.unknown,
    );
  }

  bool get isInformational => code >= 100 && code <= 199;
  bool get isSuccessful => code >= 200 && code <= 299;
  bool get isRedirect => code >= 300 && code <= 399;
  bool get isClientError => code >= 400 && code <= 499;
  bool get isServerError => code >= 500 && code <= 599;
}