import 'package:stack_trace/stack_trace.dart';

import '/src/failures.dart';

/// Base class for all failures
abstract class Failure<E> {
  Failure(
    this.error, {
    this.message,
    this.extra,
    this.underlyingError,
    StackTrace? stackTrace,
  }) : stackTrace = stackTrace != null
    ? Trace.from(stackTrace)
    : Trace.current();

  /// Actual error caused this failure
  final E error;

  /// Detailed technical message
  final String? message;

  /// Extra information associated with the failure
  final FailureExtra? extra;

  /// Underlying error caused actual error
  final Object? underlyingError;

  /// Stack trace to track down the source of the failure
  Trace stackTrace;

  /// Short description of the failure
  String get summary => error.toString();

  /// Failure type allows to distinguish between exceptions
  /// or just failures within business logic layer
  FailureType get type => .exception;

  /// Allows to create an instance of Failure based on the failure
  /// types registered using [Failures], see [Failures.fromError]
  static Failure fromError(
    Object error, {
    String? message,
    FailureExtra? extra,
    Object? underlyingError,
    StackTrace? stackTrace,
  }) {
    return failures.fromError(
      error,
      message: message,
      extra: extra,
      underlyingError: underlyingError,
      stackTrace: stackTrace,
    );
  }

  /// Convenient checker for exception failure type
  bool get isException => type == .exception;

  /// Convenient checker for logical failure type
  bool get isLogical => type == .logical;

  @override
  String toString() => summary;
}

/// Type of extra data possible to add to any failure
typedef FailureExtra = Map<Object, dynamic>;

/// Failure types
enum FailureType {
  exception,
  logical,
}

/// Failure descriptor allows providing user facing details
/// about the failure which can be used to show some UI and
/// explain what happened.
class FailureDescriptor<F extends Failure> {
  String? title(F failure) => null;
  String? description(F failure) => null;
}

/// Provides a way to get [title] and [description]
/// about any specific failure directly through its instance.
extension FailureDescription on Failure {
  String? get title =>
    failures.descriptorFor(this)?.title(this);

  String? get description =>
    failures.descriptorFor(this)?.description(this);
}
