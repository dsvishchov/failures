import '/src/types/failure.dart';

abstract mixin class FailureDescriptor<T extends Failure> {
  String? title(T failure) => null;
  String? message(T failure) => null;
}