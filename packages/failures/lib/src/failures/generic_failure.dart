import 'failure.dart';

class GenericFailure extends Failure<Object> {
  GenericFailure(
    super.error, {
    super.extra,
    super.stackTrace,
  });

  @override
  FailureType get type => .exception;

  @override
  String toString() => '${runtimeType} (${error.runtimeType})';
}

class GenericFailureDescriptor extends FailureDescriptor<GenericFailure> {
  @override
  String? message(GenericFailure failure) => failure.error.toString();

  @override
  String? details(GenericFailure failure) => null;
}
