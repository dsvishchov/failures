class Failure<T> {
  const Failure(
    this.error, {
    this.stackTrace,
  });

  final T error;
  final StackTrace? stackTrace;
}

mixin class FailureDescriptor<T extends Failure> {
  String? title(T failure) => null;
  String? message(T failure) => null;
}