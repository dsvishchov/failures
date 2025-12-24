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

  @override
  String? get description => error.toString();
}