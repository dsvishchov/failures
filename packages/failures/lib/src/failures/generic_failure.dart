import 'failure.dart';

class GenericFailure extends Failure<Object> {
  GenericFailure(
    super.error, {
    super.message,
    super.extra,
    super.underlyingError,
    super.stackTrace,
  });

  @override
  String get summary => '$runtimeType (${error.runtimeType})';

  @override
  String? get message => error.toString();
}