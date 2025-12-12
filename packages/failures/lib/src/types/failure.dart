class Failure<T> {
  const Failure(
    this.error, {
    this.stackTrace,
  });

  final T? error;
  final StackTrace? stackTrace;
}