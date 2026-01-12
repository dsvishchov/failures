import 'failure.dart';

class GenericFailure extends Failure<Object> {
  GenericFailure(
    super.error, {
    super.extra,
    super.stackTrace,
  });

  @override
  String get summary => '$runtimeType (${error.runtimeType})';

  @override
  String? get message => error.toString();

  @override
  FailureType get type => .exception;
}