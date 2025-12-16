import 'package:dio/dio.dart';

import 'types/dio_failure.dart';
import 'types/generic_failure.dart';

/// Global instance to handle all failures
final failures = Failures.instance;

/// Provides a way to register and handle all built-in and
/// custom failures and their descriptors
class Failures {
  static final Failures instance = Failures._();
  factory Failures() => instance;

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

  void register<E>({
    required CreateFailure<E> create,
    required FailureDescriptor<Failure<E>> descriptor,
  }) {
    _meta[E] = FailureMeta<E>(create, descriptor);
  }

  FailureDescriptor descriptorFor(Failure failure)
    => _metaFor(failure.error).descriptor;


  Failure fromError(
    Object error,
    StackTrace? stackTrace,
  ) {
    return (error is Failure)
      ? error
      : _metaFor(error).create(error, stackTrace);
  }

  final Map<Type, dynamic> _meta = {};

  dynamic _metaFor(Object error)
    => _meta[error.runtimeType] ?? _meta[Object];
}

class FailureMeta<E> {
  const FailureMeta(
    this.create,
    this.descriptor,
  ): errorType = E;

  final CreateFailure<E> create;
  final FailureDescriptor<Failure<E>> descriptor;
  final Type errorType;
}

typedef CreateFailure<E> = Failure<E> Function(E error, StackTrace? stackTrace);

/// Base class for all failures
abstract class Failure<E> {
  const Failure(
    this.error,
    this.stackTrace,
  );

  final E error;
  final StackTrace? stackTrace;

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

/// This extension provides a way to get `message` and `details`
/// about any specific failure directly through its instance.
extension FailureDescription on Failure {
  String? get message
    => failures.descriptorFor(this).message(this);

  String? get details
    => failures.descriptorFor(this).details(this);
}