import 'package:meta/meta_meta.dart';

/// An annotation used to specify that `Failure` should be generated for this enum.
@Target({TargetKind.enumType})
class FailureEnum {
  const FailureEnum({
    this.name,
  });

  final String? name;
}

const failureEnum = FailureEnum();
