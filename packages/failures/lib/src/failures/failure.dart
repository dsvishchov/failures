import 'package:stack_trace/stack_trace.dart';

import '/src/failures.dart';

/// Base class for all failures
abstract class Failure<E> {
  Failure(
    this.error,
    StackTrace? stackTrace,
  ) : this.stackTrace = stackTrace != null
    ? Trace.from(stackTrace)
    : Trace.current();

  final E error;
  final Trace stackTrace;

  static Failure fromError(
    Object error,
    StackTrace? stackTrace,
  ) => failures.fromError(error, stackTrace);
}

/// Failure descriptor which allows to provide additional details
/// about any specific failure which afterwards can be used to be
/// logged into console, shown to the user etc.
abstract class FailureDescriptor<F extends Failure> {
  String? message(F failure);
  String? details(F failure);
}

/// This extension provides a way to get [message] and [details]
/// about any specific failure directly through its instance.
extension FailureDescription on Failure {
  String? get message
    => failures.descriptorFor(this).message(this);

  String? get details
    => failures.descriptorFor(this).details(this);
}