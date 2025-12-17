import 'package:dio/dio.dart';

import '/src/failures/dio_failure.dart';
import '/src/failures/failure.dart';
import '/src/failures/generic_failure.dart';

/// Global singleton instance
final failures = Failures.instance;

/// Provides a single place to register and handle failures.
///
/// Each [Failure] subclass handles a single type of errors and
/// should provide a way to create them (typically through constructor
/// tear-off) and describe using an instance of [FailureDescriptor].
///
/// Use [register] method to register new type of errors and their
/// appropriate failure class and descriptor.
///
/// Use [Failure.fromError] to create a failure matching the type
/// of the error provided in arguments. If no matching failure has
/// been registered then a [GenericFailure] will be returned. Keep
/// in mind that only direct type matching is supported, i.e if you
/// use a subclass of a failure type registered it won't be matched.
///
/// Typically to handle all unhandled exceptions you might want to
/// use [FlutterError.onError] and [PlatformDispatcher.instance.onError].
/// Ref.: https://docs.flutter.dev/testing/errors
class Failures {
  /// Provides access to the singleton instance
  static final Failures instance = Failures._();
  factory Failures() => instance;

  /// Default private constructor which registers built-in failures
  Failures._() {
    register<Object>(
      create: GenericFailure.new,
      descriptor: GenericFailureDescriptor(),
    );

    register<DioException>(
      create: DioFailure.new,
      descriptor: DioFailureDescriptor(),
    );
  }

  /// Register a new type of error and respective failure class
  void register<E>({
    required CreateFailure<E> create,
    required FailureDescriptor<Failure<E>> descriptor,
  }) {
    _meta[E] = _FailureMeta<E>(create, descriptor);
  }

  /// Get descriptor for specific failure
  FailureDescriptor descriptorFor(Failure failure)
    => _metaFor(failure.error).descriptor;

  /// Create a failure from the given error and its type
  Failure fromError(
    Object error, {
    Map<Enum, dynamic>? extra,
    StackTrace? stackTrace,
  }) {
    // If instance of Failure is thrown let's re-create it with
    // a stack trace provided instead of using the current one
    if (error is Failure) {
      final failure = error;
      if (stackTrace == null) {
        return failure;
      } else {
        error = failure.error;
      }
    }

    return _metaFor(error).create(
      error,
      extra: extra,
      stackTrace: stackTrace,
    );
  }

  final Map<Type, dynamic> _meta = {};

  dynamic _metaFor(Object error)
    => _meta[error.runtimeType] ?? _meta[Object];
}

/// Failure creation function
typedef CreateFailure<E> = Failure<E> Function(
  E error, {
  FailureExtra? extra,
  StackTrace? stackTrace,
});

class _FailureMeta<E> {
  const _FailureMeta(
    this.create,
    this.descriptor,
  ) : errorType = E;

  final CreateFailure<E> create;
  final FailureDescriptor<Failure<E>> descriptor;
  final Type errorType;
}
