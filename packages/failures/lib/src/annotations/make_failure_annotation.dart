import 'package:meta/meta_meta.dart';

/// An annotation used to specify that `Failure` should be generated for this enum.
@Target({TargetKind.enumType})
class MakeFailure {
  const MakeFailure({
    this.name,
  });

  final String? name;
}

const makeFailure = MakeFailure();
