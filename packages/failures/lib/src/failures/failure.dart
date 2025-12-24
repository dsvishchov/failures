import 'package:stack_trace/stack_trace.dart';

import '/src/failures.dart';

/// Base class for all failures
abstract class Failure<E> {
  Failure(
    this.error, {
    this.extra,
    StackTrace? stackTrace,
  }) : this.stackTrace = stackTrace != null
    ? Trace.from(stackTrace)
    : Trace.current();

  /// Actual error caused this failure
  final E error;

  /// Extra information associated with the failure
  final FailureExtra? extra;

  /// Stack trace to track down the source of the failure
  final Trace stackTrace;

  /// Failure type allows to distinguish between exceptions
  /// or just failures within business logic layer
  FailureType get type;

  /// Short description of the failure
  @override
  String toString() => error.toString();

  /// Detailed technical (not user-facing) description
  String? get description => null;

  /// Allows to create an instance of Failure based on the failure
  /// types registered using [Failures], see [Failures.fromError]
  static Failure fromError(
    Object error, {
    FailureExtra? extra,
    StackTrace? stackTrace,
  }) {
    return failures.fromError(
      error,
      extra: extra,
      stackTrace: stackTrace,
    );
  }
}

/// Type of extra data possible to add to any failure
typedef FailureExtra = Map<Object, dynamic>;

/// Failure types
enum FailureType {
  exception,
  logic,
}

/// Failure descriptor allows providing user facing details
/// about the failure which can be used to show some UI and
/// explain what happened.
abstract class FailureDescriptor<F extends Failure> {
  String? message(F failure);
  String? details(F failure);
}

/// Provides a way to get [message] and [details]
/// about any specific failure directly through its instance.
extension FailureDescription on Failure {
  String? get message
    => failures.descriptorFor(this)?.message(this);

  String? get details
    => failures.descriptorFor(this)?.details(this);
}