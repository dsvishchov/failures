import 'types/failure.dart';

final failures = Failures.instance;

class Failures {
  Failures._();

  static final Failures instance = Failures._();
  factory Failures() => instance;

  final Map<Type, FailureDescriptor> _descriptors = {};

  void register<F extends Failure>({
    FailureDescriptor<F>? descriptor,
  }) {
    _descriptors[F] = descriptor ?? FailureDescriptor<F>();
  }

  void unregister<F extends Failure>() {
    _descriptors.remove(F);
  }

  FailureDescriptor? descriptor(Failure failure)
    => _descriptors[failure.runtimeType];
}

extension FailureDescription on Failure {
  String? get title {
    return Failures.instance.descriptor(this)?.title(this);
  }

  String? get message {
    return Failures.instance.descriptor(this)?.message(this);
  }
}