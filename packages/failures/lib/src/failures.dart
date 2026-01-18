import 'package:stack_trace/stack_trace.dart';

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
/// Use [register] method to register new type of failure, its
/// error type and possibly descriptor. You can always register
/// descriptor later by using [registerDescriptor] method.
///
/// Use [Failure.fromError] to create a failure matching the type
/// of the error provided in arguments. If no matching failure has
/// been registered then a [GenericFailure] will be returned.
///
/// Register a global handler by setting [onFailure] callback and
/// send all failures to handle through calling [handle] method.
class Failures {
  /// Provides access to the singleton instance
  static final Failures instance = Failures._();
  factory Failures() => instance;

  /// Register a new type of error and respective failure class
  void register<F extends Failure<E>, E>({
    required CreateFailure<E> create,
    FailureDescriptor<F>? descriptor,
  }) {
    assert((_registry[F] == null) && (F != GenericFailure), 'This failure is already registered');
    _registry[F] = _FailureMeta<F, E>(create, descriptor);
  }

  /// Register new descriptor for specific failure type
  void registerDescriptor<F extends Failure>(
    FailureDescriptor<F> descriptor,
  ) {
    assert(_registry[F] != null, 'Provided failure type is not registered yet');
    _registry[F].descriptor = descriptor;
  }

  /// Reset by removing all registered failure types
  void reset() {
    onFailure = null;
    _registry.clear();
  }

  /// Get descriptor for specific failure
  FailureDescriptor? descriptorFor(Failure failure) {
    return _registry[failure.runtimeType]?.descriptor;
  }

  /// Create a failure from the given error and its type
  Failure fromError(
    Object error, {
    String? message,
    FailureExtra? extra,
    Object? underlyingError,
    StackTrace? stackTrace,
  }) {
    // If an instance of Failure is thrown let's re-create it with
    // a stack trace provided instead of using the current one
    if (error is Failure) {
      final failure = error;
      if (stackTrace != null) {
        failure.stackTrace = Trace.from(stackTrace);
      }
      return failure;
    }

    final meta = _registry.values.where(
      (meta) => meta.canHandleError(error),
    ).firstOrNull;

    final create = meta != null
      ? meta.create
      : GenericFailure.new;

    return create(
      error,
      message: message,
      extra: extra,
      underlyingError: underlyingError,
      stackTrace: stackTrace,
    );
  }

  /// Handle a failure by calling a callback when provided
  void handle(Failure failure) {
    failures.onFailure?.call(failure);
  }

  /// Callback to be triggered to handled
  void Function(Failure failure)? onFailure;

  Failures._();

  final Map<Type, dynamic> _registry = {};
}

/// Failure creation function
typedef CreateFailure<E> = Failure<E> Function(
  E error, {
  String? message,
  FailureExtra? extra,
  Object? underlyingError,
  StackTrace? stackTrace,
});

class _FailureMeta<F extends Failure<E>, E> {
  _FailureMeta(
    this.create,
    this.descriptor,
  );

  final CreateFailure<E> create;
  FailureDescriptor<F>? descriptor;

  bool canHandleError(dynamic error) => error is E;

  Type get failureType => F;
  Type get errorType => E;
}
