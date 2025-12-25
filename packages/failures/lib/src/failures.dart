import '/src/failures/failure.dart';
import '/src/failures/generic_failure.dart';

/// Global singleton instance
final failures = Failures.instance;

/// Provides a single place to register and handle failures.
///
/// Each [Failure] subclass handles a single type of errors and
/// should provide a way to create them (typically through constructor
/// tear-off) and describe them both for technical purposes and
/// for user facing UI.
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

  /// Default private constructor
  Failures._();

  /// Register a new type of error and respective failure class
  void register<F extends Failure<E>, E>({
    required CreateFailure<E> create,
    FailureDescriptor<F>? descriptor,
  }) {
    _meta[E] = _FailureMeta<F, E>(create, descriptor);
  }

  /// Register new descriptor for specific failure type
  void registerDescriptor<F extends Failure>(
    FailureDescriptor<F> descriptor,
  ) {
    final value = _meta.values.where(
      (meta) => meta.failureType == F,
    ).firstOrNull;

    assert(value != null, 'Provided failure type is not registered yet');
    if (value != null) {
      _meta[value.errorType].descriptor = descriptor;
    }
  }

  /// Get descriptor for specific failure
  FailureDescriptor? descriptorFor(Failure failure)
    => _metaFor(failure.error).descriptor;

  /// Create a failure from the given error and its type
  Failure fromError(
    Object error, {
    FailureExtra? extra,
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

  /// Handle a failure by calling a callback when provided
  void handle(Failure failure) {
    failures.onFailure?.call(failure);
  }

  /// Callback to be triggered after each failure creation
  void Function(Failure failure)? onFailure;

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

class _FailureMeta<F extends Failure<E>, E> {
  _FailureMeta(
    this.create,
    this.descriptor,
  ) : failureType = F, errorType = E;

  final CreateFailure<E> create;
  FailureDescriptor<F>? descriptor;

  final Type errorType;
  final Type failureType;
}
