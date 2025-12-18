import 'failure.dart';

class GenericFailure extends Failure<Object> {
  GenericFailure(
    super.error, {
    super.extra,
    super.stackTrace,
  });

  @override
  FailureType get type => .exception;
}

class GenericFailureDescriptor extends FailureDescriptor<GenericFailure> {
  @override
  String? message(GenericFailure failure) => failure.error.toString();

  @override
  String? details(GenericFailure failure) => null;
}
